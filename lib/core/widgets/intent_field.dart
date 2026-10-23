import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'dynamic_pill.dart';
import 'pressable.dart';

/// IntentField: a serene, conversational surface where the user states a
/// goal, followed by curated contextual intent pills.
///
/// Deliberately not a search bar — no magnifier, no border box. The prompt
/// is set in display type, and focus is shown by an iris filament drawing
/// itself along the base of the field.
class IntentField extends StatefulWidget {
  const IntentField({
    super.key,
    required this.onSubmitted,
    this.onCleared,
    this.capsules = const [],
    this.activeIntent,
    this.hint = 'What are you seeking to accomplish?',
  });

  final ValueChanged<String> onSubmitted;
  final VoidCallback? onCleared;

  /// Curated suggestions shown as pills beneath the field.
  final List<String> capsules;

  /// The applied intent; its capsule (if any) renders selected, and clearing
  /// it upstream clears the field.
  final String? activeIntent;
  final String hint;

  @override
  State<IntentField> createState() => _IntentFieldState();
}

class _IntentFieldState extends State<IntentField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  @override
  void didUpdateWidget(IntentField old) {
    super.didUpdateWidget(old);
    if (old.activeIntent != null && widget.activeIntent == null) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _submit([String? value, bool haptic = true]) {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty) return;
    if (haptic) HapticFeedback.lightImpact();
    _focus.unfocus();
    widget.onSubmitted(text);
  }

  void _clear() {
    _controller.clear();
    widget.onCleared?.call();
  }

  void _toggleCapsule(String capsule) {
    if (widget.activeIntent == capsule) {
      _clear();
      return;
    }
    _controller.value = TextEditingValue(
      text: capsule,
      selection: TextSelection.collapsed(offset: capsule.length),
    );
    // The pill already ticked with a selection haptic.
    _submit(capsule, false);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasText = _controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          foregroundPainter: RimLightPainter(
            borderRadius: AppRadii.xlAll,
            gradient: focused
                ? AppDecorations.rimLight
                : AppDecorations.rimLightSoft,
          ),
          child: AnimatedContainer(
            duration: AppMotion.medium,
            curve: AppMotion.standard,
            decoration: AppDecorations.vellum(
              borderRadius: AppRadii.xlAll,
              active: focused,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: _Field(
                    controller: _controller,
                    focusNode: _focus,
                    hint: widget.hint,
                    hasText: hasText,
                    onSubmit: _submit,
                    onClear: _clear,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedFractionallySizedBox(
                      duration: AppMotion.slow,
                      curve: AppMotion.emphasized,
                      widthFactor: focused ? 0.84 : 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.irisGlow.withValues(alpha: 0),
                              AppColors.irisGlow,
                              AppColors.irisGlow.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Suggestions step aside once there is text: the field (or the
        // intent summary below it) is then the only thing asking for focus.
        AnimatedSize(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: widget.capsules.isEmpty || hasText
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final capsule in widget.capsules)
                        DynamicPill(
                          label: capsule,
                          size: PillSize.regular,
                          color: AppColors.irisGlow,
                          selected: widget.activeIntent == capsule,
                          onTap: () => _toggleCapsule(capsule),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.hasText,
    required this.onSubmit,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool hasText;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClear;

  // Intent sits in the display band (24–28px) — the prompt is the hero.
  static TextStyle get _style => AppTypography.display.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmit,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.go,
          textCapitalization: TextCapitalization.sentences,
          style: _style,
          decoration: InputDecoration(
            hintText: hint,
            hintMaxLines: 2,
            hintStyle: _style.copyWith(color: AppColors.textTertiary),
            contentPadding: const EdgeInsets.only(right: AppSpacing.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                'Add a ceiling, e.g. < ₹2,500',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            if (hasText)
              Pressable(
                onTap: onClear,
                semanticLabel: 'Clear intent',
                child: SizedBox.square(
                  dimension: 36,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.xs),
            _SubmitButton(
              enabled: hasText,
              onTap: () => onSubmit(controller.text),
            ),
          ],
        ),
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
      haptic: false,
      semanticLabel: 'Evaluate intent',
      scale: 0.92,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.iris : AppColors.hairline,
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 18,
          color: enabled ? AppColors.onAccent : AppColors.textTertiary,
        ),
      ),
    );
  }
}
