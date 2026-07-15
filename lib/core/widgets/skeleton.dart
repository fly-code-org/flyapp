import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isCircle;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  const Skeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 0,
        isCircle = true;

  const Skeleton.text({
    super.key,
    this.width,
    double? height,
  })  : height = height ?? 14,
        borderRadius = 4,
        isCircle = false;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                0,
                0.5 + (_animation.value * 0.25),
                1,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.text(width: width, height: height);
  }
}

class SkeletonParagraph extends StatelessWidget {
  final int lines;
  final double spacing;
  final double lineHeight;

  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.spacing = 8,
    this.lineHeight = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: SkeletonLine(
            width: isLast ? MediaQuery.of(context).size.width * 0.6 : null,
            height: lineHeight,
          ),
        );
      }),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.circle(size: size);
  }
}

class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const SkeletonCard({
    super.key,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonAvatar(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                        width: MediaQuery.of(context).size.width * 0.3),
                    const SizedBox(height: 6),
                    SkeletonLine(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonParagraph(lines: 2),
        ],
      ),
    );
  }
}
