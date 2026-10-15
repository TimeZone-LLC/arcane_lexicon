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
    await page.locator('[data-kb-stylesheet-select]:visible').first().inputValue(),
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
  ), /monospace/);
  assert.equal(await page.locator('#arcane-root').evaluate(
    (element) => getComputedStyle(element).getPropertyValue('--background').trim(),
  ), dark ? '#111310' : '#f6f5f0');
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

try {
  for (const width of [375, 768, 1440]) {
    const context = await browser.newContext({ viewport: { width, height: 1000 } });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', (error) => errors.push(error.message));
    assert.ok((await page.goto(`${baseUrl}/`))?.ok());
    await page.waitForFunction(() => (
      document.documentElement.getAttribute('data-arcane-client-ready') === 'true'
    ));
    assert.equal(await page.locator('#arcane-root').getAttribute('data-arcane-theme'), 'neon');
    await page.locator('[data-kb-stylesheet-select]:visible').first().selectOption('ascii');
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
    assert.deepEqual(errors, [], `${width}px theme navigation emitted page errors`);
    await context.close();
  }
  console.log('Ascii theme passed: default preserved, selection, brightness, navigation, history, and 375/768/1440px layout.');
} finally {
  await browser.close();
}
