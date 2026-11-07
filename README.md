# Ours Design System

Swift package implementing the **Ours** design language — tokens, fonts and base components
for the Coterie iOS app.

Part of a four-repo project, cloned side by side into a plain `coterie/` folder:

| Repo | Local | Contents |
|---|---|---|
| [`coterie-design`](https://github.com/suigeneris/coterie-design) | `coterie/design` | this repo — the design system as a Swift package |
| [`coterie-ios`](https://github.com/suigeneris/coterie-ios) | `coterie/ios` | SwiftUI app |
| [`coterie-backend`](https://github.com/suigeneris/coterie-backend) | `coterie/backend` | Supabase schema, migrations, RLS, pgTAP |
| [`coterie-docs`](https://github.com/suigeneris/coterie-docs) | `coterie/docs` | spec, plans, and the design system **source of truth** |

The written system and its 14 plates live in `coterie-docs/design/`. This package is the
Swift translation of it. **When they disagree, the docs win** — change them first, then this.

## Install

```yaml
packages:
  OursDesignSystem:
    url: git@github-personal:suigeneris/coterie-design.git
    branch: main
```

The SSH alias is deliberate. SPM fetches over HTTPS, and on a machine signed in to more than
one GitHub account the credential helper can resolve to the wrong identity — a private repo
then returns a misleading `Repository not found`. See `coterie-docs/README.md`.

**After pushing to this repo, consuming apps need `make refresh-design`.** SPM pins to a
commit and caches the clone, so a plain rebuild silently uses the old version and fails with
"no member" errors that look like your code is wrong.

## Use

```swift
import OursDesignSystem

VStack(spacing: OursSpacing.md) {
    Text("luxury, together")
        .oursTextStyle(.display)
        .foregroundStyle(OursColor.ink)

    OursBadge("3 of 4 shares", tone: .attention)

    OursButton("Buy this share") { … }
}
.padding(OursScreenMargin.standard)
.background(OursColor.backgroundPrimary)
```

## What's in it

| | |
|---|---|
| `OursColor` | Brand, neutral, surface and semantic colours |
| `OursTextStyle` | The 9-step type scale, Dynamic Type aware, with specified line heights |
| `OursSpacing` · `OursRadius` · `OursSize` · `OursScreenMargin` | 4pt grid, radius scale, fixed sizes |
| `OursIconSize` · `OursStroke` | Free-standing symbol sizes; stroke widths and the dash pattern |
| `OursElevation` | Three levels, with the shadow and border each specifies |
| `OursMotion` | Durations, animations, and Reduce Motion handling |
| `OursButton` · `OursBadge` | Base components |
| `OursChip` · `OursTextArea` | Selection chip, multi-line text field with a code-point counter |
| `OursFundingBar` · `OursStepProgress` · `OursSkeleton` | Progress bars with labels, and a loading placeholder |
| `OursAvatarGroup` · `OursPhotoTile` | Initials or remote avatars with an open place, and a photo add, preparing and preview tile |
| `OursProductCard` · `OursOwnershipCard` · `OursInformationCard` | Cards that take strings and slots, never a domain type |

### Setting a button's label colour

`.foregroundStyle` **does not work** on `OursButton` — the button's `ButtonStyle` sets the
label colour on its own content, and a modifier applied closer to the content always wins, so
an outer `.foregroundStyle` is silently ignored. Use:

```swift
OursButton("Skip", kind: .tertiary) { … }
    .oursButtonLabelColor(OursColor.ink)
```

Disabled buttons ignore the override, so a caller cannot tint an unusable control into
looking usable.

### Appearance

Ours is light-only for now. The app locks itself to light with `UIUserInterfaceStyle: Light` in
its Info.plist. Tokens are still built to adapt: a token gets a dark value by changing
`Color(ours: hex)` to `Color(ours: light, dark: dark)`, and the contrast tests already run in
both appearances, so a dark value has to pass AA before it can ship.

## What's deliberately not in it

**Anything that knows about the product.** No `Pool`, no `Profile`, no domain models. Anything
that takes a domain type, such as a `Pool`, is composed from these primitives in the app, not
here. The moment this package imports a domain type it stops being a design system and becomes
a second app target.

## Fonts

DM Serif Display and Inter, both open-source (SIL OFL, licences included alongside them).

Fonts inside a Swift package **cannot** be declared in the host app's `UIAppFonts` — that key
only sees the app bundle. They're registered at runtime from `Bundle.module` via Core Text,
automatically on first use of any type token. Callers don't need to do anything; call
`OursFonts.registerIfNeeded()` explicitly only if you want to pay that cost at launch.

## Tests

```bash
xcodebuild test -scheme OursDesignSystem -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The suite is mostly guards rather than examples. The one worth knowing about computes
**WCAG contrast for every text token against both grounds** and fails below 4.5:1. Three
tokens in the source plates failed that bar and were darkened; this test is what stops them
drifting back. It is verified to bite — reverting `stone` to the plate's `#A3A3A3` fails with
2.28:1 and 2.52:1.

A second holds every control's resting border (`outline`) to the 3:1 WCAG asks of a boundary
you need to see to find the control, on both grounds; `mist` is for decorative hairlines only.

Others check that the serif stays reserved for headlines, that the spacing scale stays on the
4pt grid, that touch targets meet 44pt, and that every font file is present in the resource
bundle.
