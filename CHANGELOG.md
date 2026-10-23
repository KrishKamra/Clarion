# Changelog

All notable changes to Clarion are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added — light mode and legibility pass
- **Light mode** ("Porcelain"): every colour token now has a light value; Appearance (System / Light / Dark) lives in Spending Profile and persists via `shared_preferences`. Switching is live and keeps scroll and widget state.
- **Legibility**: body 15px / 1.5, bodySmall 13.5px, captions 12.5px, labels 14px, mono micro labels 11px; no text below 10px. Dark `textSecondary` / `textTertiary` lifted to `#A3B0C2` / `#7D8899` (tertiary was ~2.6:1, now ≥ 4.5:1).

### Changed — Home declutter (from `Clarion_Home_Declutter_README.md`)
- Adopted: dropped the "STATE AN INTENT" eyebrow and shortened the hint (A); header budget is one figure, "₹1,800 left" (B); Home section headers lose their captions (D); intent suggestions hide while the field has text (G).
- Not adopted: slimming Fit Stream cards (C — the top two weighted factors are core explainability), merging Radar into a sheet (E — hides content behind a tap), a new accent rule (F — accents already carry one meaning each), two-state Home (H) and the Compare follow-up — overkill for the problem.

### Changed — "Obsidian Titanium" brief
- **Structure** now follows the brief: domain models in `lib/data/models/` (`product_model`, `cart_item_model`, `trade_off_item`), catalogue in `lib/data/`; atoms renamed to `fit_score_gauge`, `intent_field`, `floating_nav_capsule`; new `dynamic_pill` replaces `MetaTag` and `IntentCapsule`.
- **Tabs** are now Intent Horizon, Compare Matrix, Smart Cart (Guardian) and Spending Profile; the cooling-off queue moved to Spending Profile.
- **Tokens**: `#07080B` canvas; matte (`#0E1017`) and floating (`#141824`, 0.5px edge, specular sheen) card tiers; diagonal 15 % → 2 % rim light; rose now marks cooling off; 14px body at 1.45; 18px section headers; 220–280 ms motion.
- **Intent Horizon**: monogram header, curated pills (`College Setup < ₹2.5k`, `ANC for Focus`, `Durable Commute Pack`), horizontal Personal Fit Stream with `94% Fit` gauges and the top two weighted factors, and a new **Price Memory Radar**.
- **Decision canvas**: "Pickup in 1.8 km" badge, **scrubbable** 30-day price band, "Why We Recommend This" ledger on the floating tier, specs behind progressive disclosure, hold button with micro-progress timer and a live 24h cooling-off status.
- **Compare Matrix**: sticky A-vs-B header that collapses into a frosted bar as rows scroll.
- **Smart Cart**: interactive zoned Spending Barometer (Safe → Caution → Over, touch to inspect each item) and the brief's swap copy — Q30 Pro → Core Edition regains ₹400 at 94% parity; cart items carry an `IntentPriority`.
- **Data**: Atlas scores 94; headphones become Pro/Core Edition; price history is dated `PricePoint`s; radar requires ≥ 10 % and ≥ ₹150 off.
- Primary buttons use a restrained iris gradient fill; selection haptics on pills, tabs, scrubbing and holds.
- Tests expanded to 16, including the hold gesture, spec disclosure and price radar.

### Added
- `LICENSE` (MIT; bundled fonts remain OFL-1.1), `SECURITY.md`, `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1) and `CONTRIBUTING.md`.
- Mermaid diagrams (decision flow, layers, provider graph, add-to-cart sequence, hold state machine, material selection) and GitHub callouts across the docs.

### Fixed
- Intent Canvas text now uses the 24px display band from the spec (was 20px).
- Removed an unused `child` parameter from `RoundIconButton` and a stale "Hold to Think" doc comment.

### Changed — "Midnight Obsidian" redesign
- New palette: obsidian `#08090C` canvas with film grain, raised `#0F1117` and 3 % vellum surfaces with a directional rim light; iris / emerald / amber / rose each carry one meaning. Violet and cyan gradients removed.
- Bundled type: Schibsted Grotesk for reading, Geist Mono for prices, scores and micro labels (OFL; licences in `assets/fonts/`).
- Tokens reorganised into `app_colors`, `app_typography`, `app_decorations` and `app_spacing`; motion tightened to 200–280 ms cubic curves.
- New atoms: `TactileCard`, `FrostedChrome` (the only `BackdropFilter` owner), `FitDial`, `IntentInput`, `FloatingNavBar` (magnetic indicator), `HoldButton`, `ClarionButton`, `PriceBandChart`, `ProductArtwork`, `ObsidianCanvas`.
- Tabs renamed to Intent Horizon, Decision Node, Smart Cart (Guardian) and Spending Memory; cooling-off items moved into the Decision Node; the light theme was removed.
- Decision canvas: matte stage, 30-day price band, signed "Why This Fits You" ledger, friction-by-design drawer with press-and-hold 24h Cooling Off.
- Smart Cart: multi-segment Spending Barometer and Guardian Swap Engine showing spec parity.
- `catalogProvider` separates read-only catalogue state from interaction state; cart lines hold `Product`s.
- Seed data retuned (₹3,200 / ₹5,000 committed; Atlas at ₹2,199 leaves ₹801).
- Tests now cover budget arithmetic, the swap engine and the over-budget Guardian render.

### Added
- Dark-first design system: colour, typography, spacing/motion and glass tokens plus Material 3 `ThemeData` (light theme scaffolded).
- Core widget library: `GlassContainer`, `GradientButton`, `FitScoreDial`, `IntentSearchBar`, `FrostedBottomBar`, `GlassSliverHeader`, `PriceTrendChart`, `GlassSheet`, `ProgressRing`, `TagPill`, `ProductThumbnail`, `AmbientBackground`, `ClarionLogo`.
- Mock catalogue with specs, explainable fit factors, 30-day price histories and compare pairs.
- Riverpod state for navigation, intent, budget, cart, swap suggestions, cooldowns and comparison.
- `MainScaffold` shell with a floating frosted bottom bar and keep-alive tabs.
- Screens: Intent Home, Product Decision View, Compare Matrix, Smart Cart (Budget Guardian), Insights.
- Anti-impulse flows: Hold to Think (24 h), Mindful check before over-budget adds, mindful checkout.
- Unit and widget smoke tests; `docs/DESIGN_SYSTEM.md` and `docs/ARCHITECTURE.md`.

### Changed
- Replaced the single-file prototype in `lib/main.dart` with a feature-first architecture.
- README now reflects the actual stack (Riverpod, mock data; persistence/auth not yet implemented).

### Dependencies
- Added `flutter_riverpod` ^3.4.3.
