import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/clarion_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../browse/application/browse_controller.dart';
import '../../application/savings_controller.dart';

/// Savings goals and per-category ceilings. Each purchase can then show
/// what share of a goal it would spend.
class SavingsGoalsCard extends ConsumerWidget {
  const SavingsGoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalsProvider);
    final categories = ref.watch(categoryBudgetsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          eyebrow: 'Opportunity cost',
          title: 'Savings goals',
        ),
        const SizedBox(height: AppSpacing.md),
        TactileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goals.isEmpty
                    ? 'Name a goal, such as a laptop, and each product will say what share of it the price is.'
                    : 'A purchase shows what share of these goals it would spend.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              for (final goal in goals) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${goal.name} · ${Fmt.inr(goal.target)}',
                  style: AppTypography.title,
                ),
              ],
              for (final budget in categories) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${budget.category} ceiling ${Fmt.inr(budget.monthlyLimit)} a month',
                  style: AppTypography.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              ClarionButton(
                label: 'Add a goal',
                tone: ButtonTone.secondary,
                onPressed: () => showSavingsSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> showSavingsSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: 'Opportunity cost',
    title: 'Add a goal',
    builder: (context) => const _SavingsForm(),
  );
}

class _SavingsForm extends ConsumerStatefulWidget {
  const _SavingsForm();

  @override
  ConsumerState<_SavingsForm> createState() => _SavingsFormState();
}

class _SavingsFormState extends ConsumerState<_SavingsForm> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _categoryLimit = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _categoryLimit.dispose();
    super.dispose();
  }

  void _save() {
    final target = double.tryParse(_target.text.replaceAll(',', ''));
    if (_name.text.trim().isNotEmpty && target != null) {
      ref
          .read(savingsGoalsProvider.notifier)
          .add(name: _name.text, target: target);
    }
    final limit = double.tryParse(_categoryLimit.text.replaceAll(',', ''));
    final category = _category;
    if (category != null && limit != null) {
      ref.read(categoryBudgetsProvider.notifier).set(category, limit);
    }
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Goal name'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _target,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Target, ₹'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Category ceiling', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in categories)
              Pressable(
                onTap: () => setState(() => _category = category),
                semanticLabel: category,
                child: Text(
                  category,
                  style: AppTypography.body.copyWith(
                    color: _category == category
                        ? AppColors.irisGlow
                        : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _categoryLimit,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly ceiling, ₹'),
        ),
        const SizedBox(height: AppSpacing.lg),
        ClarionButton(label: 'Save', onPressed: _save),
      ],
    );
  }
}
