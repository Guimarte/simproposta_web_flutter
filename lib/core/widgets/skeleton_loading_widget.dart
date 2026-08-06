import 'package:flutter/material.dart';
import '../constants/simproposta_colors.dart';

class SkeletonLoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoadingWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 10.0,
  });

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surfaceSubtle;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: (isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border).withOpacity(0.4),
            ),
          ),
        );
      },
    );
  }
}

class DashboardSkeletonView extends StatelessWidget {
  const DashboardSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(child: SkeletonLoadingWidget(height: 90)),
            SizedBox(width: 14),
            Expanded(child: SkeletonLoadingWidget(height: 90)),
            SizedBox(width: 14),
            Expanded(child: SkeletonLoadingWidget(height: 90)),
            SizedBox(width: 14),
            Expanded(child: SkeletonLoadingWidget(height: 90)),
          ],
        ),
        const SizedBox(height: 24),
        const SkeletonLoadingWidget(height: 180, borderRadius: 14),
        const SizedBox(height: 24),
        Row(
          children: const [
            Expanded(flex: 5, child: SkeletonLoadingWidget(height: 240, borderRadius: 16)),
            SizedBox(width: 18),
            Expanded(flex: 6, child: SkeletonLoadingWidget(height: 240, borderRadius: 16)),
          ],
        ),
        const SizedBox(height: 28),
        const SkeletonLoadingWidget(height: 80, borderRadius: 12),
        const SizedBox(height: 12),
        const SkeletonLoadingWidget(height: 80, borderRadius: 12),
      ],
    );
  }
}
