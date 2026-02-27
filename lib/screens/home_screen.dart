import 'package:flutter/cupertino.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/components/quick_play.dart';
import 'package:undealer/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFde896b), Color(0xFFF4E9DE)]),

      appBar: AppBar(
        title: Text("undealer"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w700, fontSize: 30, color: AppColors.primary),
      ),

      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 1,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return QuickPlay();
              },
            ),

            // Floating bottom bar
            Align(alignment: Alignment.bottomCenter, child: _FloatingBottomBar()),
          ],
        ),
      ),
    );
  }
}

class _FloatingBottomBar extends StatefulWidget {
  @override
  State<_FloatingBottomBar> createState() => _FloatingBottomBarState();
}

class _FloatingBottomBarState extends State<_FloatingBottomBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 180,
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.15 * 255).floor()), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            duration: Duration(milliseconds: 150),
            // curve: Curves.elasticOut,
            curve: Cubic(0.2, 0.9, 0.3, 1.15),
            child: Container(
              width: 85,
              decoration: BoxDecoration(color: AppColors.textColor, borderRadius: BorderRadius.circular(40)),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildItem(Icons.home, 0), _buildItem(Icons.settings, 1)]),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        // duration: const Duration(milliseconds: 250),
        // curve: Curves.easeInOut,
        // decoration: BoxDecoration(color: isSelected ? const Color(0xFF9C5A2E) : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Icon(icon, color: isSelected ? AppColors.background : AppColors.textColor, size: 25),
      ),
    );
  }
}
