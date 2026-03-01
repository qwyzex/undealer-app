import 'package:flutter/material.dart';
import 'package:undealer/theme/colors.dart';

class SecondaryButton extends StatelessWidget {
  final String buttonText;
  final void Function()? onTap;

  const SecondaryButton({super.key, required this.buttonText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: AppColors.textColor, width: 5 / 2, style: BorderStyle.solid, strokeAlign: BorderSide.strokeAlignInside),
          // boxShadow: [BoxShadow(color: Colors.pinkAccent.shade200.withAlpha(100), blurRadius: 15, offset: const Offset(0, 0), spreadRadius: 5)],
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
