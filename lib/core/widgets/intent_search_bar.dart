import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// Intent-first input: the user states a goal, not a keyword.
///
/// Renders a faux-glass field (it lives inside a scroll view, so no backdrop
/// blur) whose border ignites with the brand gradient on focus, followed by
/// a row of quick-prompt chips.
class IntentSearchBar extends StatefulWidget {
  const IntentSearchBar({
    super.key,
    required this.onSubmitted,
    this.quickPrompts = const [],
    this.activePrompt,
    this.hint = 'e.g. Quiet headphones for library study under ₹2k',
    this.onCleared,
  });

  final ValueChanged<String> onSubmitted;
  final List<String> quickPrompts;

  /// The currently applied intent, highlighted if it matches a chip.
  final String? activePrompt;
  final String hint;
  final VoidCallback? onCleared;

  @override
  State<IntentSearchBar> createState() => _IntentSearchBarState();
}

class _IntentSearchBarState extends State<IntentSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onChanged);
    _focus = FocusNode()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _submit([String? value]) {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty) return;
    _focus.unfocus();
    widget.onSubmitted(text);
  }

  void _usePrompt(String prompt) {
    if (widget.activePrompt == prompt) {
      _controller.clear();
      widget.onCleared?.call();
      return;
    }
    _controller.text = prompt;
    _controller.selection = TextSelection.collapsed(offset: prompt.length);
    _submit(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasText = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          padding: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            gradient: focused
                ? const LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  )
                : AppGlass.borderGradient(intensity: 1.2),
            boxShadow: focused
                ? AppGlass.glow(AppColors.primary, opacity: 0.45)
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg - 1.2),
              color: AppColors.surface.withValues(alpha: 0.92),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: AppColors.valueGradient.createShader,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    onSubmitted: _submit,
                    textInputAction: TextInputAction.search,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                    ),
                  ),
                ),
                if (hasText)
                  IconButton(
                    tooltip: 'Clear',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _controller.clear();
                      widget.onCleared?.call();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                _SubmitButton(enabled: hasText, onTap: _submit),
              ],
            ),
          ),
        ),
        if (widget.quickPrompts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: widget.quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final prompt = widget.quickPrompts[i];
                return _PromptChip(
                  label: prompt,
                  selected: widget.activePrompt == prompt,
                  onTap: () => _usePrompt(prompt),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      semanticLabel: 'Evaluate intent',
      child: AnimatedContainer(
        duration: AppMotion.medium,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          gradient: enabled ? AppColors.brandGradient : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.05),
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: enabled ? Colors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.35),
                    AppColors.secondary.withValues(alpha: 0.35),
                  ],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.8)
                : AppColors.glassBorderFaint,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_rounded : Icons.bolt_rounded,
              size: 14,
              color: selected ? Colors.white : AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 12.5,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
