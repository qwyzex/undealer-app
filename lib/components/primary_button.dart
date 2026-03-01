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
      decoration: BoxDecoration(
        color: isSecondary ? Colors.transparent : Colors.pinkAccent.shade200,
        boxShadow: isSecondary ? [] : [BoxShadow(color: Colors.pinkAccent.shade200.withAlpha(60), blurRadius: 25, offset: const Offset(0, 0), spreadRadius: 10)],
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: isSecondary ? AppColors.textColor : Colors.pinkAccent, width: 1, style: BorderStyle.solid, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: CupertinoButton(
        onPressed: onTap,
        color: isSecondary ? Colors.transparent : Colors.pinkAccent,
        minimumSize: Size(160, 40),
        focusColor: Colors.blue,
        foregroundColor: Colors.yellow,
        disabledColor: Colors.purple,
        borderRadius: BorderRadius.circular(10),
        pressedOpacity: 0.65,
        sizeStyle: CupertinoButtonSize.large,
        // elevation: 0,
        // highlightElevation: 0,
        // focusElevation: 0,
        // hoverElevation: 0,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
        child: Text(
          buttonText,
          style: isSecondary ? TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Lexend') : TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Lexend'),
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return ConstrainedBox(
  //     constraints: BoxConstraints(minWidth: 160, maxHeight: 50),
  //     child: MaterialButton(
  //       onPressed: onTap,
  //       focusElevation: 20,
  //       child: Container(
  //         width: width,
  //         height: height,
  //         decoration: BoxDecoration(
  //           color: secondary == true ? Colors.transparent : Colors.pinkAccent.shade200,
  //           borderRadius: const BorderRadius.all(Radius.circular(10)),
  //           border: secondary == true ? BoxBorder.all(color: AppColors.textColor, width: 5 / 2, style: BorderStyle.solid, strokeAlign: BorderSide.strokeAlignInside) : null,
  //           boxShadow: secondary == true ? [] : [BoxShadow(color: Colors.pinkAccent.shade200.withAlpha(100), blurRadius: 15, offset: const Offset(0, 0), spreadRadius: 5)],
  //         ),
  //         child: Center(
  //           child: Text(
  //             buttonText,
  //             style: secondary == true ? const TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.w500) : const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
