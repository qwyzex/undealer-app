import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/models/suit.dart';

// POKER CARD
class PokerCard extends StatelessWidget {
  final int value;
  final Suit? suit;
  final bool small;
  final bool showBack;

  const PokerCard({
    super.key,
    required this.value,
    this.suit,
    this.small = false,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    double widthVal = small ? 70 : 84;
    double heightVal = small ? 98 : 120;
    double fontSizeVal = small ? 34 : 42;

    String valOf(number) {
      switch (number) {
        case 2:
          return "2";
        case 3:
          return "3";
        case 4:
          return "4";
        case 5:
          return "5";
        case 6:
          return "6";
        case 7:
          return "7";
        case 8:
          return "8";
        case 9:
          return "9";
        case 10:
          return "10";
        case 11:
          return "J";
        case 12:
          return "Q";
        case 13:
          return "K";
        case 14:
          return "A";
      }

      return "";
    }

    String getSuitSymbol(Suit? s) {
      if (s == null) return "";
      switch (s) {
        case Suit.hearts:
          return "♥";
        case Suit.diamonds:
          return "♦";
        case Suit.clubs:
          return "♣";
        case Suit.spades:
          return "♠";
      }
    }

    Color getSuitColor(Suit? s) {
      if (s == null) return Colors.black;
      switch (s) {
        case Suit.hearts:
        case Suit.diamonds:
          return const Color(0xFFC22B2B); // A bit darker red
        case Suit.clubs:
        case Suit.spades:
          return const Color(0xFF1A1A1A); // Almost black
      }
    }

    Widget valueWidget;
    if (suit == null) {
      valueWidget = GradientText(
        valOf(value),
        style: TextStyle(fontSize: fontSizeVal, fontWeight: FontWeight.w900),
        gradientDirection: GradientDirection.btt,
        colors: const [Color(0xFF3A1A1A), Color(0xFFA16D6D)],
      );
    } else {
      valueWidget = Text(
        valOf(value),
        style: TextStyle(
          fontSize: fontSizeVal,
          fontWeight: FontWeight.w900,
          color: getSuitColor(suit),
        ),
      );
    }

    return Container(
      width: widthVal,
      height: heightVal,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: showBack ? const Color(0xFF3A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(1, 6),
          ),
        ],
      ),
      child: showBack
          ? const Center(
              child: Icon(Icons.casino, color: Colors.white, size: 28),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  valueWidget,
                  if (suit != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text(
                        getSuitSymbol(suit),
                        style: TextStyle(
                          fontSize: small ? 18 : 22,
                          color: getSuitColor(suit),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
