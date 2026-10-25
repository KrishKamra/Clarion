# Changelog

All notable changes to Clarion are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added — the clarity loop
- **Regret check-in, 14–30 days on**: kept purchases in that window ask "Still glad you bought it?". The answers nudge fit scores in that category and the Mindful Barometer shows a personal regret rate. Schema v7 stores the product and category on each check-in.
- **Cost per use**: the decision canvas states a year of use, consumables and accessories.
- **Adaptive cooling-off**: rapid adds, late-night browsing and large purchases lengthen the hold; a small, calm one shortens it. With no signals it stays 24 hours.
- **Already owned**: a warning before buying the same product, or one that shares a distinctive intent with something kept.
- **Budget-optimal set**: a goal with a ceiling gets the best-fitting combination under it, one item per category.
- **Savings goals**: each product can show what share of a named goal, and of a category ceiling, its price is.
- **Refurbished and repair**: separate from the Guardian's verified swap, with the saving, parity and a sustainability score.
- **Clarity report**: a shareable month of impulse buys avoided, money kept, regret rate and best decisions.
- **Warranty vault**: return-window and warranty-expiry reminders, and a vault of kept lines.
- **Ask a friend**: a comparison link a friend votes on by opening a reply link. Votes stay on the device.
- **Home-screen widget**: budget left and the soonest cooling-off timer.
- **Goal reading**: an on-device reading of a free-form goal, replaced by grok-4.7 when `XAI_API_KEY` is compiled in, plus Android voice input.
- **In-store scan**: a barcode shows fit, price history and pickup. Typing the code works without the camera.

### Added — orders, returns, browse, reviews, sharing, Hindi, accessibility audit
- **Orders and tracking**: checkout places an order with a short reference (`CLR-…`). Profile → Orders lists them, and each has a tracking timeline (placed → packed → ready for pickup → picked up, simulated until a fulfilment backend reports it) and a "Track" link in the checkout snackbar. Saved per account (schema v6: `orders`, `order_lines`).
- **Returns**: any item can be cancelled before pickup or returned within 7 days after, with one reason and no retention tricks. The amount goes straight back to the month's envelope (a refund only touches the month the order was placed in).
- **Browse**: the whole catalogue from "Browse all" on Home, with category chips, filters (maximum price, rating, pickup nearby, below the 30-day average) and sort (best fit by default, price, rating, biggest dip). Fit stays on every row.
- **Owner reviews**: a rating breakdown and written reviews on every product, each with how long the owner had it. Buyers can write, edit or delete their own, marked as a verified purchase (schema v6: `reviews`).
- **Sharing and deep links**: a share button on each product sends price, fit and any dip, with a link. `clarion://` and `https://clarion-e08f0.web.app/…` links open products, orders and Browse (`app_links`). Notification taps use the same path. See `docs/DEEP_LINKS.md`.
- **Localization**: English and Hindi (`flutter_localizations`, ARB files in `lib/l10n/`), with a language picker in Profile. Covers navigation, the four tabs' headers, the cart, profile settings and every new screen. Product data and the remaining screens are still English.
- **Accessibility audit** (`docs/ACCESSIBILITY.md`, `test/accessibility_test.dart`): every screen in both themes is checked in CI for 48dp tap targets, labels, text contrast and 200 % text size. Fixes include: no more double-read labels; controls are their own semantics node; 48dp hit areas on every control; a spoken spending barometer; dark iris and tertiary text lifted to pass 4.5:1; fixed-height chrome that grows with the text size.
- Notifications were already in place, so nothing was added there.

### Fixed — review of the Regret Check-in, verification and deletion work
- **Account deletion** deletes the Firebase account *first*, then the local data. Before, it wiped SQLite and reminders first, so when Firebase refused with `requires-recent-login` (common), the user lost their data and still had an account. Deletion now also removes the account's saved settings (`*_<uid>` preferences).
- **Email verification card** follows the result of each status check. Before, it read the `User` object from session start, so after verifying it still showed "Unverified" until the next launch. It's now shown only to accounts that still need verifying. Removed the unused `isEmailVerifiedProvider`, which had the same stale source.
- **Regret Check-in edits** update their saved row instead of adding a duplicate each time (`replace` needs the row `id`). Before, duplicates double-counted in the Mindful Barometer after a restart.
- "Buy now or wait?": "1 week" instead of "~1 weeks", an explanation that adds information instead of repeating the headline, and the confidence label raised to the 11px minimum.
- The regret table's SQL is defined once and shared by fresh installs and the v5 upgrade.
- Formatted the four commits CI rejected; it fails on unformatted code.

