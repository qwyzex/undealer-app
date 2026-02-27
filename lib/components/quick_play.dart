import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:undealer/theme/colors.dart';

class QuickPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26.withAlpha(10), blurRadius: 10, offset: Offset(0, 10))],
      ),
    );
  }
}
