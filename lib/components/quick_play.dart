import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/app_state.dart';
import 'package:undealer/components/primary_button.dart';
import 'package:undealer/components/secondary_buttons.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/screens/table_screen.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'dart:math' as math;

class QuickPlay extends StatelessWidget {
  const QuickPlay({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Container(
      margin: const EdgeInsets.all(30),
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryLighter, Color(0xFFFAFAFA)]),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: -17,
            child: Transform.rotate(
              angle: -math.pi / 30,
              child: const PokerCard(value: 14, suit: Suit.spades),
            ),
          ),
          Positioned(
            left: 70,
            bottom: -12,
            child: Transform.rotate(
              angle: math.pi / 30,
              child: const PokerCard(value: 13, suit: Suit.hearts),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GradientText(
                      "Quick Play!",
                      colors: const [AppColors.textColor, AppColors.textColorDim],
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        if (appState.hasSavedGame) ...[
                          PrimaryButton(
                            buttonText: "Continue",
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
                            },
                          ),
                          SecondaryButton(
                            buttonText: "New Game",
                            onTap: () {
                              appState.resetGame();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
                            },
                          ),
                        ] else ...[
                          PrimaryButton(
                            buttonText: "Play",
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
                            },
                          ),
                          const SecondaryButton(buttonText: "Settings"),
                        ],
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
