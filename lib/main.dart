import 'dart:math';
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
        appBarTheme: const AppBarThemeData(backgroundColor: AppColors.background),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0x00000000)),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Lexend',
      ),
      home: const TableRoom(title: 'undealer'),
    );
  }
}
