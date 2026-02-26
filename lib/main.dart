import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:undealer/screens/home_screen.dart';

import 'widgets/player_tab.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '/app_state.dart';
import 'package:undealer/screens/table_screen.dart';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/flip_card.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'package:undealer/widgets/suit_selector.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const UndealerApp()));
}

class UndealerApp extends StatelessWidget {
  const UndealerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undealer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        useMaterial3: true,
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.background),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: AppColors.textColorDim),
          filled: true,
          fillColor: AppColors.primaryLighter,
          // Border properties
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.transparent, // Default border color
              width: 3, // Change thickness here
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.focusedBorderColor, // Color when focused
              width: 3, // Change thickness here
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red, // Color for error state
              width: 3, // Change thickness here
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(color: AppColors.background),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColors.textColor)),
        cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(color: AppColors.textColor, fontFamily: 'Lexend'),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.textColor,
          unselectedLabelColor: AppColors.textColorDim,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: AppColors.textColor, width: 3.0),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          ),
        ),
        primaryColor: AppColors.primary,
      ),
      // ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
      //   appBarTheme: const AppBarThemeData(backgroundColor: AppColors.background),
      //   bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0x00000000)),
      //   useMaterial3: true,
      //   scaffoldBackgroundColor: AppColors.background,
      //   fontFamily: 'Lexend',
      // ),
      home: const HomeScreen(),
      // home: const TableRoom(title: 'undealer'),
    );
  }
}
