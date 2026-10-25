# Accessibility

Clarion aims for **WCAG 2.1 AA** on Android, checked automatically on every push by [`test/accessibility_test.dart`](../test/accessibility_test.dart).

## What CI checks

Every screen (the four tabs, the decision canvas, Browse, Orders and an order) is checked in **both themes** against Flutter's built-in guidelines:

| Check | Standard |
| :--- | :--- |
| `androidTapTargetGuideline` | Every control is at least 48 × 48dp |
| `labeledTapTargetGuideline` | Every control has a spoken label |
| `textContrastGuideline` | Text meets 4.5:1 (3:1 for large text), WCAG 1.4.3 |
| 200 % text size | Nothing overflows when the system font size is doubled, WCAG 1.4.4 |

A new screen joins the audit by adding it to `visitEveryScreen`.

## Audit, October 2026

The first run found these issues. All are fixed.

| Finding | Fix |
| :--- | :--- |
| Screen readers read pill labels twice ("Filters, Filters"). `Pressable` added a label *and* kept the child's text. | A label passed to `Pressable` now replaces the child's text. |
| Control semantics merged into the text around them, e.g. "PURCHASES, Orders, See all" read as one button. | `Pressable` is its own semantics node (`container: true`). |
| Small targets: pills ~36dp, compact pills 24dp, round icon buttons 36–40dp, cart steppers 28dp, text links ~25dp. | `Pressable` gives every control a 48dp hit area, centred on what it draws. Nothing looks different. |
| The touch-to-inspect spending barometer was an unlabelled gesture. | It reads every segment and amount aloud, and has a 48dp touch band. |
| Dark-theme contrast: iris text 4.48:1, tertiary text on raised cards 4.32:1. | `irisGlow` (dark) `#6366F1` → `#6B6EF3`; `textTertiary` (dark) `#7D8899` → `#8792A3`. |
| At 200 % text: the tab headers, compare header, cooling-off button, price rows and Horizon header overflowed. | Fixed-height chrome grows with the text size (`AppSpacing.textGrowth`); price rows wrap; the wordmark yields room. |
| "4.6★" was read as "4.6 black star". | Ratings are announced as "Rated 4.6 out of 5". |

**Known false positive:** the decision drawer's "Leaves ₹801 safe buffer…" uses two text colours on a frosted pane. The test capture leaves out the blurred backdrop, so the contrast check compares the white and emerald text with each other. Against the drawer's real fill, both exceed 7:1. The audit skips this one node and says why.

## Built in already

- **Reduce motion:** ambient animation stops when the system asks for less motion.
- **Light and dark themes**, both checked for contrast.
- **No information by colour alone:** budget states also have words ("Safe zone", "over monthly limit").
- **Haptics** confirm holds, selections and errors.
- **Localization:** English and Hindi (see `lib/l10n/`).

## When adding UI

- Use `Pressable`, `DynamicPill`, `RoundIconButton` or `ClarionButton` for anything tappable; they bring the 48dp target and semantics.
- Pass `semanticLabel` only when it says *more* than the visible text (an icon button, a card summary). It replaces the child's text.
- Avoid fixed heights around text. When chrome must be fixed, add `AppSpacing.textGrowth(context, textHeight)`.
- Run `flutter test test/accessibility_test.dart`.

Not yet covered: iOS VoiceOver (the app ships on Android) and a manual TalkBack walkthrough on a device.
