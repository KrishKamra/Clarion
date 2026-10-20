import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A number that eases to each new value. Pair with a mono style so the
/// count never shifts surrounding layout.
class AnimatedMetric extends StatelessWidget {
  const AnimatedMetric({
    super.key,
    required this.value,
    required this.format,
    required this.style,
  });

  final double value;
  final String Function(double) format;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: AppMotion.reveal,
      curve: AppMotion.standard,
      builder: (context, v, _) => Text(format(v), style: style),
    );
  }
}
