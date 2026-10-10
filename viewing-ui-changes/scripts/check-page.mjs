#!/usr/bin/env node
// Load a page with the current project's own Playwright, save a screenshot at
// each viewport width, and report console errors, page errors and failed
// requests. Installs nothing: Playwright must already be a dependency of the
// project in the current directory. If its browsers haven't been downloaded,
// falls back to the Google Chrome or Microsoft Edge already on the machine.
//
// Usage: node <skill>/scripts/check-page.mjs <url> [options]
//   --out <dir>        where screenshots go (default: a new temp directory)
//   --widths <list>    comma-separated viewport widths (default: 375,768,1280)
//   --dark             emulate prefers-color-scheme: dark
//   --full-page        capture the whole page, not just the viewport
//   --wait-for <css>   wait for this selector before capturing
//
// Exit codes: 0 page loaded with no errors, 1 page loaded with errors,
//             2 could not run (bad arguments, no Playwright, no browser).
import { createRequire } from 'node:module';
import { mkdtempSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

function fail(message) {
  console.error(`✗ ${message}`);
  process.exit(2);
}

const args = process.argv.slice(2);
const opts = { widths: [375, 768, 1280], dark: false, fullPage: false };
let url;
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  const value = () => args[++i] ?? fail(`${arg} needs a value`);
  if (arg === '--out') opts.out = resolve(value());
  else if (arg === '--widths') opts.widths = value().split(',').map(Number);
  else if (arg === '--dark') opts.dark = true;
  else if (arg === '--full-page') opts.fullPage = true;
  else if (arg === '--wait-for') opts.waitFor = value();
  else if (arg.startsWith('--')) fail(`unknown option ${arg}`);
  else url = arg;
}
if (!url) fail('usage: check-page.mjs <url> [--out dir] [--widths 375,768,1280] [--dark] [--full-page] [--wait-for css]');
if (opts.widths.some((w) => !Number.isInteger(w) || w < 200)) fail('--widths must be whole numbers of at least 200');

// Resolve Playwright from the project, not from where this script lives.
const projectRequire = createRequire(join(process.cwd(), 'package.json'));
let chromium;
for (const pkg of ['playwright', '@playwright/test', 'playwright-core']) {
  try {
    ({ chromium } = projectRequire(pkg));
    break;
  } catch {}
}
if (!chromium) {
  fail('Playwright is not installed in this project (looked for playwright, @playwright/test, playwright-core). ' +
    'Run this from the project root, or ask the user before installing anything.');
}

let browser;
const launchErrors = [];
for (const channel of [undefined, 'chrome', 'msedge']) {
  try {
    browser = await chromium.launch(channel ? { channel } : {});
    if (channel) console.log(`(using installed ${channel}: Playwright's own browser isn't downloaded)`);
    break;
  } catch (err) {
    launchErrors.push(`${channel ?? 'playwright chromium'}: ${err.message.split('\n')[0]}`);
  }
}
if (!browser) fail(`no browser could be started:\n  ${launchErrors.join('\n  ')}`);

const outDir = opts.out ?? mkdtempSync(join(tmpdir(), 'ui-check-'));
mkdirSync(outDir, { recursive: true });

let problems = 0;
try {
  for (const width of opts.widths) {
    const page = await browser.newPage({
      viewport: { width, height: width < 768 ? 812 : 900 },
      colorScheme: opts.dark ? 'dark' : 'light',
    });
    const issues = [];
    page.on('console', (msg) => {
      // "Failed to load resource" repeats an HTTP error below, without the URL.
      if (msg.text().startsWith('Failed to load resource')) return;
      if (msg.type() === 'error' || msg.type() === 'warning') issues.push(`console ${msg.type()}: ${msg.text()}`);
    });
    page.on('pageerror', (err) => issues.push(`page error: ${err.message}`));
    page.on('requestfailed', (req) => issues.push(`request failed: ${req.url()} (${req.failure()?.errorText})`));
    page.on('response', (res) => {
      // Browsers ask for /favicon.ico on their own; a missing one isn't the page's fault.
      if (res.status() >= 400 && new URL(res.url()).pathname !== '/favicon.ico') {
        issues.push(`HTTP ${res.status()}: ${res.url()}`);
      }
    });

    let response;
    try {
      response = await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
      if (opts.waitFor) await page.waitForSelector(opts.waitFor, { timeout: 10000 });
    } catch (err) {
      issues.push(`load failed: ${err.message.split('\n')[0]}`);
    }

    const file = join(outDir, `${width}${opts.dark ? '-dark' : ''}.png`);
    await page.screenshot({ path: file, fullPage: opts.fullPage }).catch(() => {});
    const overflow = await page
      .evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth)
      .catch(() => 0);
    if (overflow > 0) issues.push(`horizontal overflow: page is ${overflow}px wider than the viewport`);

    const errors = issues.filter((i) => !i.startsWith('console warning'));
    problems += errors.length;
    console.log(`\n${width}px  ${response ? `HTTP ${response.status()}` : 'no response'}  ${await page.title().catch(() => '')}`);
    console.log(`  screenshot: ${file}`);
    for (const issue of issues) console.log(`  ${issue.startsWith('console warning') ? '!' : '✗'} ${issue}`);
    if (issues.length === 0) console.log('  ✓ no errors');
    await page.close();
  }
} finally {
  await browser.close();
}

console.log(`\n${problems === 0 ? '✓ no errors found' : `✗ ${problems} error(s) found`}; screenshots in ${outDir}`);
process.exit(problems === 0 ? 0 : 1);
