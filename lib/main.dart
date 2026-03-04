import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:undealer/screens/home_screen.dart';
import 'package:undealer/theme/colors.dart';
import '/app_state.dart';

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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.focusedBorderColor, width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 3),
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
      home: const HomeScreen(),
    );
  }
}
