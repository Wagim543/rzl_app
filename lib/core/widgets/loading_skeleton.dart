import 'package:flutter/material.dart';

/// Placeholder cards shown while a list loads.
///
/// Preferred over a bare `CircularProgressIndicator` because it communicates
/// the shape of what is coming and never looks like a frozen screen.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({this.itemCount = 4, this.itemHeight = 112, super.key});

  final int itemCount;
  final double itemHeight;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.9).animate(_controller),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: widget.itemHeight,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
