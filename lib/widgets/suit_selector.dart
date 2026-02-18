import 'dart:math';
import 'package:flutter/material.dart';
import 'package:undealer/models/suit.dart';

class SuitSelector extends StatefulWidget {
  final Suit? selectedSuit;

  const SuitSelector({super.key, this.selectedSuit});

  @override
  State<SuitSelector> createState() => _SuitSelectorState();
}

class _SuitSelectorState extends State<SuitSelector> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..forward();
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
        child: SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _RadialMenuPainter(selectedSuit: widget.selectedSuit),
          ),
        ),
      ),
    );
  }
}

class _RadialMenuPainter extends CustomPainter {
  final Suit? selectedSuit;

  _RadialMenuPainter({this.selectedSuit});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 40.0;

    final Map<Suit, Map<String, dynamic>> suitInfo = {
      Suit.hearts: {
        'offset': Offset(center.dx, center.dy - radius),
        'symbol': '♥',
        'color': Colors.red.shade700
      },
      Suit.spades: {
        'offset': Offset(center.dx - radius, center.dy),
        'symbol': '♠',
        'color': Colors.black87
      },
      Suit.diamonds: {
        'offset': Offset(center.dx + radius, center.dy),
        'symbol': '♦',
        'color': Colors.red.shade700
      },
      Suit.clubs: {
        'offset': Offset(center.dx, center.dy + radius),
        'symbol': '♣',
        'color': Colors.black87
      },
    };

    final bgPaint = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(center, radius + 25, bgPaint);

    suitInfo.forEach((suit, data) {
      final isSelected = selectedSuit == suit;
      final selectedPaint = Paint()..color = Colors.blue.withOpacity(0.4);

      if (isSelected) {
        canvas.drawCircle(data['offset'], 22, selectedPaint);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: data['symbol'],
          style: TextStyle(
            fontSize: 32,
            color: data['color'],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
          canvas, data['offset'] - Offset(textPainter.width / 2, textPainter.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
