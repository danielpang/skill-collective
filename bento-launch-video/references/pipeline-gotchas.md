# Pipeline gotchas

Every problem met while shipping the Slack launch, with the fix. Apply these up front.

## Project shape

- **Two root files in one project fail lint** (`multiple_root_compositions`). Keep the vertical host out of the root (`.hf-shared/index-vertical.html`) and mirror into a sibling project with `sync-vertical.sh`.
- **Scene roots are stamped at their own `data-width/height`.** A scene with `data-width="1920" data-height="1080"` renders as a 1920x1080 box even inside a 1080x1920 host, so the bottom 840px are clipped. The sync script rewrites the roots in the vertical copy. If you add a scene, keep the attribute pattern `data-width="1920" data-height="1080"` exactly so the sed matches.
- **Studio injects `data-hf-id` attributes** into your files when a preview or check opens them. Strip them before string replacing (`sed -i '' 's/ data-hf-id="[^"]*"//g'`), or your `replace()` anchors will not match.
- `npx hyperframes add <name>` takes one name per call and has no `--yes`; the registry's typewriter and device stage components were not worth using for these mockups.

## Lint and check findings

| Finding | Cause | Fix |
| --- | --- | --- |
| `duplicate_media_discovery_risk` | the same `<img src>` repeated (logo avatars) | CSS `background: url(...)` on a span instead of `<img>` |
| `text_occluded` on an off screen panel | thread pane or drawer parked outside the window with `opacity` only | park it with `autoAlpha: 0` and bring `autoAlpha` to 1 as it slides in |
| `text_occluded` on UI a panel covers | drawer over nav items and lanes, which is the real product | `data-layout-allow-overflow` on the panel; `data-layout-allow-occlusion` on every covered element (set it in script with `querySelectorAll`) |
| `content_overlap` with an autocomplete popup | popup over a message, as in Slack | `data-layout-ignore` on the popup |
| `content_overlap` avatar vs close glyph | drawer × over the nav avatar | `data-layout-ignore` on the × |
| `clipped_text` on ellipsized rows | `card-line`, description line | `data-layout-ignore` on those spans |
| `escaped_container` on the backdrop | the 800px bleed | `data-layout-ignore` on bg and grid |
| `contrast_aa_failure` in the Slack mock | Slack's real grays and white on bright avatars | use the corrected palette in design-system.md; avatars #5a3d9e, #1e7550, #a04f08 |
| `font_family_without_font_face` | Geist or any non bundled font | Lato, Inter, JetBrains Mono |
| `gsap_css_transform_conflict` | CSS transform plus GSAP x/y on one element | center with flex or absolute offsets, never translate(-50%) |

A lint error silences the layout and contrast audits, so clear lint first or `check` reports a clean zero that means nothing.

## Rendering

- Needs ffmpeg and ffprobe on PATH (`brew install ffmpeg`, done October 2026).
- `npx hyperframes render --quality looks --output renders/<file>.mp4 --quiet` in each project. About a minute per cut.
- Verify the file, not the preview: `ffprobe -show_entries format=duration:stream=width,height` and tile frames with `ffmpeg -vf "select='eq(n\,120)+eq(n\,400)',scale=640:-1,tile=2x1" -frames:v 1 out.jpg`, then look at the image.
- Disk: the first run died on a full disk. Check `df -h /` before rendering; clear `~/.npm/_npx` and `~/.npm/_cacache` if needed, they rebuild.

## Delivery to iCloud

The shell cannot touch `~/Library/Mobile Documents`. Stage the files in `/tmp/<stage>` and drive Finder:

```applescript
tell application "Finder"
  set icloud to (path to library folder from user domain as text) & "Mobile Documents:com~apple~CloudDocs:"
  set bentoFolder to folder (icloud & "bento:")
  if not (exists folder "<folder>" of bentoFolder) then make new folder at bentoFolder with properties {name:"<folder>"}
  set dest to folder "<folder>" of bentoFolder
  duplicate every item of (folder (POSIX file "/tmp/<stage>" as text)) to dest with replacing
  return {name of every item of dest, modification date of every item of dest}
end tell
```

Run with the sandbox disabled. Always list the folder afterward: one earlier copy left a stray file named " .mp4" that had to be deleted. "With replacing" is how a new version replaces the old; do not create versioned filenames.

## Copy and naming

- No dashes as pauses anywhere on screen, in storyboard text included.
- Stand in names only: Jordan Reyes (JR) types the request; Priya Nair and Marcus Lee are the colleagues. Never the real author's name.
- Feature, project, channel, workspace used so far: "Dark mode for the settings page", bento-www, #product, Acme.
