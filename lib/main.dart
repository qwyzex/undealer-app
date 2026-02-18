import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/models/card_model.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/flip_card.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'package:undealer/widgets/suit_selector.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? selectingIndex;

  final List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());

  OverlayEntry? _overlayEntry;
  Suit? _selectedSuit;
  int? _panningCardValue;
  Offset? _panOrigin;

  Set<Suit> getUnavailableSuitsForValue(int value) {
    final Set<Suit> unavailable = {};
    for (var card in communityCards) {
      if (card.value == value && card.suit != null) {
        unavailable.add(card.suit!);
      }
    }
    return unavailable;
  }

  void setCommunityCard(int index, int value, Suit suit) {
    setState(() {
      communityCards[index].value = value;
      communityCards[index].suit = suit;
      communityCards[index].flipped = true;
    });
  }

  void clearCard(int index) {
    setState(() {
      communityCards[index] = CommunityCardData();
    });
  }

  void _showSuitSelector(BuildContext context, Offset position, int value) {
    final unavailableSuits = getUnavailableSuitsForValue(value);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy - 60,
        child: SuitSelector(selectedSuit: _selectedSuit, unavailableSuits: unavailableSuits),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeSuitSelector() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateSuitSelection(Offset globalPosition, int value) {
    if (_panOrigin == null) {
      return;
    }

    final unavailableSuits = getUnavailableSuitsForValue(value);
    final offset = globalPosition - _panOrigin!;
    final distance = offset.distance;

    Suit? newSuit;
    if (distance > 20) {
      // Deadzone
      double angle = atan2(offset.dy, offset.dx);
      if (angle < 0) {
        angle += 2 * pi;
      }

      if (angle >= 7 * pi / 4 || angle < pi / 4) {
        newSuit = Suit.diamonds;
      } else if (angle >= pi / 4 && angle < 3 * pi / 4) {
        newSuit = Suit.clubs;
      } else if (angle >= 3 * pi / 4 && angle < 5 * pi / 4) {
        newSuit = Suit.spades;
      } else {
        newSuit = Suit.hearts;
      }

      if (unavailableSuits.contains(newSuit)) {
        newSuit = null;
      }
    }

    if (newSuit != _selectedSuit) {
      setState(() {
        _selectedSuit = newSuit;
      });
      _overlayEntry?.markNeedsBuild();
    }
  }

  Widget valueButton(int val) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onPanStart: (details) {
            if (selectingIndex == null) {
              return;
            }
            final cardBox = context.findRenderObject() as RenderBox;
            final cardCenter = cardBox.localToGlobal(cardBox.size.center(Offset.zero));
            setState(() {
              _panningCardValue = val;
              _panOrigin = cardCenter;
              _selectedSuit = null;
            });
            _showSuitSelector(context, cardCenter, val);
          },
          onPanUpdate: (details) {
            if (selectingIndex == null) {
              return;
            }
            _updateSuitSelection(details.globalPosition, val);
          },
          onPanEnd: (details) {
            if (selectingIndex != null && _selectedSuit != null && _panningCardValue == val) {
              setCommunityCard(selectingIndex!, val, _selectedSuit!);
              setState(() {
                selectingIndex = null;
              });
            }
            _removeSuitSelector();
            setState(() {
              _panningCardValue = null;
              _panOrigin = null;
              _selectedSuit = null;
            });
          },
          child: PokerCard(value: val, suit: _panningCardValue == val ? _selectedSuit : null),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF532B2B), fontSize: 30, letterSpacing: 2),
        ),
        leading: IconButton(onPressed: () => {}, icon: const Icon(Icons.arrow_back_ios)),
        actions: [IconButton(onPressed: () => {}, icon: const Icon(Icons.menu))],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(spacing: 8, children: [valueButton(14), valueButton(2), valueButton(3), valueButton(4)]),
              const SizedBox(height: 12),
              Row(spacing: 8, children: [valueButton(5), valueButton(6), valueButton(7)]),
              const SizedBox(height: 12),
              Row(spacing: 8, children: [valueButton(8), valueButton(9), valueButton(10)]),
              const SizedBox(height: 12),
              Row(spacing: 8, children: [valueButton(11), valueButton(12), valueButton(13)]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 200,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                  bool isActive = selectingIndex == index;
                  bool isDisabled = selectingIndex != null && !isActive;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..translate(0.0, isActive ? -20.0 : 0.0, 0.0)
                      ..scale(isActive ? 1.1 : 1.0),
                    child: Opacity(
                      opacity: isDisabled ? 0.35 : 1,
                      child: IgnorePointer(
                        ignoring: isDisabled,
                        child: FlipCard(
                          flipped: card.flipped,
                          locked: card.flipped,
                          onTap: () => setState(() => selectingIndex = index),
                          onLongPress: () {
                            clearCard(index);
                            setState(() {
                              selectingIndex = index;
                            });
                          },
                          front: PokerCard(value: card.value ?? 0, suit: card.suit, small: true, showBack: false),
                          back: const PokerCard(value: 0, small: true, showBack: true),
                        ),
                      ),
                    ),
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
