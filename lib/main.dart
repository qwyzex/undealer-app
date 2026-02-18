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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int? selectingIndex;
  List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());

  OverlayEntry? _overlayEntry;
  Suit? _selectedSuit;
  int? _panningCardValue;
  Offset? _panOrigin;

  void _showSuitSelector(BuildContext context, Offset position) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy - 60,
        child: SuitSelector(selectedSuit: _selectedSuit),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeSuitSelector() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateSuitSelection(Offset globalPosition) {
    if (_panOrigin == null) return;

    final offset = globalPosition - _panOrigin!;
    final distance = offset.distance;

    Suit? newSuit;
    if (distance > 20) { // Deadzone
      if (offset.dx.abs() > offset.dy.abs()) {
        newSuit = offset.dx > 0 ? Suit.diamonds : Suit.spades;
      } else {
        newSuit = offset.dy < 0 ? Suit.hearts : Suit.clubs;
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
    return Builder(builder: (context) {
      return GestureDetector(
        onPanStart: (details) {
          if (selectingIndex == null) return;

          final cardBox = context.findRenderObject() as RenderBox;
          final cardCenter = cardBox.localToGlobal(cardBox.size.center(Offset.zero));

          setState(() {
            _panningCardValue = val;
            _panOrigin = cardCenter;
            _selectedSuit = null;
          });

          _showSuitSelector(context, cardCenter);
        },
        onPanUpdate: (details) {
          if (selectingIndex == null) return;
          _updateSuitSelection(details.globalPosition);
        },
        onPanEnd: (details) {
          if (selectingIndex != null && _selectedSuit != null && _panningCardValue == val) {
            setState(() {
              communityCards[selectingIndex!].value = _panningCardValue;
              communityCards[selectingIndex!].suit = _selectedSuit;
              communityCards[selectingIndex!].flipped = true;
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
        onPanCancel: () {
          _removeSuitSelector();
          setState(() {
            _panningCardValue = null;
            _panOrigin = null;
            _selectedSuit = null;
          });
        },
        child: PokerCard(
          value: val,
          suit: _panningCardValue == val ? _selectedSuit : null,
        ),
      );
    });
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [valueButton(14), valueButton(2), valueButton(3), valueButton(4)]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [valueButton(5), valueButton(6), valueButton(7)]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [valueButton(8), valueButton(9), valueButton(10)]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [valueButton(11), valueButton(12), valueButton(13)]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 2.0,
        height: 200,
        padding: const EdgeInsets.all(0),
        color: const Color(0x00000000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: GradientText(
                'River',
                gradientDirection: GradientDirection.ttb,
                colors: const [Color(0xFFC59090), Color(0xFF7E5B5B)],
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final card = communityCards[index];
                  bool isActive = selectingIndex == index;
                  bool isDisabled = selectingIndex != null && selectingIndex != index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..translate(isActive ? -6.0 : 0.0, isActive ? -30.0 : 0.0)
                      ..scale(isActive ? 1.15 : 1.0),
                    child: Opacity(
                      opacity: isDisabled ? 0.35 : 1,
                      child: IgnorePointer(
                        ignoring: isDisabled,
                        child: FlipCard(
                          flipped: card.flipped,
                          locked: card.flipped,
                          onTap: () {
                            if (card.value == null) {
                              setState(() {
                                selectingIndex = index;
                              });
                            }
                          },
                          onLongPress: () {
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
