---
name: bento-launch-video
description: Build a Bento product launch or feature demo video in HyperFrames in the house look: dark warm backdrop with a blurred orange glow top left and a blue glow bottom right, product UI rebuilt in macOS window chrome from the console's own tokens, a push cut between apps, a Bento mark close card, delivered as a 16:9 web cut and a 9:16 Reels and X cut from one set of scene files. Use for any Bento launch video, feature reveal, integration demo (Slack, Linear, GitHub, MCP), or when asked for a video "like the Slack demo".
---

# Bento launch video

The look and the pipeline that made the Slack integration launch (October 2026). Read this file, then `references/design-system.md` before writing any scene HTML. HyperFrames is the renderer; `/hyperframes-core` is the composition contract and still applies.

## The look in one paragraph

One backdrop across every scene: the console's near black (#0e0d0b) with a large, soft orange glow in the upper left (brand #ff8a3d at 16 percent) and a cooler blue glow in the lower right (#4da3ff at 10 percent), under a faint 80px grid. Product windows float on it in macOS chrome (traffic lights, slim title bar, 14px radius, deep shadow). Each app is rebuilt in HTML from its real tokens, never a screenshot: Slack in its dark theme with Lato, the Bento console from `apps/web/src/styles.css` with Inter standing in for Geist. Motion is quiet and product true: typing with a real caret, elements that pop in with `power3.out`, one slow push toward the thing that matters, a push cut between apps, a crossfade into the mark. No music, no narration, no em dashes.

## Deliverables

Always two cuts from the same scene files:

| Cut | Canvas | For | Project |
| --- | --- | --- | --- |
| Wide | 1920x1080 | web, YouTube, embeds | `<name>/` |
| Tall | 1080x1920 | Instagram Reels, X | `<name>-vertical/` |

Two sibling projects, because HyperFrames lint refuses two root compositions in one project and the runtime stamps a scene root's `data-width/height` as pixels. Scenes live once in the wide project and read a `layout` variable (`wide` or `tall`); `sync-vertical.sh` mirrors them into the sibling and rewrites the roots to 1080x1920. Edit only in the wide project, sync, then check and render in both.

## Workflow

1. **Scaffold** with `scripts/new-project.sh <name>` (creates both projects under `~/projects/bento-launch-videos/` from `templates/`). It copies the proven Slack, Bento console, and close scenes; rename and rewrite them for the new story rather than starting blank.
2. **Write the story** in `BRIEF.md` and `STORYBOARD.md`: two or three scenes, 20 to 25 seconds. Pattern: the trigger surface (Slack, Linear, a PR) → the Bento app showing the card and the agent at work → the mark. Keep copy product true: lift reply text and labels from the server and console source, not from memory. `references/scene-recipes.md` lists the real strings used so far.
3. **Build scenes** following `references/design-system.md` (tokens, chrome, type, motion) and `references/scene-recipes.md` (layouts, timings, zoom math, the Slack and console mockups).
4. **Verify**: `npx hyperframes lint`, then `npx hyperframes check` in both projects, then `npx hyperframes snapshot --at <beats>` and read the contact sheet. `references/pipeline-gotchas.md` has the fixes for every finding met so far; apply them before you hunt.
5. **Render** both: `npx hyperframes render --quality looks --output renders/<name>-16x9.mp4` and the 9x16 sibling. Verify with ffprobe and tile a few frames with ffmpeg; the render can differ from Studio.
6. **Deliver** to iCloud `bento/<folder>/` through Finder AppleScript (the shell cannot write iCloud): stage in /tmp, `duplicate ... with replacing`, then list names and dates to confirm. Replace in place when asked for a new version; never leave two versions.

## Rules that are not negotiable

- No em dashes, en dashes, or hyphen as a pause anywhere on screen. Separate sentences or commas.
- Never use Daniel's real name on screen. The Slack user is a stand in (Jordan Reyes, initials JR, avatar #a04f08).
- Fonts: only renderer bundled families (Lato for Slack, Inter for the console, JetBrains Mono for paths). Geist is not shipped.
- Everything is `fromTo` on one paused timeline; hidden until needed elements use `autoAlpha`, never `opacity` alone, or the layout audit flags them as hidden text.
- The backdrop lives inside the camera wrapper and bleeds 800px past the frame so a push never shows an edge.
- Decorative or intentionally clipped elements carry `data-layout-ignore`; a panel that legitimately covers UI (the drawer, a thread pane) gets `data-layout-allow-overflow`, and whatever it covers gets `data-layout-allow-occlusion`.

## References

- `references/design-system.md`: palette, backdrop CSS, window chrome, type scale, motion vocabulary, close card.
- `references/scene-recipes.md`: Slack mockup, Bento console mockup (board, card states, drawer with Chat pane), timing tables, camera math, tall reflow rules.
- `references/pipeline-gotchas.md`: every lint, check, render, and delivery problem hit so far and the fix.
- `templates/`: the finished Slack launch scene files, both hosts, the sync script, and `frame.md`.
