# Design spec: Bento Slack integration launch

One backdrop across every scene: Bento's console background (#0e0d0b) with a soft brand glow (#ff8a3d at low alpha) upper left and a cool counter glow (#4da3ff) lower right. Two product windows sit on it, each in macOS chrome.

## Scene 1, Slack (dark theme, product true)
- Main pane #1a1d21, sidebar #19171d, hairlines #35373b, text #d1d2d3, dim text #ababad, link and mention #1d9bd1, mention pill bg rgba(29,155,209,0.16), active channel #1164a3, send button #007a5a.
- Type: Lato 400 and 700 (bundled). Message name 15px/700, body 15px/400, sidebar 15px.

## Scene 2, Bento Mac app (console tokens from styles.css)
- bg #0e0d0b, panel #161411, panel raised #1d1b17, line #2a2722, line bright #3d392f, text #ededed, text dim #a8a49b, text faint #8b867c, brand #ff8a3d, running #4da3ff, succeeded #3fbf7f, idle #6d675c, radius 7px and 12px, lane width 300px.
- Type: Inter 400 and 700 (bundled, stands in for Geist, which is not shipped with the renderer).

## Scene 3, close
- Same backdrop. Bento mark (assets/logo.svg) plus "Bento" wordmark in Inter 900, one tagline in text dim.

## Copy
- No em dashes, no en dashes, no hyphen as a pause.
- Feature: "Dark mode for the settings page". Project: bento-www. Channel: #product. Workspace: Acme.
