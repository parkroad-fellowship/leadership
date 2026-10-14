import 'package:flutter/widgets.dart';

/// Calls [onEndReached] when the wrapped scrollable is within [threshold]
/// pixels of its end. `ResourceCubit.loadNextPage` ignores repeat calls.
class LoadMoreOnScroll extends StatelessWidget {
  const LoadMoreOnScroll({
    required this.child,
    required this.onEndReached,
    this.threshold = 600,
    super.key,
  });

  final Widget child;
  final VoidCallback onEndReached;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // Ignore nested scrollables (e.g. horizontal chips inside a row).
        if (n.depth == 0 &&
            n.metrics.axis == Axis.vertical &&
            n.metrics.extentAfter < threshold) {
          onEndReached();
        }
        return false;
      },
      child: child,
    );
  }
}
