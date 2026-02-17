import 'dart:math';

// import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
// import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class AppColors {
  static const Color primary = Color(0xFFFFE5C7);
  static const Color primaryLighter = Color.fromARGB(255, 243, 227, 206);
  static const Color secondary = Color(0xFFDC8282);
  static const Color buttonBackground = Color(0xFFFFE5C7);
  static const Color background = Color(0xFFFFE7CF);
  static const Color textColor = Color(0xFF604a24);
  static const Color textColorDim = Color(0xFFAC987C);
  static const Color focusedBorderColor = Color(0xFF897558);
}

void main() {
  runApp(const UndealerApp());
}

class UndealerApp extends StatelessWidget {
  const UndealerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undealer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        appBarTheme: const AppBarThemeData(
          backgroundColor: AppColors.background,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0x00000000),
        ),

        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Lexend',
      ),
      home: const MyHomePage(title: 'undealer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget pokerCard(String label) {
    return Container(
      width: 84,
      height: 120,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.black),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 4,
            blurRadius: 10,
            offset: Offset(1, 6), // X and Y offsets
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
        child: GradientText(
          label,
          style: TextStyle(fontSize: 42.0, fontWeight: FontWeight.w900),
          gradientDirection: GradientDirection.btt,
          // gradientType: GradientType.linear,
          colors: [Color(0xFF3A1A1A), Color(0xFFA16D6D)],
        ),
      ),
      // Text(
      //   label,
      //   style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF532B2B),
            fontSize: 30,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          onPressed: () => {},
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.menu))],
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Row 1 (4 cards)
              Row(
                spacing: 8.0,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  pokerCard("A"),
                  pokerCard("2"),
                  pokerCard("3"),
                  pokerCard("4"),
                ],
              ),

              const SizedBox(height: 12),

              // Row 2 (3 cards)
              Row(
                spacing: 8.0,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [pokerCard("5"), pokerCard("6"), pokerCard("7")],
              ),

              const SizedBox(height: 12),

              // Row 3 (3 cards)
              Row(
                spacing: 8.0,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [pokerCard("8"), pokerCard("9"), pokerCard("10")],
              ),

              const SizedBox(height: 12),

              // Row 4 (3 cards)
              Row(
                spacing: 8.0,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [pokerCard("J"), pokerCard("Q"), pokerCard("K")],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 2.0,
        height: 150,
        padding: const EdgeInsets.all(0),

        // color: Colors.amber,
        color: Color(0x00000000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            GradientText(
              'River',
              gradientDirection: GradientDirection.ttb,
              colors: [Color(0xFFC59090), Color(0xFF7E5B5B)],
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: Container(
                // color: Colors.cyan,
                // decoration: BoxDecoration(boxShadow: BoxShadow(
                //
                // )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
