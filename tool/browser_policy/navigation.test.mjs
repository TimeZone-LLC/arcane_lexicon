import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const projectRoot = fileURLToPath(new URL('../../', import.meta.url));
const temporary = await mkdtemp(join(tmpdir(), 'lexicon-navigation-'));
const exporter = join(temporary, 'scripts.dart');
await writeFile(exporter, `
import 'dart:io';
import 'package:arcane_lexicon/src/scripts/kb_scripts.dart';
void main() => stdout.write(const KBScripts().generate());
`);
const scripts = execFileSync('dart', [
  `--packages=${join(projectRoot, '.dart_tool/package_config.json')}`,
  exporter,
], { cwd: projectRoot, encoding: 'utf8' });

function documentFor(path) {
  const interactive = path === '/interactive';
  const content = interactive
    ? '<!--@counter--><button id="counter">0</button><!--/@counter-->'
    : `<h1>${path}</h1>`;
  return `<!doctype html><html><head><title>${path}</title></head><body>
    <div id="arcane-root" class="kb-page-shell"><main class="kb-main-area">
      <nav><a href="/static-a">Static A</a><a href="/static-b">Static B</a>
      <a href="/interactive">Interactive</a><a href="#details">Details</a></nav>
      ${content}<h2 id="details">Details</h2>
    </main></div>
    <script>window.documentToken = crypto.randomUUID();
      const counter = document.getElementById('counter');
      if (counter) counter.onclick = () => counter.textContent = Number(counter.textContent) + 1;
    </script><script>${scripts}</script></body></html>`;
}

const server = createServer((request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/html' });
  response.end(documentFor(new URL(request.url, 'http://localhost').pathname));
});
await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
const browser = await chromium.launch({
  executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE,
});
try {
  const page = await browser.newPage();
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  const base = `http://127.0.0.1:${server.address().port}`;
  const token = () => page.evaluate(() => window.documentToken);
  await page.goto(`${base}/interactive`);
  await page.evaluate(() => localStorage.setItem('arcane-theme-mode', 'light'));
  await page.locator('#counter').click();
  assert.equal(await page.locator('#counter').textContent(), '1');
  const interactiveToken = await token();
  await page.getByRole('link', { name: 'Details', exact: true }).click();
  assert.equal(await token(), interactiveToken);
  await page.locator('#counter').click();
  assert.equal(await page.locator('#counter').textContent(), '2');
  await page.goBack();
  await page.goForward();
  assert.equal(await token(), interactiveToken);
  await page.locator('#counter').click();
  assert.equal(await page.locator('#counter').textContent(), '3');

  await page.getByRole('link', { name: 'Static A', exact: true }).click();
  await page.getByRole('heading', { name: '/static-a', exact: true }).waitFor();
  assert.notEqual(await token(), interactiveToken, 'Leaving client islands must dispose their document');
  const staticToken = await token();
  await page.getByRole('link', { name: 'Static B', exact: true }).click();
  await page.getByRole('heading', { name: '/static-b', exact: true }).waitFor();
  assert.equal(await token(), staticToken, 'Static documents should retain soft navigation');
  await page.goBack();
  await page.getByRole('heading', { name: '/static-a', exact: true }).waitFor();
  await page.goForward();
  await page.getByRole('heading', { name: '/static-b', exact: true }).waitFor();

  await page.getByRole('link', { name: 'Interactive', exact: true }).click();
  await page.locator('#counter').waitFor();
  assert.notEqual(await token(), staticToken, 'Entering client islands must initialize their document');
  await page.locator('#counter').click();
  assert.equal(await page.locator('#counter').textContent(), '1');
  await page.goBack();
  await page.getByRole('heading', { name: '/static-b', exact: true }).waitFor();
  await page.goForward();
  await page.locator('#counter').waitFor();
  const previousCount = Number(await page.locator('#counter').textContent());
  await page.locator('#counter').click();
  assert.equal(Number(await page.locator('#counter').textContent()), previousCount + 1);
  assert.equal(await page.evaluate(() => localStorage.getItem('arcane-theme-mode')), 'light');
  assert.deepEqual(errors, []);
  console.log('Navigation runtime passed: client islands, static routes, hashes, history, and stored theme.');
} finally {
  await browser.close();
  await new Promise((resolve) => server.close(resolve));
  await rm(temporary, { recursive: true, force: true });
}
