import 'package:flutter/material.dart';
import 'package:undealer/theme/colors.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class PlayerOption {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final Color? color;

  PlayerOption({required this.label, required this.icon, required this.onTap, this.color});
}

class PlayerOptionMenu extends StatelessWidget {
  final List<PlayerOption> options;
  final Offset position;
  final int? hoveredIndex;

  const PlayerOptionMenu({
    super.key,
    required this.options,
    required this.position,
    this.hoveredIndex,
  });

  static const double itemHeight = 60.0;
  static const double itemWidth = 220.0;
  static const double verticalSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final double totalHeight =
        (options.length * itemHeight) + ((options.length - 1) * verticalSpacing);

    double top = position.dy - (totalHeight / 2);
    double left = position.dx - (itemWidth / 2);

    final size = MediaQuery.of(context).size;
    if (top < 80) top = 80;
    if (top + totalHeight > size.height - 80) top = size.height - 80 - totalHeight;
    if (left < 20) left = 20;
    if (left + itemWidth > size.width - 20) left = size.width - 20 - itemWidth;

    return Material(
      color: AppColors.transparent,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.playerOptionOverlay)),
          Positioned(
            top: top,
            left: left,
            child: Column(
              children: List.generate(options.length, (index) {
                final option = options[index];
                final bool isHovered = hoveredIndex == index;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == options.length - 1 ? 0 : verticalSpacing,
                  ),
                  child: _MenuTile(
                    option: option,
                    isHovered: isHovered,
                    width: itemWidth,
                    height: itemHeight,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to determine which index is hovered based on global touch position
  static int? getHoveredIndex(
    Offset globalPosition,
    Offset menuTriggerPosition,
    int optionsCount,
    BuildContext context,
  ) {
    final double totalHeight = (optionsCount * itemHeight) + ((optionsCount - 1) * verticalSpacing);

    double top = menuTriggerPosition.dy - (totalHeight / 2);
    double left = menuTriggerPosition.dx - (itemWidth / 2);

    final size = MediaQuery.of(context).size;
    if (top < 80) top = 80;
    if (top + totalHeight > size.height - 80) top = size.height - 80 - totalHeight;
    if (left < 20) left = 20;
    if (left + itemWidth > size.width - 20) left = size.width - 20 - itemWidth;

    if (globalPosition.dx < left || globalPosition.dx > left + itemWidth) return null;

    for (int i = 0; i < optionsCount; i++) {
      final itemTop = top + (i * (itemHeight + verticalSpacing));
      if (globalPosition.dy >= itemTop && globalPosition.dy <= itemTop + itemHeight) {
        return i;
      }
    }
    return null;
  }
}

class _MenuTile extends StatelessWidget {
  final PlayerOption option;
  final bool isHovered;
  final double width;
  final double height;

  const _MenuTile({
    required this.option,
    required this.isHovered,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = option.color ?? AppColors.textColor;
    final Color bgColor = isHovered
        ? (option.label == 'Cancel' || option.label == 'Remove'
              ? AppColors.dangerLight
              : AppColors.playerOptionMenuBackground)
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: width,
      height: height,
      transform: Matrix4.identity()
        ..translateByVector3(Vector3(0, isHovered ? -(0.05 * height) : 0, 0))
        ..scaleByVector3(Vector3.all(isHovered ? 1.1 : 1)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isHovered ? (0.1 * 255).floor() : (0.05 * 255).floor()),
            blurRadius: isHovered ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          option.icon,
          const SizedBox(width: 16),
          Text(
            option.label,
            style: TextStyle(
              color: contentColor.withAlpha(isHovered ? (1.0 * 255).floor() : (0.8 * 255).floor()),
              fontSize: 18,
              fontWeight: isHovered ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
