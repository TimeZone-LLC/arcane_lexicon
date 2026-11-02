import assert from 'node:assert/strict';
import { chromium } from 'playwright';

const baseUrl = (
  process.env.ARCANE_LEXICON_DOCS_URL
    ?? 'http://127.0.0.1:41738/arcane_lexicon'
).replace(/\/+$/, '');
const browser = await chromium.launch({
  headless: true,
  executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE,
});

async function verifyAscii(page, dark) {
  await page.waitForFunction((expectedDark) => {
    const root = document.querySelector('#arcane-root');
    const active = document.querySelector(
      '[data-kb-style-slot="ascii"].kb-style-slot-active:not([hidden])',
    );
    return root?.getAttribute('data-arcane-theme') === 'ascii'
      && Boolean(active)
      && root.classList.contains('dark') === expectedDark;
  }, dark);
  assert.equal(
    await page.locator('[data-kb-style-slot="ascii"] [data-kb-stylesheet-select]').first().inputValue(),
    'ascii',
  );
  assert.equal(await page.evaluate(() => (
    localStorage.getItem('arcane-stylesheet-id')
  )), 'ascii');
  for (const id of ['arcane-theme-vars-ascii-default', 'arcane-component-styles-ascii-default']) {
    assert.equal(await page.locator(`#${id}`).getAttribute('media'), 'all');
  }
  assert.match(await page.locator('#arcane-root').evaluate(
    (element) => getComputedStyle(element).fontFamily,
  ), /sans-serif/);
  assert.doesNotMatch(await page.locator('#arcane-root').evaluate(
    (element) => getComputedStyle(element).fontFamily,
  ), /monospace/);
  assert.equal(await page.locator('#arcane-root').evaluate(
    (element) => getComputedStyle(element).getPropertyValue('--background').trim(),
  ), dark ? '#101014' : '#f2f1ee');
  const slot = page.locator('[data-kb-style-slot="ascii"]');
  const toc = slot.locator('.kb-toc-panel');
  if (await toc.count()) {
    assert.equal(await toc.isVisible(), page.viewportSize().width > 900);
  }
  if (page.viewportSize().width <= 900) {
    assert.ok(await slot.locator('.kb-sidebar').evaluate((element) => (
      element.hasAttribute('inert')
        && element.getBoundingClientRect().right <= 1
    )), 'The closed mobile sidebar must remain outside the content');
  } else {
    assert.ok(await slot.locator('.kb-sidebar').evaluate((element) => (
      element.getBoundingClientRect().left >= 0
    )));
  }
  assert.ok(await page.evaluate(() => (
    document.documentElement.scrollWidth <= innerWidth
  )), 'Ascii must fit the viewport');
}

