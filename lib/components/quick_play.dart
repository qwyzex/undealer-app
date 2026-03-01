import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/app_state.dart';
import 'package:undealer/components/primary_button.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/screens/game_options_screen.dart';
import 'package:undealer/screens/table_screen.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'dart:math' as math;

class QuickPlay extends StatelessWidget {
  const QuickPlay({super.key});

  Future<void> delayCardUIUpdate(BuildContext context, AppState appState) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
    await Future.delayed(const Duration(milliseconds: 25));
    appState.resetGame();
  }

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
              child: PokerCard(value: context.read<AppState>().communityCards[3].value ?? 14, suit: context.read<AppState>().communityCards[3].suit ?? Suit.spades),
            ),
          ),
          Positioned(
            left: 70,
            bottom: -12,
            child: Transform.rotate(
              angle: math.pi / 30,
              child: PokerCard(value: context.read<AppState>().communityCards[4].value ?? 13, suit: context.read<AppState>().communityCards[4].suit ?? Suit.hearts),
            ),
          ),
          Positioned.fill(
            child: Padding(
              // padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
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
                            width: 160,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
                            },
                          ),
                          PrimaryButton(
                            secondary: true,
                            buttonText: "New Game",
                            width: 160,
                            onTap: () {
                              delayCardUIUpdate(context, appState);
                            },
                          ),
                        ] else ...[
                          PrimaryButton(
                            buttonText: "Play",
                            // width: 160,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
                            },
                          ),
                          PrimaryButton(
                            secondary: true,
                            buttonText: "Customize",
                            width: 160,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const GameOptionsScreen()));
                            },
                          ),
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
