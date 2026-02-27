import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String buttonText;

  PrimaryButton({required this.buttonText});

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState(buttonText: buttonText);
}

class _PrimaryButtonState extends State<PrimaryButton> {
  final String buttonText;

  _PrimaryButtonState({required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      width: 160,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade200,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [BoxShadow(color: Colors.pinkAccent.shade200.withAlpha(100), blurRadius: 15, offset: Offset(0, 0), spreadRadius: 5)],
      ),
      child: Center(
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
