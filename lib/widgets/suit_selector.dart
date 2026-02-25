import 'dart:math';
import 'package:flutter/material.dart';
import 'package:undealer/models/suit.dart';

class SuitSelector extends StatefulWidget {
  final Suit? selectedSuit;
  final Set<Suit> unavailableSuits;

  const SuitSelector({super.key, this.selectedSuit, this.unavailableSuits = const {}});

  @override
  State<SuitSelector> createState() => _SuitSelectorState();
}

class _SuitSelectorState extends State<SuitSelector> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: _controller,
        child: PhysicalModel(
          color: Colors.white,
          elevation: 20,
          shadowColor: Colors.black,
          shape: BoxShape.circle,
          child: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _RadialMenuPainter(selectedSuit: widget.selectedSuit, unavailableSuits: widget.unavailableSuits),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialMenuPainter extends CustomPainter {
  final Suit? selectedSuit;
  final Set<Suit> unavailableSuits;

  _RadialMenuPainter({this.selectedSuit, required this.unavailableSuits});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 + 20;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw the main red background
    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Define suit properties
    final Map<Suit, Map<String, dynamic>> suitInfo = {
      Suit.hearts: {'angle': -pi / 2, 'symbol': '♥', 'color': Colors.white},
      Suit.diamonds: {'angle': 0, 'symbol': '♦', 'color': Colors.white},
      Suit.clubs: {'angle': pi / 2, 'symbol': '♣', 'color': Colors.white},
      Suit.spades: {'angle': pi, 'symbol': '♠', 'color': Colors.white},
    };

    // 3. Draw highlight for the selected suit (if any)
    if (selectedSuit != null && !unavailableSuits.contains(selectedSuit)) {
      final highlightPaint = Paint()..color = Colors.pinkAccent.withAlpha(30);
      final startAngle = suitInfo[selectedSuit!]!['angle'] - (pi / 4);
      const sweepAngle = pi / 2;
      canvas.drawArc(rect, startAngle, sweepAngle, true, highlightPaint);
    }

    // 4. Draw the dividers
    final dividerPaint = Paint()
      ..color = Colors.grey.withAlpha(40)
      ..strokeWidth = 4;

    canvas.drawLine(center + Offset.fromDirection(-pi / 4, radius), center + Offset.fromDirection(3 * pi / 4, radius), dividerPaint);
    canvas.drawLine(center + Offset.fromDirection(pi / 4, radius), center + Offset.fromDirection(5 * pi / 4, radius), dividerPaint);

    // 5. Draw suit symbols
    suitInfo.forEach((suit, data) {
      final isUnavailable = unavailableSuits.contains(suit);
      final symbolAngle = data['angle'];
      final symbolRadius = radius * 0.5;
      final symbolPosition = center + Offset(cos(symbolAngle) * symbolRadius, sin(symbolAngle) * symbolRadius);

      final textColor = isUnavailable ? (data['color'] as Color).withAlpha(80) : data['color'];

      final textPainter = TextPainter(
        text: TextSpan(
          text: data['symbol'],
          style: TextStyle(fontSize: 30, color: textColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, symbolPosition - Offset(textPainter.width / 2, textPainter.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant _RadialMenuPainter oldDelegate) {
    return oldDelegate.selectedSuit != selectedSuit || oldDelegate.unavailableSuits != unavailableSuits;
  }
}