### Added — Regret Check-in, price-dip predictions, email verification, account deletion (Jash Kankariya)
- **Regret Check-in**: rate a purchase "Worth it", "Neutral" or "Regretted", with a reflection tag and note, from the spend breakdown. The **Mindful Barometer** on the Spending Profile shows the share of purchases you were glad about. Saved per account (schema v5, `regret_checkins`).
- **"Buy now or wait?"** on the decision canvas: a verdict from the price history (position in the 30-day band, volatility, recent dips) with estimated savings, wait time and confidence.
- **Email verification**: a link is sent on sign-up, and a Spending Profile card can resend it or check its status.
- **Account deletion** from Profile → Account, with a confirmation sheet.

### Added — persistence, Price Memory Watcher, fit engine, onboarding (Aaryesh Pathare)
- **SQLite persistence** for the cart, cooling-off holds, budget and spend (schema, repositories, migrations).
- **Price Memory Watcher**: watch products, set target prices, and see recorded price history.
- **Heuristic Fit Engine**: fit scores computed from the product and your intent, explained in plain language.
- **First-run onboarding** (set your monthly ceiling) and a **hands-on app tour**, once per account, plus a larger catalogue with support for product photos.

### Added — reminders, app icon, splash and CI
- **Notifications** (`flutter_local_notifications`, Android): a cooling-off reminder is scheduled for the moment each 24h hold ends and survives reboots; a price-watch alert fires when a watched product reaches its target (once per target). Tapping either opens the product. Permission is asked when a reminder first becomes useful (holding a product or setting a target), never at launch. Reminders are re-armed per account when its session opens and cleared on sign-out. Calm copy, no countdowns.
- **App icon**: an adaptive icon (the lens over the aurora canvas), a themed monochrome icon for Android 13+, a legacy icon and web icons, all generated from `assets/brand/icon/` (`flutter_launcher_icons.yaml`). The app is now labelled "Clarion".
- **Splash**: native light and dark splash screens on the app's two canvas colours, for both pre-12 and Android 12+ (`flutter_native_splash.yaml`).
- **CI** (`.github/workflows/ci.yml`): format, analyze and test on every push and PR with Flutter pinned to 3.47.7, then a debug APK build uploaded as an artifact. One-time `dart format` pass over the repo so the format check starts green.

### Added — brand identity
- `assets/brand/clarion_logo.svg`: the lens mark evolved into a glass lens with an iris → emerald rim, a specular glint and an iris focal point. Its colours are fixed, so it reads on light and dark. `ClarionWordmark` now renders it with `flutter_svg`, so the Home header and sign-in screen use it.
- `assets/brand/clarion_banner.svg`: logo, name and tagline ("CLEAR INTENT." / "Conscious Commerce.") over a dark aurora card. All text is outlined from the bundled fonts, so it renders identically on GitHub.
- README: the banner, tech-stack badges (Flutter, Dart, Riverpod, Firebase Auth, SQLite, Material 3, platforms, licence), and an up-to-date note, tech stack, structure and roadmap.

### Changed — arrival and interaction polish
- **Sign-in redesign**: a frosted pane over a slow aurora of brand light; the lens breathing in an iris halo, with the tagline wrapped around the name ("CLEAR INTENT." above, "Conscious Commerce." in the iris → emerald gradient below); three promise pills; a sliding Sign in / Sign up switch; fields with an iris focus edge and halo, hover edges and a show-password toggle; a damped shake and haptic on errors; a staggered entrance; a four-colour Google mark.
- **App-wide hover and glow**: `Pressable` adds a click cursor, a hover lift and shared hover/press state; `PressGlow` gives solid buttons a resting glow that blooms on hover, and tappable cards light their rim in their tint.
- Ambient animation respects the system's reduce-motion setting.

### Added — Firebase authentication
- Email/password and Google sign-in (`firebase_auth`, `google_sign_in` 7), password reset, and sign-out under Profile → Account.
- `AuthGate` keeps the app behind sign-in. Each account gets its own SQLite file and provider scope, so accounts on one device never share a cart, holds, budget or watchlist.
- Connected to Firebase project `clarion-e08f0`. The config (`firebase_options.dart`, `google-services.json`, `firebase.json`) is committed, and each teammate registers their debug key for Google sign-in (`docs/FIREBASE_SETUP.md`).

### Added — light mode and legibility pass
- **Light mode** ("Porcelain"): every colour token now has a light value; Appearance (System / Light / Dark) lives in Spending Profile and persists via `shared_preferences`. Switching is live and keeps scroll and widget state.
- **Legibility**: body 15px / 1.5, bodySmall 13.5px, captions 12.5px, labels 14px, mono micro labels 11px; no text below 10px. Dark `textSecondary` / `textTertiary` lifted to `#A3B0C2` / `#7D8899` (tertiary was ~2.6:1, now ≥ 4.5:1).

### Changed — Home declutter (from the team's Home declutter proposal)
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
