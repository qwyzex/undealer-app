import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:undealer/theme/colors.dart';

class SVGIcon extends StatelessWidget {
  final String assetName;
  final Color? color;
  final int? width;
  final int? height;
  final String description;
  final int? size;

  const SVGIcon({
    super.key,
    required this.assetName,
    this.color = AppColors.textColor,
    this.width = 24,
    this.height = 24,
    this.size,
    this.description = 'Undealer Widget Icon',
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/svgs/$assetName.svg",
      width: size != null ? size?.toDouble() : width?.toDouble(),
      height: size != null ? size?.toDouble() : height?.toDouble(),
      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: description,
    );
  }
}
