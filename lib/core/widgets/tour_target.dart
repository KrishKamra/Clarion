import 'package:flutter/widgets.dart';

/// Things the app tour can point at.
enum TourTarget { suggestion, firstProduct, ledger, coolOff, addToCart }

/// Finds where tour targets currently are on screen.
abstract final class TourTargets {
  static final Map<TourTarget, BuildContext> _contexts = {};

  static BuildContext? contextOf(TourTarget id) {
    final context = _contexts[id];
    return context != null && context.mounted ? context : null;
  }

  /// The target's bounds in global coordinates, or `null` if it is not on
  /// screen right now.
  static Rect? rectOf(TourTarget id) {
    final context = contextOf(id);
    if (context == null) return null;
    try {
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) return null;
      return box.localToGlobal(Offset.zero) & box.size;
    } catch (_) {
      return null; // an element mid-teardown
    }
  }
}

/// Marks [child] as something the tour can spotlight. Costs nothing when the
/// tour is not running.
class TourTargetBox extends StatefulWidget {
  const TourTargetBox({super.key, required this.id, required this.child});

  final TourTarget id;
  final Widget child;

  @override
  State<TourTargetBox> createState() => _TourTargetBoxState();
}

class _TourTargetBoxState extends State<TourTargetBox> {
  @override
  void initState() {
    super.initState();
    TourTargets._contexts[widget.id] = context;
  }

  @override
  void dispose() {
    // Only clear our own entry; a newer box with the same id may have
    // registered already (e.g. during a cross-fade).
    if (identical(TourTargets._contexts[widget.id], context)) {
      TourTargets._contexts.remove(widget.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
