# Changelog

All notable changes to Clarion are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
