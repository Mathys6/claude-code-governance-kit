---
name: verify-frontend-change
description: Use when a change touches a web UI (layout, dialog, map or chart container, page redesign, form) BEFORE declaring it complete, committing, or opening a pull request. Layout bugs are invisible to type checks and unit tests; only a real browser catches them.
---

# No UI change is done until it is verified in a real browser

Edits plus a green type check prove the code compiles, not that the screen works. The classic misses: a container rendered at zero width, a dialog footer pushed out of view by long content, a widget validated against a mock whose shape differs from the real API. When browser verification is skipped, each of these usually costs extra corrective pull requests.

## Tools

- **Preferred:** a browser automation MCP server (for example Playwright MCP) to navigate, click, read the console and take screenshots.
- **Fallback:** a headless screenshot script run from the shell.
- **Neither available:** say so explicitly and hand over a manual checklist. Never present the change as verified.

Prefer waiting on selectors over "network idle", which can hang on pages with long-lived connections.

## Checklist (all steps, in order)

1. **Start the dev server** and open the page that actually changed, not just the home page.
2. **Interact with the change**: click the buttons, submit the form, open the dialog, switch tabs. Screenshot before and after.
3. **Measure every added or modified container**: width **and** height via `getBoundingClientRect()`. A blank area is often a zero-width flex child, not a missing height.
4. **Dialogs and drawers**: scroll the whole body with long content; the footer and its buttons must stay visible and clickable.
5. **Responsive**: check at least one narrow viewport (about 375 px wide) and one desktop width.
6. **Browser console**: zero new errors or warnings.
7. **Real data**: if the page shows counts, aggregates or API-driven values, compare what is displayed with the real development backend, not only with test mocks.
8. **Design system**: compare with the project's reference page or component library; no one-off styles where a shared component exists.

If a step fails: fix, then **restart from step 1**. Never hand over partially verified work as complete.

## Diagnosis rule

Reproduce before fixing. Two consecutive "plausible" fixes without a reproduction means stop and reproduce first.

## Evidence

The final message lists the steps run, the screenshots taken and the console result. "Looks good" without that evidence does not count as verification (contract rule 7).
