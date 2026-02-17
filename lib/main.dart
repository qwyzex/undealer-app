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
        appBarTheme: const AppBarThemeData(backgroundColor: AppColors.background),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0x00000000)),

        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Lexend',
      ),
      home: const MyHomePage(title: 'undealer'),
    );
  }
}

class CommunityCardData {
  String? value; // null = not assigned
  bool flipped;

  CommunityCardData({this.value, this.flipped = false});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// POKER CARD
class PokerCard extends StatelessWidget {
  final String label;
  final bool small;
  final bool showBack;

  const PokerCard({super.key, required this.label, this.small = false, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    double widthVal = small ? 70 : 84;
    double heightVal = small ? 98 : 120;
    double fontSizeVal = small ? 34 : 42;

    return Container(
      width: widthVal,
      height: heightVal,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: showBack ? const Color(0xFF3A1A1A) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 4, blurRadius: 10, offset: const Offset(1, 6))],
      ),
      child: showBack
          ? const Center(child: Icon(Icons.casino, color: Colors.white, size: 28))
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: GradientText(
                label,
                style: TextStyle(fontSize: fontSizeVal, fontWeight: FontWeight.w900),
                gradientDirection: GradientDirection.btt,
                colors: const [Color(0xFF3A1A1A), Color(0xFFA16D6D)],
              ),
            ),
    );
  }
}

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool locked;
  final VoidCallback? onTap;

  const FlipCard({super.key, required this.front, required this.back, this.locked = false, this.onTap});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  bool isFront = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  void flip() {
    if (isFront) return; // prevent flipping back

    controller.forward();
    isFront = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.locked) return;

        if (!isFront) {
          widget.onTap?.call(); // notify parent before flip
        }

        flip();
      },
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final angle = animation.value * 3.1416;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: animation.value < 0.5 ? widget.back : Transform(alignment: Alignment.center, transform: Matrix4.rotationY(3.1416), child: widget.front),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int? selectingIndex; // which card currently being assigned

  List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());

  Widget pokerCard(String label, [bool small = false, bool showBack = false]) {
    double widthVal = small ? 70 : 84;
    double heightVal = small ? 98 : 120;
    double fontSizeVal = small ? 34 : 42;

    return Container(
      width: widthVal,
      height: heightVal,
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
          style: TextStyle(fontSize: fontSizeVal, fontWeight: FontWeight.w900),
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

  Widget valueButton(String val) {
    return GestureDetector(
      onTap: () {
        if (selectingIndex == null) return;

        setState(() {
          communityCards[selectingIndex!].value = val;
          communityCards[selectingIndex!].flipped = true;
          selectingIndex = null;
        });
      },
      child: PokerCard(label: val),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF532B2B), fontSize: 30, letterSpacing: 2),
        ),
        leading: IconButton(onPressed: () => {}, icon: Icon(Icons.arrow_back_ios)),
        actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.menu))],
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(spacing: 8, children: [valueButton("A"), valueButton("2"), valueButton("3"), valueButton("4")]),
              const SizedBox(height: 12),
              Row(spacing: 8, children: [valueButton("5"), valueButton("6"), valueButton("7")]),
              const SizedBox(height: 12),
              Row(spacing: 8, children: [valueButton("8"), valueButton("9"), valueButton("10")]),
              const SizedBox(height: 12),
              Row(spacing: 8, children: [valueButton("J"), valueButton("Q"), valueButton("K")]),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 2.0,
        height: 200,
        padding: const EdgeInsets.all(0),

        // color: Colors.amber,
        color: Color(0x00000000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: GradientText(
                'River',
                gradientDirection: GradientDirection.ttb,
                colors: [Color(0xFFC59090), Color(0xFF7E5B5B)],
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: List.generate(5, (index) {
                  final card = communityCards[index];

                  return FlipCard(
                    locked: card.flipped,
                    onTap: () {
                      if (card.value == null) {
                        setState(() {
                          selectingIndex = index;
                        });
                      }
                    },
                    front: PokerCard(label: card.value ?? '', small: true, showBack: false),
                    back: PokerCard(label: '', small: true, showBack: true),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
