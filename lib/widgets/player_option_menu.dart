import 'package:flutter/material.dart';

class PlayerOption {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  PlayerOption({required this.label, required this.icon, required this.onTap, this.color});
}

class PlayerOptionMenu extends StatelessWidget {
  final List<PlayerOption> options;
  final Offset position;
  final int? hoveredIndex;

  const PlayerOptionMenu({super.key, required this.options, required this.position, this.hoveredIndex});

  static const double itemHeight = 60.0;
  static const double itemWidth = 220.0;
  static const double verticalSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final double totalHeight = (options.length * itemHeight) + ((options.length - 1) * verticalSpacing);

    double top = position.dy - (totalHeight / 2);
    double left = position.dx - (itemWidth / 2);

    final size = MediaQuery.of(context).size;
    if (top < 80) top = 80;
    if (top + totalHeight > size.height - 80) top = size.height - 80 - totalHeight;
    if (left < 20) left = 20;
    if (left + itemWidth > size.width - 20) left = size.width - 20 - itemWidth;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.12))),
          Positioned(
            top: top,
            left: left,
            child: Column(
              children: List.generate(options.length, (index) {
                final option = options[index];
                final bool isHovered = hoveredIndex == index;

                return Padding(
                  padding: EdgeInsets.only(bottom: index == options.length - 1 ? 0 : verticalSpacing),
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

  const _MenuTile({required this.option, required this.isHovered, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final Color contentColor = option.color ?? const Color(0xFF5D4037);
    final Color bgColor = isHovered
        ? (option.label == 'Cancel' || option.label == 'Remove'
              ? Colors.red.shade100
              : const Color(0xFFF5EFE1))
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isHovered ? 0.1 : 0.05),
            blurRadius: isHovered ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(option.icon, color: contentColor, size: 24),
          const SizedBox(width: 16),
          Text(
            option.label,
            style: TextStyle(
              color: contentColor.withOpacity(isHovered ? 1.0 : 0.8),
              fontSize: 18,
              fontWeight: isHovered ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
