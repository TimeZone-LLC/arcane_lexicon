import { readFile } from 'node:fs/promises';
import { chromium } from 'playwright';

const baseUrl = (
  process.env.ARCANE_LEXICON_DOCS_URL
    ?? 'http://127.0.0.1:41738/arcane_lexicon'
).replace(/\/+$/, '');
const viewports = [
  { name: 'mobile', width: 375, height: 900 },
  { name: 'tablet', width: 768, height: 1000 },
  { name: 'desktop', width: 1440, height: 1000 },
];
const searchIndex = JSON.parse(
  await readFile(
    new URL('../../example/build/jaspr/search-index.json', import.meta.url),
    'utf8',
  ),
);
const routes = [...new Set(searchIndex.entries.map(({ path }) => (
  path.startsWith('/') ? path : `/${path}`
)))];
const failures = [];

const activeSlotSelector = [
  '[data-kb-style-slot].kb-style-slot-active:not([hidden])',
  '[data-kb-style-slot]:not([hidden])',
].join(',');

function urlForRoute(route) {
  return `${baseUrl}${route === '/' ? '/' : route}`;
}

async function loadRoute(page, route) {
  const response = await page.goto(urlForRoute(route), {
    waitUntil: 'domcontentloaded',
    timeout: 30_000,
  });
  if (!response?.ok()) {
    throw new Error(`HTTP ${response?.status() ?? 'no response'}`);
  }
  await page.locator('#arcane-root').waitFor({ state: 'visible' });
  await page.waitForFunction(() => (
    document.documentElement.getAttribute('data-arcane-client-ready') === 'true'
  ));
  await page.waitForFunction(() => Boolean(
    document.querySelector(
      '[data-kb-style-slot].kb-style-slot-active:not([hidden]), '
        + '[data-kb-style-slot]:not([hidden])',
    ),
  ));
  await page.waitForFunction(() => {
    const input = document.querySelector(
      '[data-kb-style-slot]:not([hidden]) [data-kb-search-input]',
    );
    const toggle = document.querySelector(
      '[data-kb-style-slot]:not([hidden]) [data-kb-sidebar-toggle]',
    );
    return input?.getAttribute('data-kb-search-initialized') === 'true'
      && toggle?.getAttribute('data-kb-sidebar-toggle-init') === 'true';
  });
  await page.evaluate(() => document.fonts.ready);
}

