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

try {
  for (const theme of ['ascii', 'shadcn']) {
    for (const width of [375, 768, 1440]) {
      for (const mode of ['light', 'dark']) {
        const context = await browser.newContext({
          viewport: { width, height: 800 },
          reducedMotion: 'reduce',
        });
        await context.addInitScript(({ theme, mode }) => {
          localStorage.setItem('arcane-stylesheet-id', theme);
          localStorage.setItem('arcane-theme-mode', mode);
        }, { theme, mode });
        const page = await context.newPage();
        const errors = [];
        page.on('pageerror', (error) => errors.push(error.message));
        assert.ok((await page.goto(`${baseUrl}/reference/theming/`))?.ok());
        await page.waitForFunction(() => document.documentElement.dataset.arcaneClientReady === 'true');
        const slot = page.locator(`[data-kb-style-slot="${theme}"]`);
        const header = slot.locator('.kb-topbar');
        const minimum = width <= 900 ? 44 : 36;
        const controls = await header.locator('button, select, .kb-topbar-github, .kb-search-input').evaluateAll((elements) => elements
          .filter((element) => element.getBoundingClientRect().width > 0)
          .map((element) => ({
            label: element.getAttribute('aria-label'),
            box: element.getBoundingClientRect().toJSON(),
          })));
        for (const control of controls) {
          assert.ok(control.box.width >= minimum && control.box.height >= minimum,
            `${theme}/${width}/${mode}: ${control.label} shrank below ${minimum}px`);
          assert.ok(control.box.x >= 0 && control.box.right <= width,
            `${control.label} extends outside the header`);
        }
        const brand = await header.locator('.kb-topbar-brand').boundingBox();
        assert.ok(await header.locator('.kb-topbar-brand-label').evaluate((element) => element.scrollWidth <= element.clientWidth),
          'The example brand must remain readable beside the header controls');
        for (const control of controls) {
          assert.ok(control.box.right <= brand.x || control.box.x >= brand.x + brand.width,
            `${theme}/${width}/${mode}: ${control.label} overlaps the brand`);
        }
        const height = controls[0].box.height;
        assert.ok(controls.every((control) => Math.abs(control.box.height - height) <= 1),
          'Header controls must share one height');
        assert.ok(controls.every((control) => Math.abs(control.box.y - controls[0].box.y) <= 1),
          'Header controls must align on the same row');
        assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));

        if (width <= 900) {
          await slot.locator('[data-kb-sidebar-toggle]').click();
          const sidebar = slot.locator('.kb-sidebar');
          await page.waitForFunction((theme) => {
            const sidebar = document.querySelector(`[data-kb-style-slot="${theme}"] .kb-sidebar`);
            return sidebar.classList.contains('open') && Math.abs(sidebar.getBoundingClientRect().left) < 1;
          }, theme);
          const search = sidebar.getByRole('combobox', { name: 'Search documentation' });
          const searchBox = await search.boundingBox();
          const headerBox = await header.boundingBox();
          const sidebarBox = await sidebar.boundingBox();
          assert.ok(searchBox.y >= headerBox.y + headerBox.height,
            'The sidebar search must start below the sticky header');
          assert.ok(searchBox.width >= sidebarBox.width - 32 && searchBox.height >= minimum,
            'The drawer search must use its available width and a full touch target');
          if (width <= 600) {
            assert.equal(await header.locator('.kb-style-switcher').isVisible(), false);
            const select = sidebar.locator('.kb-mobile-style-controls [data-kb-stylesheet-select]');
            assert.equal(await select.inputValue(), theme);
            const selectBox = await select.boundingBox();
            assert.ok(selectBox.height >= minimum && selectBox.width >= 150);
          }
          await search.fill('Ascii');
          await sidebar.locator('[data-kb-search-results] a').first().waitFor();
          assert.ok(await sidebar.locator('[data-kb-search-results]').evaluate((element) => {
            const bounds = element.getBoundingClientRect();
            const sidebar = element.closest('.kb-sidebar').getBoundingClientRect();
            return bounds.left >= sidebar.left && bounds.right <= sidebar.right;
          }), 'Search results must stay inside the drawer');
          await search.fill('');
          await slot.locator('[data-kb-sidebar-toggle]').focus();
          await page.keyboard.press('Escape');
          assert.equal(await sidebar.getAttribute('aria-hidden'), 'true');
        } else {
          const sidebar = slot.locator('.kb-sidebar');
          const sidebarBox = await sidebar.boundingBox();
          const headerBox = await header.boundingBox();
          assert.ok(Math.abs(sidebarBox.y - headerBox.y - headerBox.height) <= 1,
            'The desktop sidebar must not count the header offset twice');
          const wrapped = sidebar.getByRole('link', { name: 'Keyboard and Interaction Shortcuts' });
          assert.ok(await wrapped.evaluate((element) => {
            const label = element.querySelector('.sidebar-link-label');
            const icon = element.querySelector('.sidebar-icon');
            return label.getBoundingClientRect().left >= icon.getBoundingClientRect().right + 4;
          }), 'Wrapped navigation labels must keep their icon indentation');
          const toc = slot.locator('.kb-toc-panel');
          const tocBox = await toc.boundingBox();
          const tocTitle = await toc.locator('.toc-title').boundingBox();
          assert.ok(Math.abs(tocTitle.x - tocBox.x) <= 1 && Math.abs(tocTitle.y - tocBox.y) <= 1,
            'The table of contents heading must align with its column without nested panel padding');
          assert.ok(tocBox.height <= 800 - 80,
            'Long tables of contents must fit within the viewport');
          await toc.locator('a').last().scrollIntoViewIfNeeded();
          assert.ok(await toc.evaluate((element) => element.scrollTop > 0),
            'Long tables of contents must scroll independently');
        }
        assert.deepEqual(errors, []);
        await context.close();
      }
    }
  }
  console.log('Knowledge base layout passed: Ascii/Shadcn light/dark, 375/768/1440px, header geometry, drawer search/selectors, navigation wrapping, and TOC scrolling.');
} finally {
  await browser.close();
}
