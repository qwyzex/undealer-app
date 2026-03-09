import 'package:flutter/material.dart';

class AppColors {
  static const Color transparent = Color(0x00000000);
  static const Color primary = Color(0xFFFFE5C7);
  static const Color primaryLighter = Color.fromARGB(255, 231, 218, 205);
  static const Color secondary = Color(0xFFDC8282);
  static const Color accentPink = Colors.pinkAccent;
  static const Color background = Color(0xFFFFE7CF);
  static const Color textColor = Color(0xFF604a24);
  static const Color textColorDim = Color(0xFFAC987C);

  // GRADIENT
  static const List<Color> gradientCopper = [Color(0xFF3A1A1A), Color(0xFFA16D6D)];
  static const List<Color> gradientSeamless = [Color(0xFFFFE7CF), Color(0xFFE8B083)];

  static const Color deepShade = Color(0xFFDAD1C1);
  static const Color deepShadeHeavy = Color(0xFFB9B6AD);
  static const Color border = Color(0xFF897558);
  static const Color focusedBorderColor = Color(0xFF897558);

  // SUITS
  static const Color suitsRed = Color(0xFFC22B2B);
  static const Color suitsBlack = Color(0xFF1A1A1A);
  static const Color hearts = Color(0xFFC22B2B);
  static const Color diamonds = Color(0xFFC22B2B);
  static const Color clubs = Color(0xFF1A1A1A);
  static const Color spades = Color(0xFF1A1A1A);

  // BUTTONS
  static final Color buttonPrimaryColor = Colors.pinkAccent.shade200;
  static final Color buttonPrimaryShadowColor = Colors.pinkAccent.shade200.withAlpha(60);
  static const Color buttonPrimaryTextColor = Color(0xFFFFFFFF);
  static const Color buttonSecondaryColor = Color(0x00000000);
  static const Color buttonSecondaryTextColor = AppColors.textColor;

  // QUICKPLAY WIDGET
  static const Color quickPlayShimmerOne = Color(0xFFECECEC);
  static const Color quickPlayShimmerTwo = Color(0xFFF8F0E0);

  // CARD WIDGET
  static const Color circularProgressFore = Color(0x70FFFFFF);
  static const Color circularProgressBack = Color(0x26000000);
  static const Color cardBackBackground = Color(0xFF493123);

  // PLAYER OPTION MENU WIDGET
  static final Color playerOptionOverlay = Colors.black.withAlpha(40);
  static const Color playerOptionMenuBackground = AppColors.primaryLighter;

  // ARBITRARY
  static const Color tooltipTextColor = Color(0xFFFFFFFF);
  static const Color danger = Colors.redAccent;
  static final Color dangerLight = Colors.red.shade100;
  static const Color indicatorTrue = Color(0xFF8EE041);
  static const Color indicatorFalse = Color(0xFFE0228A);
  static const Color indicatorRing = Color(0xFF3A1A1A);
}