async function verifyDeploymentAssets(page) {
  await loadRoute(page, '/');
  const expectedBasePath = `${new URL(baseUrl).pathname.replace(/\/+$/, '')}/`;
  const result = await page.evaluate(async () => {
    const cssText = [...document.querySelectorAll('style')]
      .map((element) => element.textContent || '')
      .join('\n');
    const fontUrls = [...new Set(
      [...cssText.matchAll(/url\(\s*['"]?([^)'"\s]*fonts\/lucide\/[^)'"\s]+)['"]?\s*\)/gi)]
        .map((match) => new URL(match[1], document.baseURI).href),
    )];
    const clientUrl = new URL('main.client.dart.js', document.baseURI).href;
    const responses = await Promise.all(
      [clientUrl, ...fontUrls].map(async (url) => {
        const response = await fetch(url);
        return { url, status: response.status };
      }),
    );
    return {
      basePath: new URL(document.baseURI).pathname,
      bodyFont: getComputedStyle(document.querySelector('#arcane-root')).fontFamily,
      codeFont: getComputedStyle(document.querySelector('#arcane-root'))
        .getPropertyValue('--font-mono'),
      clientReady:
        document.documentElement.getAttribute('data-arcane-client-ready'),
      fontUrls,
      responses,
    };
  });

  if (result.basePath !== expectedBasePath) {
    failures.push(
      `deployment base is ${result.basePath}; expected ${expectedBasePath}`,
    );
  }
  if (!/sans-serif|system-ui/.test(result.bodyFont)) {
    failures.push(`body font has no system fallback: ${result.bodyFont}`);
  }
  if (!/monospace/.test(result.codeFont)) {
    failures.push(`code font has no monospace fallback: ${result.codeFont}`);
  }
  if (result.clientReady !== 'true') {
    failures.push('compiled client did not publish its hydration marker');
  }
  const expectedFontPath = `${expectedBasePath}assets/fonts/lucide/lucide.woff2`;
  if (result.fontUrls.length !== 1
      || new URL(result.fontUrls[0]).pathname !== expectedFontPath) {
    failures.push(
      `Lucide font sources are not canonical: ${result.fontUrls.join(', ')}`,
    );
  }
  for (const response of result.responses) {
    if (response.status !== 200) {
      failures.push(`${response.url} returned HTTP ${response.status}`);
    }
  }
}

async function designPolicyViolations(page) {
  return page.evaluate(() => {
    const root = document.querySelector('#arcane-root');
    const scope = document.querySelector(
      '[data-kb-style-slot].kb-style-slot-active:not([hidden]), '
        + '[data-kb-style-slot]:not([hidden])',
    );
    if (!root) return ['page is missing #arcane-root'];
    if (!scope) return ['page has no active knowledge-base style slot'];

    const surfaceSelector = [
      '[data-arcane-surface]',
      '[data-surface]',
      '.kb-accordion',
      '.kb-article-panel',
      '.kb-badge',
      '.kb-banner',
      '.kb-callout',
      '.kb-card',
      '.kb-changelog',
      '.kb-code-group',
      '.kb-color-item',
      '.kb-endpoint',
      '.kb-expandable',
      '.kb-field',
      '.kb-frame',
      '.kb-missing-demo',
      '.kb-panel',
      '.kb-rating',
      '.kb-related-row',
      '.kb-resource',
      '.kb-step',
      '.kb-subpage-row',
      '.kb-tag',
      '.kb-tile',
      '.kb-update',
      '.kb-view',
      '.markdown-alert',
    ].join(',');
    const controlSelector = [
      'a',
      'button',
      'input',
      'select',
      'summary',
      'textarea',
      '[role="button"]',
      '[role="tab"]',
    ].join(',');
    const surfaces = [...scope.querySelectorAll(surfaceSelector)];
    const controls = [...scope.querySelectorAll(controlSelector)];
    const targets = [...new Set([
      ...surfaces,
      ...controls,
      ...scope.querySelectorAll('.kb-sidebar, .search-results'),
    ])];
    const compactIconTargets = [...new Set([
      ...scope.querySelectorAll('button, [role="button"]'),
      ...scope.querySelectorAll('.kb-badge, .kb-tag'),
    ])];
    const violations = [];

    const label = (element) => {
      const rawClassName = typeof element.className === 'string'
        ? element.className
        : element.className?.baseVal ?? '';
      const className = rawClassName.trim().replace(/\s+/g, '.');
      return `${element.tagName.toLowerCase()}${className ? `.${className}` : ''}`;
    };
    const radius = (style) => Math.max(
      Number.parseFloat(style.borderTopLeftRadius) || 0,
      Number.parseFloat(style.borderTopRightRadius) || 0,
      Number.parseFloat(style.borderBottomRightRadius) || 0,
      Number.parseFloat(style.borderBottomLeftRadius) || 0,
    );
    const transparent = (color) => [
      '',
      'transparent',
      'rgba(0, 0, 0, 0)',
      'rgba(0,0,0,0)',
    ].includes(color);
    const framed = (style) => [
      ['borderTopWidth', 'borderTopStyle', 'borderTopColor'],
      ['borderRightWidth', 'borderRightStyle', 'borderRightColor'],
      ['borderBottomWidth', 'borderBottomStyle', 'borderBottomColor'],
      ['borderLeftWidth', 'borderLeftStyle', 'borderLeftColor'],
    ].some(([width, borderStyle, color]) => (
      Number.parseFloat(style[width]) > 0
        && style[borderStyle] !== 'none'
        && !transparent(style[color])
    ));
    const visible = (element) => {
      const style = getComputedStyle(element);
      const rect = element.getBoundingClientRect();
      return style.display !== 'none'
        && style.visibility !== 'hidden'
        && Number.parseFloat(style.opacity || '1') > 0
        && rect.width > 0
        && rect.height > 0;
    };

    for (const element of targets) {
      const style = getComputedStyle(element);
      const rect = element.getBoundingClientRect();
      const elementRadius = radius(style);
      const name = label(element);
      const isCircle = rect.width > 0
        && Math.abs(rect.width - rect.height) < 1
        && elementRadius >= (rect.height / 2) - 1;

      if (!isCircle && rect.height > 0 && rect.width > rect.height * 1.25
          && elementRadius >= (rect.height / 2) - 1) {
        violations.push(`${name}: pill radius`);
      }
      const radiusLimit = controls.includes(element) ? 6 : 8;
      if (!isCircle && elementRadius > radiusLimit) {
        violations.push(`${name}: radius exceeds ${radiusLimit}px`);
      }
      if (style.backgroundImage !== 'none') {
        violations.push(`${name}: decorative background image or gradient`);
      }
      const backdropFilter = style.backdropFilter
        || style.webkitBackdropFilter
        || 'none';
      if (backdropFilter !== 'none') {
        violations.push(`${name}: backdrop blur or filter`);
      }
      if (style.filter !== 'none') {
        violations.push(`${name}: decorative filter or glow`);
      }
      if (style.boxShadow !== 'none' || style.textShadow !== 'none') {
        violations.push(`${name}: decorative shadow or glow`);
      }

      if (!isCircle && elementRadius > 0) {
        const sides = [
          `${style.borderTopWidth}|${style.borderTopStyle}|${style.borderTopColor}`,
          `${style.borderRightWidth}|${style.borderRightStyle}|${style.borderRightColor}`,
          `${style.borderBottomWidth}|${style.borderBottomStyle}|${style.borderBottomColor}`,
          `${style.borderLeftWidth}|${style.borderLeftStyle}|${style.borderLeftColor}`,
        ];
        if (new Set(sides).size > 1) {
          violations.push(`${name}: directional border on rounded element`);
        }
      }
    }

    for (const surface of surfaces) {
      if (!framed(getComputedStyle(surface))) continue;
      let parent = surface.parentElement?.closest(surfaceSelector);
      while (parent && scope.contains(parent)) {
        if (framed(getComputedStyle(parent))) {
          violations.push(`${label(surface)}: framed inside ${label(parent)}`);
          break;
        }
        parent = parent.parentElement?.closest(surfaceSelector);
      }
    }

    for (const element of compactIconTargets) {
      const visibleIcons = [...element.querySelectorAll('i, svg, img')]
        .filter(visible);
      if (visibleIcons.length > 1) {
        violations.push(`${label(element)}: more than one semantic icon`);
      }
    }

    for (const element of targets) {
      if (radius(getComputedStyle(element)) === 0) continue;
      for (const pseudo of ['::before', '::after']) {
        const style = getComputedStyle(element, pseudo);
        const hasGeometry = style.display !== 'none'
          && style.visibility !== 'hidden'
          && ((Number.parseFloat(style.width) || 0) > 0
            || (Number.parseFloat(style.height) || 0) > 0);
        const hasContent = !['none', 'normal', '', '""'].includes(style.content);
        const borderPaint = [
          ['borderTopWidth', 'borderTopColor'],
          ['borderRightWidth', 'borderRightColor'],
          ['borderBottomWidth', 'borderBottomColor'],
          ['borderLeftWidth', 'borderLeftColor'],
        ].some(([width, color]) => (
          Number.parseFloat(style[width]) > 0 && !transparent(style[color])
        ));
        const hasPaint = style.backgroundImage !== 'none'
          || !transparent(style.backgroundColor)
          || style.boxShadow !== 'none'
          || style.filter !== 'none'
          || style.borderImageSource !== 'none'
          || style.maskImage !== 'none'
          || style.webkitMaskImage !== 'none'
          || borderPaint;
        if ((hasGeometry || hasContent) && hasPaint) {
          violations.push(`${label(element)}: painted ${pseudo} one-sided accent`);
        }
      }
    }

    const bodyFont = getComputedStyle(root).fontFamily;
    if (!bodyFont.includes('Akzidenz-GroteskPro')) {
      violations.push(`body does not use the approved local font: ${bodyFont}`);
    }
    const heading = scope.querySelector('h1, h2');
    const headingFont = heading ? getComputedStyle(heading).fontFamily : '';
    if (heading && !['Akzidenz-GroteskPro', 'ITCAvantGardeStd'].some(
      (family) => headingFont.includes(family),
    )) {
      violations.push(`heading does not use the approved local font: ${headingFont}`);
    }
    const code = scope.querySelector('pre code, code');
    const codeFont = code ? getComputedStyle(code).fontFamily : '';
    if (code && !codeFont.includes('Hack')) {
      violations.push(`code does not use the approved local font: ${codeFont}`);
    }

    for (const link of document.querySelectorAll('link[rel="stylesheet"]')) {
      const href = link.getAttribute('href') || '';
      if (/^https?:\/\//i.test(href)) {
        violations.push(`remote stylesheet or font: ${href}`);
      }
    }
    const remoteFontFace = /@font-face\s*\{[\s\S]*?url\(\s*['"]?https?:\/\//gi;
    const remoteImport = /@import\s+(?:url\()?\s*['"]?https?:\/\//gi;
    for (const styleElement of document.querySelectorAll('style')) {
      const cssText = styleElement.textContent || '';
      if (remoteFontFace.test(cssText) || remoteImport.test(cssText)) {
        violations.push('inline CSS loads a remote font or stylesheet');
      }
      remoteFontFace.lastIndex = 0;
      remoteImport.lastIndex = 0;
    }

    for (const input of scope.querySelectorAll('[data-kb-search-input]')) {
      const search = input.closest('[data-kb-search]');
      const results = search?.querySelector('[data-kb-search-results]');
      if (input.getAttribute('role') !== 'combobox') {
        violations.push(`${label(input)}: search input is not a combobox`);
      }
      if (!input.getAttribute('aria-label')) {
        violations.push(`${label(input)}: search input has no accessible label`);
      }
      if (!['true', 'false'].includes(input.getAttribute('aria-expanded'))) {
        violations.push(`${label(input)}: search input has no expanded state`);
      }
      if (!results || results.getAttribute('role') !== 'listbox') {
        violations.push(`${label(input)}: search results are not a listbox`);
      } else if (!results.id || input.getAttribute('aria-controls') !== results.id) {
        violations.push(`${label(input)}: search input does not control its results`);
      }
    }

    for (const toggle of scope.querySelectorAll('[data-kb-sidebar-toggle]')) {
      const sidebar = scope.querySelector('.kb-sidebar');
      if (!toggle.getAttribute('aria-label')) {
        violations.push(`${label(toggle)}: sidebar toggle has no accessible label`);
      }
      if (!['true', 'false'].includes(toggle.getAttribute('aria-expanded'))) {
        violations.push(`${label(toggle)}: sidebar toggle has no expanded state`);
      }
      if (!sidebar?.id || toggle.getAttribute('aria-controls') !== sidebar.id) {
        violations.push(`${label(toggle)}: sidebar toggle does not control its drawer`);
      } else if ((toggle.getAttribute('aria-expanded') === 'true')
          !== sidebar.classList.contains('open')) {
        violations.push(`${label(toggle)}: sidebar expanded state is out of sync`);
      }
    }

    for (const toggle of scope.querySelectorAll('[data-kb-theme-toggle]')) {
      if (!toggle.getAttribute('aria-label')) {
        violations.push(`${label(toggle)}: theme toggle has no accessible label`);
      }
    }

    if (matchMedia('(max-width: 900px)').matches) {
      for (const sidebar of scope.querySelectorAll('.kb-sidebar:not(.open)')) {
        if (!sidebar.hasAttribute('inert')
            || sidebar.getAttribute('aria-hidden') !== 'true') {
          violations.push(`${label(sidebar)}: closed sidebar remains interactive`);
        }
      }
    }

    return [...new Set(violations)];
  });
}

async function assertDesignPolicy(page, context) {
  const violations = await designPolicyViolations(page);
  for (const violation of violations) failures.push(`${context}: ${violation}`);
  return violations;
}

async function exerciseInteractiveStates(page, viewport) {
  await loadRoute(page, '/');
  await assertDesignPolicy(page, `${viewport.width}px default state`);

  const activeSlot = page.locator(activeSlotSelector).first();
  const sidebarToggle = activeSlot.locator('[data-kb-sidebar-toggle]').first();
  const sidebar = activeSlot.locator('.kb-sidebar').first();
  if (!await sidebarToggle.count() || !await sidebar.count()) {
    failures.push(`${viewport.width}px sidebar controls are missing`);
  } else {
    if (viewport.width <= 900) {
      await sidebarToggle.evaluate((element) => element.click());
      await page.waitForFunction(() => {
        const slot = document.querySelector('[data-kb-style-slot]:not([hidden])');
        return slot?.querySelector('[data-kb-sidebar-toggle]')
          ?.getAttribute('aria-expanded') === 'true'
          && slot.querySelector('.kb-sidebar')?.classList.contains('open');
      });
      await assertDesignPolicy(page, `${viewport.width}px sidebar open`);
    } else {
      const desktopSidebarState = await sidebar.evaluate((element) => ({
        ariaHidden: element.getAttribute('aria-hidden'),
        inert: element.hasAttribute('inert'),
        visible: element.getBoundingClientRect().width > 0,
      }));
      if (!desktopSidebarState.visible
          || desktopSidebarState.inert
          || desktopSidebarState.ariaHidden === 'true') {
        failures.push(`${viewport.width}px desktop sidebar is not available`);
      }
      await assertDesignPolicy(page, `${viewport.width}px desktop sidebar`);
    }

    const searchInput = activeSlot.locator('[data-kb-search-input]:visible').first();
    if (!await searchInput.count()) {
      failures.push(`${viewport.width}px visible search control is missing`);
    } else {
      await searchInput.fill('navigation');
      const searchResults = activeSlot
        .locator('[data-kb-search-results]:visible')
        .first();
      try {
        await searchResults.waitFor({ state: 'visible', timeout: 5_000 });
        await assertDesignPolicy(page, `${viewport.width}px search open`);
        await searchInput.press('Escape');
        await searchResults.waitFor({ state: 'hidden', timeout: 5_000 });
        await assertDesignPolicy(page, `${viewport.width}px search closed`);
      } catch (error) {
        failures.push(`${viewport.width}px search state: ${error.message}`);
      }
    }

    if (viewport.width <= 900) {
      await sidebarToggle.evaluate((element) => element.click());
      await page.waitForFunction(() => {
        const slot = document.querySelector('[data-kb-style-slot]:not([hidden])');
        return slot?.querySelector('[data-kb-sidebar-toggle]')
          ?.getAttribute('aria-expanded') === 'false'
          && !slot.querySelector('.kb-sidebar')?.classList.contains('open');
      });
      await assertDesignPolicy(page, `${viewport.width}px sidebar closed`);
    }
  }

  const themeToggle = activeSlot.locator('[data-kb-theme-toggle]').first();
  if (!await themeToggle.count()) {
    failures.push(`${viewport.width}px theme toggle is missing`);
  } else {
    const initialDark = await page.locator('#arcane-root').evaluate(
      (element) => element.classList.contains('dark'),
    );
    await themeToggle.evaluate((element) => element.click());
    await page.waitForFunction(
      (wasDark) => document.querySelector('#arcane-root')
        ?.classList.contains('dark') !== wasDark,
      initialDark,
    );
    await assertDesignPolicy(page, `${viewport.width}px alternate theme`);
    await themeToggle.evaluate((element) => element.click());
    await page.waitForFunction(
      (wasDark) => document.querySelector('#arcane-root')
        ?.classList.contains('dark') === wasDark,
      initialDark,
    );
    await assertDesignPolicy(page, `${viewport.width}px restored theme`);
  }

  await loadRoute(page, '/features/rich-markdown');
  const disclosure = page
    .locator(activeSlotSelector)
    .first()
    .locator('details.kb-accordion')
    .first();
  if (!await disclosure.count()) {
    failures.push(`${viewport.width}px disclosure example is missing`);
  } else {
    await disclosure.evaluate((element) => element.removeAttribute('open'));
    await assertDesignPolicy(page, `${viewport.width}px disclosure closed`);
    await disclosure.locator(':scope > summary').click();
    if (!await disclosure.evaluate((element) => element.open)) {
      failures.push(`${viewport.width}px disclosure did not open`);
    }
    await assertDesignPolicy(page, `${viewport.width}px disclosure open`);
    await disclosure.locator(':scope > summary').click();
    if (await disclosure.evaluate((element) => element.open)) {
      failures.push(`${viewport.width}px disclosure did not close`);
    }
    await assertDesignPolicy(page, `${viewport.width}px disclosure reclosed`);
  }
}

async function runMutationSelfTests(page) {
  await loadRoute(page, '/');
  const cleanViolations = await designPolicyViolations(page);
  if (cleanViolations.length) {
    failures.push(`mutation baseline is not clean: ${cleanViolations.join('; ')}`);
    return;
  }

  await page.evaluate(() => {
    const scope = document.querySelector('[data-kb-style-slot]:not([hidden])');
    if (!scope) return;

    const pill = document.createElement('button');
    pill.className = 'policy-mutation-pill';
    pill.textContent = 'Forbidden pill';
    pill.style.cssText = 'width:180px;height:32px;border-radius:999px';
    scope.append(pill);

    const effects = document.createElement('div');
    effects.setAttribute('data-arcane-surface', 'effects');
    effects.textContent = 'Forbidden effects';
    effects.style.cssText = [
      'width:180px',
      'height:48px',
      'background-image:linear-gradient(red, blue)',
      'backdrop-filter:blur(4px)',
      'box-shadow:0 0 12px lime',
    ].join(';');
    scope.append(effects);

    const accent = document.createElement('div');
    accent.className = 'policy-mutation-accent';
    accent.setAttribute('data-arcane-surface', 'accent');
    accent.textContent = 'Forbidden accent';
    accent.style.cssText = 'position:relative;border:1px solid gray;border-radius:6px';
    scope.append(accent);
    const accentStyle = document.createElement('style');
    accentStyle.textContent = `
      .policy-mutation-accent::before {
        content: '';
        position: absolute;
        top: 0;
        left: 4px;
        width: 48px;
        height: 0;
        border-top: 3px solid lime;
      }
    `;
    document.head.append(accentStyle);

    const outer = document.createElement('div');
    outer.setAttribute('data-arcane-surface', 'outer');
    outer.style.cssText = 'padding:8px';
    outer.style.setProperty('border', '1px solid gray', 'important');
    const inner = document.createElement('div');
    inner.setAttribute('data-arcane-surface', 'inner');
    inner.style.setProperty('border', '1px solid gray', 'important');
    inner.textContent = 'Forbidden nested frame';
    outer.append(inner);
    scope.append(outer);

    const remoteLink = document.createElement('link');
    remoteLink.rel = 'stylesheet';
    remoteLink.href = 'https://fonts.example.invalid/forbidden.css';
    remoteLink.disabled = true;
    document.head.append(remoteLink);
    const remoteFont = document.createElement('style');
    remoteFont.textContent = `
      @font-face {
        font-family: 'Forbidden Remote';
        src: url('https://fonts.example.invalid/forbidden.woff2');
      }
    `;
    document.head.append(remoteFont);

    const iconControl = document.createElement('button');
    iconControl.className = 'policy-mutation-icons';
    iconControl.setAttribute('aria-label', 'Forbidden multi-icon control');
    for (let index = 0; index < 2; index += 1) {
      const icon = document.createElement('i');
      icon.textContent = String(index + 1);
      icon.style.cssText = 'display:inline-block;width:16px;height:16px';
      iconControl.append(icon);
    }
    scope.append(iconControl);
  });

  const mutationViolations = await designPolicyViolations(page);
  const mutationText = mutationViolations.join('\n');
  const expectedDiagnostics = [
    'pill radius',
    'decorative background image or gradient',
    'backdrop blur or filter',
    'decorative shadow or glow',
    'painted ::before one-sided accent',
    'framed inside',
    'remote stylesheet or font',
    'inline CSS loads a remote font or stylesheet',
    'more than one semantic icon',
  ];
  for (const expected of expectedDiagnostics) {
    if (!mutationText.includes(expected)) {
      failures.push(`mutation self-test did not reject: ${expected}`);
    }
  }
}

const browser = await chromium.launch({ headless: true });
try {
  const deploymentPage = await browser.newPage({
    viewport: { width: 1440, height: 1000 },
  });
  try {
    await verifyDeploymentAssets(deploymentPage);
  } catch (error) {
    failures.push(`deployment assets: ${error.message}`);
  }
  await deploymentPage.close();

  for (const viewport of viewports) {
    const page = await browser.newPage({ viewport });
    for (const route of routes) {
      try {
        await loadRoute(page, route);
        await assertDesignPolicy(page, `${viewport.width}px ${route}`);
      } catch (error) {
        failures.push(`${viewport.width}px ${route}: ${error.message}`);
      }
    }
    try {
      await exerciseInteractiveStates(page, viewport);
    } catch (error) {
      failures.push(`${viewport.width}px interactive states: ${error.message}`);
    }
    await page.close();
  }

  const mutationPage = await browser.newPage({
    viewport: { width: 1440, height: 1000 },
  });
  try {
    await runMutationSelfTests(mutationPage);
  } catch (error) {
    failures.push(`mutation self-tests: ${error.message}`);
  }
  await mutationPage.close();
} finally {
  await browser.close();
}

if (failures.length) {
  console.error(`Arcane Lexicon browser design policy failed:\n${failures.join('\n')}`);
  process.exitCode = 1;
} else {
  console.log(
    `Arcane Lexicon browser design policy passed: ${routes.length} routes at `
      + `${viewports.map(({ width }) => width).join('/')}px, interactive states, `
      + 'and mutation self-tests.',
  );
}
