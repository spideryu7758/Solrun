import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Shimmer 骨架屏基础组件
class RpSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const RpSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<RpSkeleton> createState() => _RpSkeletonState();
}

class _RpSkeletonState extends State<RpSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.rpCard;
    final highlightColor = context.rpBorder;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _ctrl.value, 0),
              end: Alignment(-1.0 + 2.0 * _ctrl.value + 1.0, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// 卡片骨架
class RpCardSkeleton extends StatelessWidget {
  final double height;

  const RpCardSkeleton({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RpSkeleton(height: height, borderRadius: 12),
    );
  }
}

/// 会话 tile 骨架（圆形 + 两行文字 + 右侧数字）
class RpSessionTileSkeleton extends StatelessWidget {
  const RpSessionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const RpSkeleton(width: 36, height: 36, borderRadius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RpSkeleton(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                RpSkeleton(width: 80, height: 10, borderRadius: 4),
              ],
            ),
          ),
          const RpSkeleton(width: 40, height: 20, borderRadius: 4),
        ],
      ),
    );
  }
}

/// 数值指标骨架
class RpMetricSkeleton extends StatelessWidget {
  const RpMetricSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RpSkeleton(width: 60, height: 24, borderRadius: 4),
        const SizedBox(height: 4),
        RpSkeleton(width: 40, height: 10, borderRadius: 4),
      ],
    );
  }
}
