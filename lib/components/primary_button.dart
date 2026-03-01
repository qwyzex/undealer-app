import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:undealer/theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final bool? secondary;

  const PrimaryButton({super.key, required this.buttonText, this.onTap, this.width, this.height, this.secondary});

  bool get isSecondary => secondary ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isSecondary ? Colors.transparent : Colors.pinkAccent.shade200,
        boxShadow: isSecondary ? [] : [BoxShadow(color: Colors.pinkAccent.shade200.withAlpha(60), blurRadius: 25, offset: const Offset(0, 0), spreadRadius: 10)],
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: isSecondary ? AppColors.textColor : Colors.pinkAccent, width: 1, style: BorderStyle.solid, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: CupertinoButton(
        onPressed: onTap,
        color: isSecondary ? Colors.transparent : Colors.pinkAccent,
        minimumSize: Size(width ?? 160, height ?? 40),
        focusColor: Colors.blue,
        foregroundColor: Colors.yellow,
        disabledColor: Colors.purple,
        borderRadius: BorderRadius.circular(10),
        pressedOpacity: 0.65,
        sizeStyle: CupertinoButtonSize.large,
        padding: const EdgeInsets.all(10),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: isSecondary ? TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Lexend') : TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Lexend'),
        ),
      ),
    );
  }
}
