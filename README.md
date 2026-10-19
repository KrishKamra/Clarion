# Clarion

> **Clear Intent. Conscious Commerce.**

Clarion is an intent-driven e-commerce **Decision Support System (DSS)** — *e-commerce that helps you buy better, not buy more.* Instead of infinite feeds and opaque recommendations, users state a goal, see why each product fits (or doesn't), compare only what differs, and stay inside a monthly spending envelope guarded by the app.

---

## 🎯 Key Feature Pillars

| Pillar | What it does in the app |
| :--- | :--- |
| 🔍 **Intent-First Search** | Describe a goal (*"College Setup < ₹3k"*). An on-device parser extracts a price ceiling and keywords and re-ranks **Personal Fit Picks**. |
| 📊 **Explainable Fit Scores** | Every 0–100 score is itemised on the Decision View — matches add points, trade-offs subtract them, and the breakdown sums exactly to the score. |
| ⚖️ **Differential Compare** | Side-by-side matrix that hides identical specs, marks the winner per criterion, and lets users star priorities that count double. |
| 🛡️ **Budget Guardian** | A live barometer of settled spend + cart vs. the monthly limit, with one-tap swaps to verified cheaper alternatives when over budget. |
| ⏳ **Anti-Impulse Guards** | *Hold to Think* 24 h cooldowns, a "Mindful check" sheet before over-budget adds, and price memory that informs without urgency. |

---

## 📱 Screens

| Tab / Route | File | Highlights |
| :--- | :--- | :--- |
| **Shell** | `features/navigation/main_scaffold.dart` | Floating frosted bottom bar, lazily built keep-alive tabs, cross-fade switching, over-budget cart badge. |
| **Intent Home** | `features/home/presentation/intent_home_screen.dart` | Live budget badge, intent search + quick prompts, fit-pick carousel with score dials, Guardian nudge, Price Memory alert. |
| **Decision View** (pushed) | `features/decision/presentation/product_decision_screen.dart` | Gallery with local-pickup badge, 30-day price trend, "Why we recommend this", sticky budget-impact bar with *Add to Intent Cart* / *Hold to Think*. |
| **Compare** | `features/decision/presentation/compare_matrix_screen.dart` | Head-to-head header, priority picker, weighted verdict, differences-only rows. |
| **Budget Guardian** | `features/cart/presentation/smart_cart_screen.dart` | Interactive barometer (Month ⇄ Cart), optimisation card, swipe-to-remove with undo, mindful checkout. |
| **Insights** | `features/profile/presentation/insights_screen.dart` | Envelope rings, editable monthly limit, six-month trend, category breakdown, items cooling off. |

---

## 🛠️ Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) 3.x · Material 3 · Dart 3 |
| **State management** | [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) 3.x (`Notifier` / derived `Provider`s) |
| **Data** | In-memory mock catalogue (`lib/core/data/mock_catalog.dart`) — no backend yet |
| **Design system** | Custom dark-first glassmorphism tokens — see [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md) |

> Persistence (e.g. SQLite) and authentication are planned but **not yet implemented**.

---

## 🗂️ Project Structure

```text
lib/
├── core/
│   ├── data/          # Mock catalogue & compare pairs
│   ├── models/        # Product, ProductSpec, FitFactor
│   ├── theme/         # Colors, typography, spacing, glass, ThemeData
│   ├── utils/         # INR (Indian grouping) & countdown formatters
│   └── widgets/       # GlassContainer, GradientButton, FitScoreDial, IntentSearchBar,
│                      # FrostedBottomBar, PriceTrendChart, GlassSheet, …
├── features/
│   ├── budget/application/      # Monthly envelope + BudgetSnapshot
│   ├── cart/                    # Cart controller, swap suggestions, Smart Cart UI
│   ├── decision/                # Decision View, Compare Matrix, cooldowns
│   ├── home/                    # Intent parsing & ranking, home UI
│   ├── navigation/              # Tab controller & MainScaffold shell
│   └── profile/presentation/    # Insights screen
└── main.dart                    # Edge-to-edge setup, ProviderScope, MaterialApp
```

Architecture notes live in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart ≥ 3.13)
- Android Studio / VS Code with Flutter & Dart plugins, plus an emulator or device

### Run

```bash
git clone https://github.com/your-username/clarion.git
cd clarion
flutter pub get
flutter run
```

### Quality checks

```bash
flutter analyze     # static analysis (flutter_lints)
flutter test        # unit + widget smoke tests
dart format lib test
```

---

## 🧪 Demo Scenario (seed data)

The mock state is tuned so the core flows are visible immediately:

- **Monthly limit** ₹5,000 · **settled** ₹2,000 · **cart** ₹3,397 → **₹397 over budget**.
- Budget Guardian suggests swapping *Arcus Q30* (₹1,899) for *Sonique Flow* (₹1,499): **save ₹400 at 94% feature parity**, landing ₹3 under.
- The *Northpeak Atlas 30L* Decision View shows **"Leaves ₹701 in your monthly envelope"** and a 92% itemised fit score.
- *Fieldnote EDC Sling* is 15% below its 30-day average (Price Memory alert).

---

## 📄 License

Intended to be released under the MIT License. A `LICENSE` file has not been added yet.
