# Scene recipes

The three scenes that shipped, with the decisions baked in. The template files under `templates/compositions/frames/` are the source of truth for markup; this file explains them so you can adapt rather than reread 50KB.

## Shared structure

Every scene is a sub composition: `<template>` with `<style>`, `#root` (position absolute, inset 0, overflow hidden), and `<script>`, all inside the template. The `<html>` element declares the `layout` variable:

```html
<html data-composition-variables='[{ "id": "layout", "type": "enum", "role": "content", "label": "Layout", "description": "wide for 16:9 hosts, tall for 9:16 hosts.", "default": "wide", "options": [{ "value": "wide", "label": "Wide" }, { "value": "tall", "label": "Tall" }] }]'>
```

The script reads it and stamps `data-layout` on `#root`; CSS branches on `#root[data-layout="tall"]`. Hosts pass `data-variable-values='{"layout":"tall"}'`.

Hosts: `index.html` (main, 1920x1080, 22.6s) mounts three clips with the push and crossfade tweens; `index-vertical.html` is the same with 1080x1920, `W = 1080`, and `layout: tall`. The sync script renames it to `index.html` in the sibling project.

## Scene 1: the trigger surface (Slack)

Window: title bar, Slack top bar (back and forward arrows, centered "Search Acme" pill), then body. Wide has a 260px sidebar (workspace "Acme", Threads, Mentions and reactions, Drafts and sent, Channels with #product active, Direct messages, Apps with Bento); tall hides it.

Main pane: channel header "# product" with star and member chip; message list bottom anchored above a composer; the list holds a channel intro ("# product", "Product updates and requests. Tag @bento to turn a request into a card."), a "Today" divider, two prior messages, and the user's message pre rendered but hidden.

Cast and copy (keep these, they were written to avoid dashes):

- Priya Nair 9:41 AM: "Settings page feedback from the beta: three people asked for dark mode this week."
- Marcus Lee 9:43 AM: "Agreed, it is the top request. Who is picking it up?"
- Jordan Reyes 9:44 AM: "@bento add dark mode to the settings page"
- Bento (APP badge) 9:44 AM, in the thread: "Created **Dark mode for the settings page** in **bento-www**." with an "Open card" button. This is the real reply from `apps/server/src/orchestrator/slack-notify.ts` (`Created *${title}* in *${project}*.` plus an Open card button). Later stage posts are "*Stage* finished." and "*Stage* needs review." if the story needs them.

Beats (T0 = 1.0s typing start, derived in script):

| Beat | When |
| --- | --- |
| window settles | 0.05 to 0.65 |
| autocomplete popup ("Members and apps matching @be", Bento APP row) | at the 2nd char, out just before the space after @bento |
| @bento converts to a mention pill | at the 7th char |
| Enter: composer clears, list shifts up, message fades in | T_SEND = last char + 0.55 |
| thread pane slides in from the right | T_SEND + 0.7 |
| Bento reply pops in; "1 reply" row appears under the message | T_THREAD + 0.8 |
| push toward the reply | T_REPLY + 0.7, 1.4s |

Thread pane: 440px wide in wide, full width in tall (it covers the channel; the channel header, list, and composer fade out under it so the audit does not see overlapping text). In wide the member chip fades out when the pane arrives.

Camera target: the reply block center. Wide S = 1.3, target y = window top + 44 + 48 + 56 + 212 + 110. Tall S = 1.1 (anything larger crops the sender's name).

## Scene 2: the Bento Mac app

Window: title bar "Bento", then the console nav (brand glyph and word, project pill "bento-www", centered tabs Board, Sessions, Settings with a brand underline, "New card" button, avatar JR). Board below with lanes 20px in from the edges.

Lanes are the real board: `.lane` panel with a head (ordinal badge, name, count), a sub row (agent name, then "Review before advancing" or "Advances automatically"), and cards. Default stage names from `packages/core/src/pipeline.ts`: Engineering requirements, Implementation, Code review. Agents: Staff Engineer, Software Engineer, Code Reviewer. Card state labels from `Board.tsx`: "agent working", "agent finished", "agent failed", "waiting for review", "idle".

Lane geometry: wide shows Backlog plus three stages at 250px with a 14px gap (so a 560px drawer from the right covers nothing); tall drops Backlog and shows three lanes at 300px with 16px gaps.

Cards: title, meta row (dot plus label), session row ("Staff Engineer · 1 run", date right aligned), and a `card-line` with the agent's latest words (ellipsized, marked `data-layout-ignore`).

The drawer is the real `FeatureDrawer`: fixed to the right, full height under the title bar, 560px wide, border left in line bright, shadow -24px 0 48px. Head: "FEATURE" kicker, status chip "Agent working" in running blue, close ×, the title at 20px, a stage block (stage name, "Stage 1 of 3", a five segment progress rail with the current segment in brand, agent row with provider mark, "Manual approval"). Tabs Overview, Changes, Chat (active), History. The Chat pane is the real `AgentSession` chat: a bordered box on bg with a centered run caption between hairlines ("Staff Engineer · just now · running"), a centered system note, assistant bubbles (panel raised, 12px radius, "Staff Engineer" meta at 10.5px 600), tool cards in mono ("▾ Read files  2 tool calls" with ▸ rows "Read apps/web/src/styles.css"), then a composer: input "Queue a message...", a Stop square in failed red, a brand Send button, and the hint "Sent while the agent works, so it reads this after its current step." The bottom sheet variant exists only on phone widths; never use it.

Transcript copy (streams in this order, 3.0, 3.7, 4.4, 5.0, 5.8, 6.9, 7.8s local):

1. system: Sandbox ready. Staff Engineer is on the card.
2. Reading the settings page and the theme tokens in styles.css.
3. tool: Read apps/web/src/styles.css
4. tool: Read apps/web/src/components/AppearanceSettings.tsx (the tool card count flips to "2 tool calls")
5. The console already ships light and dark palettes. The settings page needs a theme control, a per user preference, and a system default.
6. Writing the engineering requirements and the system design. (blue caret blinks until the next line)
7. tool: Write docs/dark-mode-settings.md

Card beats: pops into lane 1 at 1.0s (count 0 to 1), flips to "agent working" with the pulse and ring at 1.7s, drawer slides in at 2.3s, camera push at 4.9s (wide S 1.12 toward x+290; tall S 1.1 centered). The card's `card-line` mirrors lines 2, 5, and 6 as they arrive.

Description line under the tabs: "Created from Slack: acme.slack.com/archives/C04PRD/p1760694240", which is what the server writes into the card description.

## Scene 3: the mark

Backdrop, lockup, tagline, URL. 3 seconds. Nothing else.

## Adapting to another integration

Keep scene 2 and 3 as they are. Replace scene 1's surface: a Linear issue view, a GitHub PR comment, an MCP client. Rebuild it from that product's dark theme tokens the same way (title bar, real layout, real copy from the server's reply strings), keep the push toward the moment Bento answers, and keep the tall reflow rule: drop side navigation, let the answering panel take the full width, fade what it covers.
