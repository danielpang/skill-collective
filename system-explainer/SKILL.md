---
name: system-explainer
description: Build an animated, textbook style explainer page for a codebase or system (architecture diagram, how the core loop works, animated requests flowing through components, sequence diagrams, deployment/system design), modeled on twotimespi.dev, then publish it as a claude.ai Artifact and a Dropway site. Use when the user asks to "explain how X works" as a page or site, wants an architecture diagram or system design diagram with animations, wants "an explainer like the OpenBots one", or asks for an internals or onboarding page for a repo.
---

# System explainer

Produces a single page that reads like a short illustrated textbook about one system. The reference build is `references/example-openbots.html` (OpenBots internals, Nov 2026). Read it before writing anything: it holds the full CSS, the SVG vocabulary and the three reusable JS engines. Reuse that code; change the content.

## 1. Research the system (delegate)

Spawn one `Explore` agent ("very thorough") on the repo. Ask for concrete names with file paths, under ~1500 words:
- monorepo layout: apps, packages, runtimes, frameworks
- deployment topology: images, compose services, hosting (Fly, Vercel, etc.)
- the core loop: how a request enters, is queued, processed, and streamed back, with key function names
- each datastore: ORM, main tables, what is written when
- queues, pub/sub channels, locks, rate limits (exact queue/channel/key names)
- any sub-system the user named (e.g. how coding agents are spawned)
- auth, realtime transport, reconnection, other components

Correct the user's premise when the report contradicts it (e.g. channels that do not exist) and say so in the final reply. Never invent names: every queue, table, function and path on the page must come from the report or the code.

## 2. Page structure

Numbered chapters, each a short argument plus a captioned figure ("Fig. N. ..."). Default outline, adapt to the system:

0. Hero: a thesis headline about the system (OpenBots: "A Bot is a run in a queue."), one line lede, mono tag row, and a live "event ticker" panel showing realistic event names scrolling.
1. **The whole system**: architecture SVG with scenario buttons. Each scenario sends a red packet along real wire paths and lights the target node, with a numbered log beside it.
2. **The core loop**: "Definition N.1" callout, an "Algorithm 1" pseudocode block (small caps function names, bold keywords, right aligned comments), and a looping SVG with a dot circling.
3. **One request, start to finish**: animated sequence diagram (lanes = components), Play and Step buttons, numbered detail list below.
4. **What each store keeps**: two tables (e.g. Postgres tables and when written; Redis keys/channels and purpose) plus the one sentence rule that separates them.
5. **Sub-system the user asked about** (e.g. spawning coding agents): definition, prose, callout, second sequence diagram.
6. Edge paths (mobile, relay, reconnect ladder) if they exist.
7. **System design, as deployed**: static topology SVG with dashed `.flow` lines for long lived connections, plus a callout on images/hosting.
8. **Reading list**: table of files in reading order and what each shows.
Footer: "Drawn from the code on <branch>." and the month.

## 3. Look (from twotimespi.dev)

- Paper ground `#fbfaf6`, ink `#15171a`, one red pen accent `#c2402a`; dark theme tokens mirror it (`#141619` / `#e8e5dc` / `#e46a51`). Red is reserved for the packet, active state and section marks.
- STIX Two Text (serif body, italic for captions and diagram subtitles) + JetBrains Mono (code, labels). Google Fonts only.
- Sketchy diagrams: boxes get `filter="url(#rough)"` (feTurbulence + feDisplacementMap, scale ~2.6). Text is never filtered.
- Italic red section numbers, `Fig. N.` captions, definition callouts with a left red rule, mono uppercase eyebrows.
- Wide SVGs sit in `.scroll.wide` (min-width 760px) so phones scroll the figure, never the page.

## 4. Engines to reuse (copy from the example)

- `travel(layer, path, reverse, speed)`: animates a packet along any SVG path with `getPointAtLength`, returns a Promise. Respects reduced motion.
- **Scenario player** (`S` map + `play(k)`): each step is `[wireId, reverse, nodeId, logText]`. Wires are drawn once as `.wire` paths with ids; packets reuse them in either direction. Use a cancel token so clicking another scenario stops the current one.
- **`Seq(root, lanes, steps)`**: builds a sequence diagram from data. Steps are `[fromLane, toLane, shortLabel, detail]`; `from === to` draws a self loop. Autoplays once when scrolled into view.
- Loop figure: hidden `lp-in`, `lp-round`, `lp-out` paths travelled in sequence while a step counter updates.

Laying out Fig. 1: put the server as a dashed zone box, leave 10 to 15px lanes between inner boxes and the zone edge for vertical wires, and route every wire with right angles. Plan coordinates on paper (in thinking) before writing the SVG.

## 5. Rules

- Page complete at rest: logs and sequence arrows render fully before any animation; animation only replays them.
- Respect the user's copy rules (this user: no em or en dashes anywhere in page copy). Grep for `[—–]` before publishing.
- Syntax check the inline script: extract it and run `node --check`.
- One visual look only if the browser tool works; Playwright here may lack Chrome, so do not loop on it.

## 6. Publish

1. `Artifact` `action: "quickstart"`, `intent: "other"` first (required), then write the page **without** doctype/html/head/body tags (the Artifact skeleton adds them), with `<title>` and `<meta name="claude:viewport-fit-sides" content="cover">` at top. Publish with `icon: "diagram"` and a one sentence description.
2. Dropway: load `mcp__claude_ai_Dropway__create_site` and `deploy_site` via ToolSearch. `create_site` with a slug like `<project>-internals` (defaults to org_only access; mention that). Build a standalone copy: add `<!doctype html>`, `<html lang>`, `<head>` with charset and viewport meta, move `<title>`/fonts/`<style>` into head, add `html{padding:env(safe-area-inset-*)}` and `body{margin:0}` since there is no skeleton, and drop the `[data-theme]` blocks (keep the media query). `deploy_site` takes the file as `text`, so the full file goes in the call.
3. Reply with both links, a short map of which figure answers which request, and any premise corrections.
