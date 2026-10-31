---
name: viewing-ui-changes
description: Open the app in a browser to see a frontend change actually working before calling it done. Takes screenshots at phone, tablet and desktop widths and reports console errors, failed requests and horizontal overflow, using the project's own Playwright or the agent's built-in browser, without installing anything. Use after changing UI, styles, layout or components, or when asked to "check it in the browser", "take a screenshot", "see how it looks", "view the changes" or "make sure the page renders".
---

# Viewing UI changes

Tests and type checks don't show what a page looks like. After changing
anything a user can see, open the page, look at it, and fix what's wrong
before saying the work is done.

**Never install anything for this** (no global packages, no browser
downloads, no new dependencies) unless the user agrees first.

## 1. Get the app running

1. Check whether a dev server is already running for this project (look for
   one on the usual port, or ask the user). Reuse it if so.
2. Otherwise find the start command in `package.json` scripts (`dev`, `start`,
   `serve`) or the project's README, and start it in the background. Wait
   until it prints a local URL or the port answers.
3. Work out which URL shows the change: the route or page that was edited,
   not just the home page.

Remember whether you started the server, so you can stop it at the end.

## 2. Look at the page

Use the first option that's available:

**A. Your own browser tool.** If you have a built-in browser or browser tools,
open the URL there, take screenshots, and read the console. Check the same
things as the script below: phone, tablet and desktop widths, and errors.

**B. The bundled script, using the project's Playwright.** Run it from the
project root (it resolves Playwright from the current directory):

```bash
node <path-to-this-skill>/scripts/check-page.mjs http://localhost:3000/settings
```

Options: `--widths 375,768,1280` (default), `--dark` for dark mode,
`--full-page` for the whole page, `--wait-for "<css selector>"` for content
that loads late, `--out <dir>` to choose where screenshots go (default: a
new temp directory).

It works when the project has `playwright`, `@playwright/test` or
`playwright-core` installed. If Playwright's browsers haven't been
downloaded, it uses the Google Chrome or Microsoft Edge already on the
machine. It exits 0 with no errors, 1 when it found errors, and 2 when it
couldn't run.

**C. Neither works.** Stop and tell the user. Offer the choices instead of
picking one: they look at the page themselves, or they approve adding
Playwright as a dev dependency of the project.

## 3. Check what you see

Open every screenshot and look at it. Don't stop at the script's summary.

- **The change itself:** is it there, and does it match what was asked?
- **Layout:** nothing overlapping, cut off, or wider than the screen at any
  width; text readable; spacing consistent with the rest of the page.
- **Errors:** every console error, page error and failed request the script
  (or your browser tool) reported. Say which ones existed before your change
  if you can tell.
- **States:** if the change involves interaction (a menu, form, dialog),
  check the opened, filled or error state too, not only the first render.
  Add a Playwright test with the project's existing setup if the flow needs
  clicks to reach.
- **Dark mode:** rerun with `--dark` if the app supports it.

Fix what's wrong and look again. Only describe the change as done once the
screenshots show it working.

## 4. Clean up

- Stop any dev server you started; leave one the user started running.
- Keep screenshots out of the repo. Leave them in the temp directory unless
  the user asks for them somewhere else, and don't commit them.
- When reporting back, say which URL and widths you checked, list any errors
  that are left, and give the screenshot paths so the user can look too.
