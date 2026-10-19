# Changelog

All notable changes to Clarion are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
