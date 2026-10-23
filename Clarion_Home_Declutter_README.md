# Clarion: Calmer Home Screen (UI Declutter Proposal)

**For:** Om
**From:** Aaryesh
**Status:** Idea only. Nothing in the repo has been changed. This is a proposal for whoever owns the Home screen to pick up.

---

## 1. The problem in one line

When the app opens, the Home screen asks for attention in about **30 places at once**, so there is no clear first thing to look at.

The tactile feel is great (button presses, card taps, the hold button). The issue isn't interaction. It's that too many things are visible and competing at the same moment.

## 2. What is on screen right now (Home, first view, no scrolling)

| Zone | Elements competing for attention |
|---|---|
| Top bar | Logo orb, budget ring, "₹4,199", "/ ₹9,000", profile button |
| Intent card | "STATE AN INTENT" label, big headline, placeholder hint, send arrow |
| Chips | 3 suggestion chips |
| Section header | "RANKED FOR YOU" label, "Personal Fit Stream" title, caption line |
| Product card | Distance pill, artwork, brand, title, price, 94% gauge, rationale line, 2 factor lines (+35 / -08) |
| Next card | A second card peeking in from the right, with its own pill, price and factors |
| Nav capsule | 4 tabs, plus a red notification dot on Profile |

Below the fold there are two more full sections: **Radar** and **Watching**.

### Why it feels overloaded

1. **Three "hero" elements compete.** The big intent headline, the green 94% gauge and the budget ring are all high-contrast and sit close together.
2. **Every section has a 3-layer header** (mono eyebrow, title, caption). That is 3 text lines before any content, repeated on every section and every tab.
3. **The product card tries to be the decision screen.** It shows score, rationale and two signed factors. The full breakdown already lives one tap away on the decision screen.
4. **Budget is shown twice at full detail.** Once in the Home header (ring + ₹4,199 / ₹9,000) and again on the Guardian tab.
5. **Colour is used for everything.** Emerald on the ring, gauge and positive factors, amber on negative factors and starred criteria, blue/indigo on the active tab. Nothing is quiet.
6. **The floating nav capsule overlaps the bottom of the first card**, which adds to the crowded feeling.

## 3. The goal

> On open, the user should know the single next thing to do. Everything else is available, but quiet.

A simple test: show the screen for **5 seconds**, then ask "what was the first thing you looked at, and what would you do next?" Today the answer is mixed. After the change it should be "the intent box".

## 4. Proposed changes

Ordered from quick wins to bigger ideas. The first four alone should fix most of it.

### Quick wins

**A. Make the intent field the only hero.**
Keep "What are you seeking to accomplish?" as the loudest thing on screen. Everything else drops a level in contrast and size.
- Drop the "STATE AN INTENT" eyebrow. The headline already says it.
- Shorten the placeholder to something like `Add a ceiling, e.g. < ₹2,500`.

**B. Slim the top bar to one budget element.**
Replace ring + "₹4,199 / ₹9,000" with a single small pill, such as the ring plus "₹4.8k left". Full numbers stay on Guardian and Profile.

**C. Slim the Fit Stream card.**
Keep: artwork, title, price, fit gauge. Move to the decision screen: the +35 / -08 factor lines, the rationale line and the distance pill (or keep only the distance pill, nothing else).
- This also lets the card shrink from `356` to roughly `270-280` tall, so one full card sits above the nav capsule with no overlap.

**D. Cut section headers to one line.**
Use title only ("Personal Fit Stream"). Drop the mono eyebrow and the caption. Keep the mono eyebrow style for the Home screen's top label at most, as a deliberate brand touch.

### Medium

**E. Merge Radar + Watching into one "Price memory" section.**
Both are "prices I should care about". Use one collapsed row: `Price memory · 2 below average ›`. Tapping opens a bottom sheet (there is already a `clarion_sheet.dart`) or expands in place. The home scroll then ends after the Fit Stream.

**F. One accent colour at a time.**
Rule: the emerald accent is reserved for the fit gauge and "good price". Starred criteria, chips and the active tab use neutral or indigo. Fewer colours means the eye lands on one thing.

**G. Quieter chips.**
Make them smaller, text-only (no filled pill) and hide them once the user starts typing or has an active intent.

### Bigger idea (optional)

**H. Two-state Home ("Ask, then answer").**
- *Resting state:* header, intent card, chips, and a single "peek" of the top pick. Nothing else.
- *After an intent is submitted:* the intent card shrinks to a summary chip (this already exists as `IntentSummary`) and the Fit Stream takes over the screen.
This literally gives "one thing at a time". The existing `AnimatedSize` and `AnimatedSwitcher` transitions in the home screen already support it.

### Keep as is (these are already good)

- The tactile press feel (`Pressable`, `TactileCard`, `HoldButton`). This is the satisfying click.
- The colour theme, typography and spacing tokens. We are only changing how many things appear, not the look.
- The **Guardian / Smart Cart** screen's empty state ("Nothing here, and that's fine"). It is the calm reference the rest of the app should feel like.

## 5. Where to make the changes (all under `lib/features/home/` unless noted)

| Change | File(s) |
|---|---|
| A. Intent field hero | `core/widgets/intent_field.dart` |
| B. Slim budget in top bar | `home/presentation/widgets/horizon_header.dart` |
| C. Slim card | `home/presentation/widgets/fit_stream.dart` (`FitStreamCard`, `height` constant, `_FactorLine`) |
| D. Single-line headers | `core/widgets/section_header.dart` and its usages in `intent_home_screen.dart` |
| E. Merge Radar + Watching | `home/presentation/intent_home_screen.dart`, `price_memory_radar.dart`, `watchlist_card.dart` |
| F. Accent colour rule | `core/theme/app_colors.dart` and usages |
| G. Quieter chips | `core/widgets/intent_field.dart` |
| H. Two-state Home | `home/presentation/intent_home_screen.dart`, `intent_summary.dart` |

Note: the factor lines and rationale removed from the card must still appear on `decision/presentation/product_decision_screen.dart`. Check that screen already shows them before removing them from the card.

## 6. Suggested rollout

1. **Pass 1 (about an hour):** A, B, C, D. Re-test.
2. **Pass 2:** E, F, G.
3. **Pass 3 (only if it still feels busy):** H.

## 7. How we will know it worked

- [ ] Roughly **15 or fewer** distinct elements on the first view (down from about 30).
- [ ] One full product card fits above the nav capsule with no overlap.
- [ ] The 5-second test: new users name the intent box as the first thing they noticed.
- [ ] Tap targets and press animations feel the same as before.
- [ ] No information is lost. It moves one tap deeper instead.

## 8. The same pattern on other screens (later)

The **Compare Matrix** screen has the same density issue: two product cards with gauges, a priorities row, a verdict card and a differences list, all stacked. The fix is the same: one hero (the verdict), everything else secondary. This can be a follow-up after Home.

---

*Screenshots reviewed: Horizon (Home), Compare Matrix, Guardian (Smart Cart). Home-screen source files were read to map suggestions to code. No files were edited.*