async function verifyMotion(page, dark) {
  assert.ok((await page.goto(`${baseUrl}/features/ascii-motion/`))?.ok());
  await verifyAscii(page, dark);
  const demo = page.locator('[data-kb-style-slot="ascii"] .lexicon-ascii-demo');
  const orbit = demo.locator('.ascii-orbit');
  const track = orbit.locator('.ascii-orbit-track').first();
  await orbit.scrollIntoViewIfNeeded();
  assert.ok(await demo.locator('.lexicon-ascii-orbit').evaluate((element) => {
    const orbit = element.querySelector('.ascii-orbit').getBoundingClientRect();
    const label = element.querySelector('.lexicon-ascii-orbit-label').getBoundingClientRect();
    return Math.abs(label.x + label.width / 2 - orbit.x - orbit.width / 2) < 1
      && Math.abs(label.y + label.height / 2 - orbit.y - orbit.height / 2) < 1
      && label.height < label.width;
  }), 'The orbit label must remain centered and readable on one line');
  await page.waitForFunction(() => {
    const track = document.querySelector(
      '[data-kb-style-slot="ascii"] .ascii-orbit-track',
    );
    return track && getComputedStyle(track).animationPlayState === 'running';
  });
  const firstTransform = await track.evaluate(
    (element) => getComputedStyle(element).transform,
  );
  await page.waitForFunction((previous) => {
    const track = document.querySelector(
      '[data-kb-style-slot="ascii"] .ascii-orbit-track',
    );
    return getComputedStyle(track).transform !== previous;
  }, firstTransform);

  const pause = demo.locator('[data-ascii-pause]');
  await pause.click();
  await page.waitForFunction(() => document.querySelector(
    '[data-kb-style-slot="ascii"] [data-ascii-pause]',
  )?.getAttribute('aria-pressed') === 'true');
  assert.equal(await track.evaluate(
    (element) => getComputedStyle(element).animationPlayState,
  ), 'paused');
  assert.equal(await demo.locator('[data-ascii-replay-control]').isDisabled(), true);
  const pausedTransform = await track.evaluate(
    (element) => getComputedStyle(element).transform,
  );
  await page.waitForTimeout(100);
  assert.equal(await track.evaluate(
    (element) => getComputedStyle(element).transform,
  ), pausedTransform, 'Pausing must hold the orbit in place');

  await pause.click();
  await page.waitForFunction(() => document.querySelector(
    '[data-kb-style-slot="ascii"] [data-ascii-pause]',
  )?.getAttribute('aria-pressed') === 'false');
  const replay = demo.locator('[data-ascii-replay-control]');
  await replay.focus();
  await page.keyboard.press('Enter');
  await page.waitForFunction(() => document.querySelector(
    '[data-kb-style-slot="ascii"] [data-ascii-replay]',
  )?.getAttribute('data-ascii-replay') === '1');
  await orbit.scrollIntoViewIfNeeded();
  await page.waitForFunction(() => {
    const track = document.querySelector(
      '[data-kb-style-slot="ascii"] .ascii-orbit-track',
    );
    return track && getComputedStyle(track).animationPlayState === 'running';
  });

  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.waitForFunction(() => {
    const demo = document.querySelector('[data-kb-style-slot="ascii"] .lexicon-ascii-demo');
    const tracks = [...demo.querySelectorAll('.ascii-orbit-track')];
    const reveals = [...demo.querySelectorAll('.ascii-reveal')];
    return tracks.length > 0 && reveals.length > 0
      && tracks.every((track) => getComputedStyle(track).animationPlayState === 'paused')
      && reveals.every((reveal) => getComputedStyle(reveal).opacity === '1');
  });
  assert.ok(await demo.locator('.ascii-text-letter').evaluateAll(
    (letters) => letters.every((letter) => getComputedStyle(letter).opacity === '1'),
  ), 'Reduced motion must keep every label readable');
  assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
  await page.emulateMedia({ reducedMotion: 'no-preference' });
}

try {
  for (const width of [375, 768, 1440]) {
    const context = await browser.newContext({
      viewport: { width, height: 1000 },
      reducedMotion: 'no-preference',
    });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', (error) => errors.push(error.message));
    assert.ok((await page.goto(`${baseUrl}/`))?.ok());
    await page.waitForFunction(() => (
      document.documentElement.getAttribute('data-arcane-client-ready') === 'true'
    ));
    assert.equal(await page.locator('#arcane-root').getAttribute('data-arcane-theme'), 'neon');
    if (width <= 600) {
      await page.locator('[data-kb-style-slot="neon"] [data-kb-sidebar-toggle]').click();
      await page.locator('[data-kb-style-slot="neon"] .kb-mobile-style-controls [data-kb-stylesheet-select]').selectOption('ascii');
      await page.keyboard.press('Escape');
    } else {
      await page.locator('[data-kb-stylesheet-select]:visible').first().selectOption('ascii');
    }
    const wasDark = await page.locator('#arcane-root').evaluate(
      (element) => element.classList.contains('dark'),
    );
    await verifyAscii(page, wasDark);
    const slot = page.locator('[data-kb-style-slot="ascii"]');
    await slot.locator('[data-kb-theme-toggle]:visible').first().click();
    await verifyAscii(page, !wasDark);
    assert.ok((await page.goto(`${baseUrl}/reference/theming/`))?.ok());
    await verifyAscii(page, !wasDark);
    await slot.getByRole('heading', { name: /^AsciiStylesheet/ }).waitFor();
    await page.goBack();
    await verifyAscii(page, !wasDark);
    await page.goForward();
    await verifyAscii(page, !wasDark);
    await verifyMotion(page, !wasDark);
    await slot.locator('[data-kb-theme-toggle]:visible').first().click();
    await verifyAscii(page, wasDark);
    await verifyMotion(page, wasDark);
    assert.deepEqual(errors, [], `${width}px theme navigation emitted page errors`);
    await context.close();
  }
  console.log('Ascii theme passed: selection, light/dark motion, navigation, pause, keyboard replay, reduced motion, and 375/768/1440px layout.');
} finally {
  await browser.close();
}
