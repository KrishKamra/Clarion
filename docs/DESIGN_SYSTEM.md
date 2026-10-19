# Clarion Design System

Dark-first, calm and precise: Linear-style restraint, Apple-style frosted depth, and Stripe-style ambient gradient light. All tokens live in `lib/core/theme/`.

## Colour (`app_colors.dart`)

| Token | Value | Use |
| :--- | :--- | :--- |
| `backgroundDeep` | `#090D16` | App canvas |
| `surface` | `#111827` | Sheets, bars, solid surfaces |
| `surfaceHigh` | `#172033` | Snackbars, tooltips, raised chips |
| `primary` | `#6366F1` | Indigo glow · primary actions |
| `secondary` | `#8B5CF6` | Violet accent · gradients |
| `accent` | `#06B6D4` | Cyan · local-store tags, value metrics, links |
| `fitHigh` | `#10B981` | Fit 90–100 · within budget · criterion winner |
| `fitMid` | `#F59E0B` | Fit 70–89 · trade-offs · approaching limit (≥ 85%) |
| `fitLow` | `#EF4444` | Fit < 70 · over budget · impulse warning |
| `glassTint*` | white @ 4–8% | Glass fills |
| `glassBorder` | white @ 12% | Glass edges |

Helpers: `AppColors.forFitScore(score)` and `AppColors.forBudgetRatio(ratio)` keep semantic colour decisions in one place.

## Typography (`app_typography.dart`)

Platform system face (SF Pro / Roboto) for instant rendering, with negative tracking on large sizes. Scale: `display 34`, `headline 26`, `title 20`, `titleSmall 16`, `body 15`, `bodySmall 13`, `label 13`, `caption 11.5`, `overline 11` (uppercase, tracked). Numeric styles (`numericLarge`, `numeric`, `numericSmall`) use **tabular figures** so animated prices and scores don't jitter.

## Spacing, radii, motion (`app_spacing.dart`)

- **Spacing:** 4px base — `xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32`; screen gutter 20.
- **Radii:** `sm 10 · md 14 · lg 20 · xl 28 · pill`.
- **Motion:** `fast 150ms · medium 280ms · slow 520ms · dial 1100ms`; curves `easeOutCubic` / `easeOutQuart`.
- **Nav clearance:** scrollable tab bodies end with `AppSpacing.navBarClearance(context)` so content clears the floating bar.

## Glass (`app_glass.dart`, `glass_container.dart`)

Two tiers, chosen for performance:

| Tier | How | Where |
| :--- | :--- | :--- |
| **True glass** | `GlassContainer(blur: 16)` → `BackdropFilter` | Persistent overlays only: bottom bar, pinned headers (only while content is underneath), sheets, sticky decision bar, single static badges. |
| **Faux glass** | `GlassContainer.card(...)` → translucent gradient fill, no blur | Anything repeated inside a scroll view (cards, rows, tiles). |

Both share the 1px directional border sheen (`GlassBorderPainter`): bright at top-left, fading to transparent at bottom-right. Elevation is expressed as coloured glow (`AppGlass.glow`) rather than drop shadow.

## Core components (`lib/core/widgets/`)

| Component | Purpose |
| :--- | :--- |
| `GlassContainer` | Frosted / faux-glass surface with optional tint, gradient fill, tap. |
| `GradientButton` | `primary` / `glass` / `success` variants, loading & disabled states, optional subtitle. |
| `FitScoreDial` | Animated radial 0–100 score coloured by fit tier, with glow. |
| `IntentSearchBar` | Goal-first input with gradient focus ring and quick-prompt chips. |
| `FrostedBottomBar` | Floating true-glass nav with gliding active indicator and badges. |
| `GlassSliverHeader` | Pinned header that frosts only once content scrolls under it. |
| `PriceTrendChart` | Self-drawing 30-day sparkline with dashed average line. |
| `ProgressRing`, `TagPill`, `SectionHeader`, `ProductThumbnail`, `GlassSheet`, `Pressable`, `AmbientBackground`, `ClarionLogo` | Supporting primitives. |

## Voice & interaction principles

- **Inform, never pressure.** No countdown timers on deals, no "only N left". Price memory says *"No rush — Clarion keeps watching."*
- **Friction where it helps.** Over-budget adds and checkouts get one calm confirmation; the recommended path (hold / swap) is the primary button, but the user always keeps the final say.
- **Show the arithmetic.** Fit scores, budget impact and swap savings are always shown with their numbers.
- **Tactile feedback.** `Pressable` scale-down plus light haptics on every custom control.
