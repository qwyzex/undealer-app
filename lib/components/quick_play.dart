import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/components/primary_button.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/screens/table_screen.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'dart:math' as math;

class QuickPlay extends StatelessWidget {
  const QuickPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryLighter, Color(0xFFFAFAFA)]),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          // BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: -20),
          // BoxShadow(color: Colors.black26.withAlpha(10), blurRadius: 10, offset: Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: -17,
            child: Transform.rotate(
              angle: -math.pi / 30,
              child: PokerCard(value: 14, suit: Suit.spades),
            ),
          ),
          Positioned(
            left: 70,
            bottom: -12,
            child: Transform.rotate(
              angle: math.pi / 30,
              child: PokerCard(value: 13, suit: Suit.hearts),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GradientText(
                      "Quick Play!",
                      colors: [AppColors.textColor, AppColors.textColorDim],
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      spacing: 10,
                      children: [
                        PrimaryButton(
                          buttonText: "Play",
                          onTap: () => {
                            // route to table screen
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer'))),
                          },
                        ),
                        PrimaryButton(buttonText: "Settings"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
