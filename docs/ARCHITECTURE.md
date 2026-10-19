# Clarion Architecture

## Layout

Feature-first. Shared, feature-agnostic code lives in `lib/core/`; each feature owns an `application/` layer (Riverpod state) and a `presentation/` layer (screens + widgets).

```text
core/        theme · widgets · models · data (mock) · utils
features/
  navigation/  AppTab + MainScaffold shell
  home/        IntentQuery parsing & ranking → IntentHomeScreen
  decision/    ProductDecisionScreen, CompareMatrixScreen, cooldowns, compare scoring
  cart/        CartController, swap suggestions → SmartCartScreen
  budget/      BudgetController + BudgetSnapshot (no UI of its own)
  profile/     InsightsScreen
```

## State (Riverpod 3)

| Provider | Type | Responsibility |
| :--- | :--- | :--- |
| `navigationProvider` | `Notifier<AppTab>` | Active shell tab; any screen can redirect (e.g. Decision View → cart). |
| `intentProvider` / `fitPicksProvider` | `Notifier<IntentQuery?>` / derived | Parsed intent; ranked, budget-filtered picks. |
| `budgetProvider` | `Notifier<BudgetState>` | Monthly limit, settled spend by category, mindful-win stats. |
| `cartProvider` | `Notifier<List<CartLine>>` | Add / remove / restore / quantity / in-place swap. |
| `cartTotalProvider`, `cartCountProvider` | derived | Totals for badges and the gauge. |
| `budgetSnapshotProvider` | derived | Settled + cart vs limit: `committed`, `headroom`, `overBy`, `leftAfter(price)`. |
| `swapSuggestionsProvider` | derived | Cheaper verified alternatives for cart items, biggest saving first. |
| `cooldownProvider` / `clockProvider` | `Notifier<Map>` / `StreamProvider` | *Hold to Think* expiries; a 30 s tick for countdowns. |
| `compareProvider` / `compareResultProvider` | `Notifier` / derived | Selected pair + priorities → aligned rows, per-row winners, weighted verdict. |

Derived providers keep business rules (budget arithmetic, ranking, compare scoring) out of widgets, so they are unit-testable and swap cleanly onto a real backend later.

## Budget semantics

- **Settled** = purchases already made this month. **Committed** = settled + cart.
- The Decision View's "Leaves ₹X in your monthly envelope" is `limit − settled − price` (the item on its own); a second line warns when the current cart would push it over.
- The Guardian barometer's *Month* view shows committed vs limit; *Cart* view shows cart vs the envelope left after settled spend.

## Navigation

`MainScaffold` hosts four tabs in a `Stack`. Tabs are built lazily on first visit and then kept alive; inactive tabs fade out, ignore pointers / focus / semantics, and have tickers paused via `TickerMode` (placed *inside* the fade so the outgoing tab can still animate). The Decision View is pushed on the root navigator with a fade-up `PageRouteBuilder` and `Hero` thumbnails.

## Performance rules

- `BackdropFilter` only on persistent overlays; repeated scroll items use `GlassContainer.card` (no blur).
- Pinned glass headers skip the blur pass at scroll offset 0.
- Custom painters (dial, gauge, sparkline, ambient glows) sit behind `RepaintBoundary`s.

## Data

`MockCatalog` provides 8 products with specs, fit factors (which sum exactly to each fit score), deterministic 30-day price histories whose mean equals the stated average, and two curated compare pairs. Replace it with a repository behind the same `Product` model when a backend lands.

## Testing

`test/widget_test.dart` covers INR formatting, intent parsing / budget filtering, fit-factor integrity, and widget smoke tests that render home, every tab, and the Decision View (layout overflows fail the suite).
