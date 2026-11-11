# Design system

Declared once, used everywhere. Copy the CSS, do not re-derive the colors.

## Backdrop (every scene)

Three layers inside the camera wrapper, each bleeding 800px past the frame:

```css
.bg {
  position: absolute; inset: -800px;
  background:
    radial-gradient(900px 700px at 28% 22%, rgba(255, 138, 61, 0.16), transparent 70%),
    radial-gradient(900px 700px at 78% 84%, rgba(77, 163, 255, 0.10), transparent 70%),
    #0e0d0b;
}
.grid {
  position: absolute; inset: -800px;
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.025) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.025) 1px, transparent 1px);
  background-size: 80px 80px;
}
```

Mark both with `data-layout-ignore`. The orange sits upper left, the blue lower right, on every scene including the close card, so a crossfade between scenes reads as one continuous world. For the close card use `inset: 0` (no camera there).

## Camera wrapper

```css
#world { position: absolute; inset: 0; transform-origin: 50% 50%; will-change: transform; }
```

One wrapper, one tween: `tl.to(world, { scale: S, x: -offX * S, y: -offY * S, duration: 1.4, ease: "power3.inOut" }, T)` where `offX/offY` is the target's center minus the canvas center. Scale and translate share the tween so the target never drifts. Keep S between 1.1 and 1.4; cap so the target stays under 88 percent of the frame.

## macOS window chrome

```css
.win { position: absolute; border-radius: 14px; overflow: hidden;
  border: 1px solid rgba(255,255,255,0.08);
  box-shadow: 0 40px 90px rgba(0,0,0,0.55), 0 0 0 1px rgba(0,0,0,0.6); }
.tb { position: absolute; left: 0; right: 0; top: 0; height: 44px; border-bottom: 1px solid; }
.tb i { position: absolute; top: 15px; width: 13px; height: 13px; border-radius: 50%; }
.tb i:nth-child(1) { left: 18px; background: #ff5f57; }
.tb i:nth-child(2) { left: 39px; background: #febc2e; }
.tb i:nth-child(3) { left: 60px; background: #28c840; }
.tb span { position: absolute; left: 0; right: 0; top: 12px; text-align: center; font-size: 13px; }
```

Window geometry:

| Layout | left | top | width | height |
| --- | --- | --- | --- | --- |
| wide (1920x1080) | 140 | 70 | 1640 | 940 |
| tall (1080x1920) | 50 | 520 | 980 | 880 |

The tall window is short on purpose: a 1560px tall window left half the UI empty. Keep the tall window just tall enough for its content and let the backdrop own the rest of the frame.

Title bar fill: Slack #121417 with #2b2d31 rule and #a8aaae title; Bento #161411 with #2a2722 rule and #8b867c title.

## Palettes

**Bento console** (from `apps/web/src/styles.css`, dark theme)

| Token | Value |
| --- | --- |
| bg | #0e0d0b |
| panel | #161411 |
| panel raised | #1d1b17 |
| line | #2a2722 |
| line bright | #3d392f |
| text | #ededed |
| text dim | #a8a49b |
| text faint | #8b867c |
| brand | #ff8a3d (on brand text #0e0d0b) |
| running | #4da3ff |
| succeeded | #3fbf7f |
| failed | #ff6b5e |
| gated | #f2c40d |
| idle | #6d675c |
| radius | 7px, large 12px |

**Slack dark theme** (contrast corrected for WCAG AA; Slack's own grays fail the renderer's audit)

| Use | Value |
| --- | --- |
| main pane | #1a1d21 |
| sidebar | #19171d |
| composer | #222529 with #565856 border |
| hairline | #2b2d31, controls #3a3d41 |
| text | #d1d2d3, names #fff |
| dim text | #b8babd (never darker than #a8aaae) |
| mention | #36aee6 on rgba(29,155,209,0.16) |
| active channel | #1164a3 |
| send button | #007a5a |
| avatars (white initials) | #5a3d9e, #1e7550, #a04f08 |

## Type

| Surface | Family | Sizes |
| --- | --- | --- |
| Slack | Lato 400/700/900 | body 15px wide, 17px tall; names 15/17px 900; meta 12 to 13px |
| Console | Inter 400/600/700 | body 13 to 14px; card title 13.5px 600; drawer title 20px 700; lane head 13px 700 |
| Paths and tool rows | JetBrains Mono | 11 to 12px |
| Close card | Inter 900 | wordmark 112px, letter spacing -0.05em; tagline 32px (38px tall) in text dim; URL 22px faint |

Bundled families only. Write the family name; no `@font-face` needed.

## Motion vocabulary

| Beat | Recipe |
| --- | --- |
| Window arrives | `fromTo(win, {opacity:0, scale:.965, y:18}, {opacity:1, scale:1, y:0, 0.6s, power3.out})` at 0.05s |
| Typing | discrete text sequence: per char 0.05s plus `((i*7)%4)*0.012`, +0.11s at spaces, +0.4s after a mention token; caret blinks on a sine square wave, 0.9s cycle, held solid while typing |
| Element pops in (card, reply, bubble) | `fromTo(el, {autoAlpha:0, scale:.86 to .9, y:10 to 14}, {autoAlpha:1, scale:1, y:0, 0.4 to 0.5s, power3.out})` |
| Panel slides in (thread, drawer) | `x` from its own width to 0, 0.55s, power3.out, with `autoAlpha` 0 to 1 over 0.08s at the same time |
| List makes room | the list is pre shifted down by the new row's height and tweens to 0 (0.45s, power3.out) as the row fades in |
| Running state | 8px dot scales 1 to 1.45, 0.65s, sine.inOut, yoyo, finite repeat; card gains a blue 1px ring and 24px glow |
| Streaming lines | one `fromTo` per line, 0.32s power2.out, 0.6 to 1.1s apart, longer gaps after a long paragraph |
| Camera push | 1.4 to 1.6s, power3.inOut or power2.inOut, starts 0.7s after the payoff lands, holds to the cut |
| Push cut between apps | outgoing `x: -W`, incoming `fromTo x: W → 0`, both 0.5s power3.inOut, scenes overlap 0.5s |
| Into the mark | crossfade 0.6s power1.inOut |
| Close card | lockup `fromTo scale .72 → 1, 0.7s power3.out` at 0.25s; tagline rises 22px at 0.75s; URL at 1.1s |

Rhythm for a 22.6s piece: scene one 10.1s, scene two 10.6s (starting at 9.6s), close 3s (starting at 19.6s).

## Close card

Mark (the four compartment SVG from `assets/logo.svg`, inline) plus the word "Bento". Wide: side by side, 120px mark, gap 26px. Tall: stacked, 160px mark. One tagline, the current one is "Tag @bento to build your feature" with the handle in text color and 600 weight. URL line "usebento.ai".
