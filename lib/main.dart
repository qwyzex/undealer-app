import 'dart:math';
import 'widgets/player_tab.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '/app_state.dart';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/flip_card.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'package:undealer/widgets/suit_selector.dart';

// void main() {
//   runApp(const UndealerApp());
// }

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const UndealerApp(),
    ),
  );
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
  /// Index of the community slot the user is currently editing (via the
  /// value buttons). Only one of [selectingCommunityIndex] or the player
  /// equivalents can be non-null at a time.
  int? selectingCommunityIndex;

  /// When editing a particular player's hole card we store the player index
  /// and which of their two cards (0 or 1) is being targeted.
  int? editingPlayerIndex;
  int? editingPlayerCardIndex;

  OverlayEntry? _overlayEntry;
  Suit? _selectedSuit;
  int? _panningCardValue;
  Offset? _panOrigin;

  /// Helper that forwards to the provider so we consistently account for both
  /// community and player cards when deciding which suits are already used.
  Set<Suit> getUnavailableSuitsForValue(int value) {
    final appState = context.read<AppState>();
    return appState.getUnavailableSuitsForValue(value);
  }

  /// Convenience wrappers that operate on the appState instead of a local
  /// copy.
  void setCommunityCard(int index, int value, Suit suit) {
    context.read<AppState>().setCommunityCard(index, value, suit);
  }

  void clearCard(int index) {
    context.read<AppState>().clearCard(index);
  }

  void setPlayerCard(int playerIndex, int cardIndex, int value, Suit suit) {
    context.read<AppState>().setPlayerCard(playerIndex, cardIndex, value, suit);
  }

  void clearPlayerCard(int playerIndex, int cardIndex) {
    context.read<AppState>().clearPlayerCard(playerIndex, cardIndex);
  }

  void _showSuitSelector(BuildContext context, Offset position, int value) {
    final unavailableSuits = getUnavailableSuitsForValue(value);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy - 60,
        child: SuitSelector(
          selectedSuit: _selectedSuit,
          unavailableSuits: unavailableSuits,
        ),
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
            if (selectingCommunityIndex == null &&
                (editingPlayerIndex == null ||
                    editingPlayerCardIndex == null)) {
              // nothing to edit (either no target or no card chosen)
              return;
            }
            final cardBox = context.findRenderObject() as RenderBox;
            final cardCenter = cardBox.localToGlobal(
              cardBox.size.center(Offset.zero),
            );
            setState(() {
              _panningCardValue = val;
              _panOrigin = cardCenter;
              _selectedSuit = null;
            });
            _showSuitSelector(context, cardCenter, val);
          },
          onPanUpdate: (details) {
            if (selectingCommunityIndex == null &&
                (editingPlayerIndex == null ||
                    editingPlayerCardIndex == null)) {
              return;
            }
            _updateSuitSelection(details.globalPosition, val);
          },
          onPanEnd: (details) {
            if (_selectedSuit != null && _panningCardValue == val) {
              if (selectingCommunityIndex != null) {
                setCommunityCard(selectingCommunityIndex!, val, _selectedSuit!);
                selectingCommunityIndex = null;
              } else if (editingPlayerIndex != null &&
                  editingPlayerCardIndex != null) {
                setPlayerCard(
                  editingPlayerIndex!,
                  editingPlayerCardIndex!,
                  val,
                  _selectedSuit!,
                );
                // keep the player expanded so the other hole card can be set;
                // clear only the card index so a subsequent tap will choose the
                // other card.
                editingPlayerCardIndex = null;
              }
            }
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
      },
    );
  }

  int openedCardTab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF532B2B),
            fontSize: 30,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          onPressed: () => {},
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.menu)),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // tapping anywhere in the body should collapse any expanded player cards
          setState(() {
            editingPlayerIndex = null;
            editingPlayerCardIndex = null;
            selectingCommunityIndex = null;
          });
          context.read<AppState>().collapseAllPlayers();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    valueButton(14),
                    valueButton(2),
                    valueButton(3),
                    valueButton(4),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [valueButton(5), valueButton(6), valueButton(7)],
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [valueButton(8), valueButton(9), valueButton(10)],
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [valueButton(11), valueButton(12), valueButton(13)],
                ),
              ],
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // SWITCH BETWEEN COMMUNITY AND PLAYERS HOLE CARD
                    IconButton(
                      onPressed: () {
                        // clear any active selections/expansions when swapping views
                        context.read<AppState>().collapseAllPlayers();
                        setState(() {
                          openedCardTab = openedCardTab == 1 ? 2 : 1;
                          selectingCommunityIndex = null;
                          editingPlayerIndex = null;
                          editingPlayerCardIndex = null;
                        });
                      },
                      icon: Icon(Icons.spoke_rounded),
                      color: openedCardTab == 1
                          ? Color(0xFFC59090)
                          : Color(0xFF7E5B5B),
                    ),
                    // TEXT DISPLAYING THE CURRENT STAGE OF COMMUNITY CARDS (FLOP, TURN, RIVER)
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: GradientText(
                        'River',
                        gradientDirection: GradientDirection.ttb,
                        colors: [Color(0xFFC59090), Color(0xFF7E5B5B)],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                // EVALUATION LOGIC BUTTON TO DETERMINE THE WINNING HAND
                TextButton(
                  onPressed: () => {},
                  child: GradientText(
                    "EVAL",
                    colors: [Colors.red, Colors.orange],

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: openedCardTab == 2
                  ? PlayerTab(
                      editingPlayerIndex: editingPlayerIndex,
                      editingPlayerCardIndex: editingPlayerCardIndex,
                      onExpand: (playerIndex) {
                        // tapping the top-level card either expands or collapses
                        context.read<AppState>().togglePlayerExpansion(
                          playerIndex,
                        );
                        // when expanding we also clear any community selection
                        setState(() {
                          selectingCommunityIndex = null;
                        });
                      },
                      onSelectCard: (playerIndex, cardIndex) {
                        setState(() {
                          editingPlayerIndex = playerIndex;
                          editingPlayerCardIndex = cardIndex;
                          selectingCommunityIndex = null;
                        });
                      },
                      onClearCard: () => {
                        setState(() {
                          editingPlayerIndex = null;
                          editingPlayerCardIndex = null;
                          selectingCommunityIndex = null;
                        }),
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: List.generate(5, (index) {
                        final appState = context.watch<AppState>();
                        final card = appState.communityCards[index];
                        bool isActive = selectingCommunityIndex == index;
                        bool isDisabled =
                            selectingCommunityIndex != null && !isActive;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()
                            ..translateByVector3(
                              Vector3(0.0, isActive ? -20.0 : 0.0, 0.0),
                            )
                            ..scaleByVector3(Vector3.all(isActive ? 1.1 : 1.0)),
                          child: Opacity(
                            opacity: isDisabled ? 0.35 : 1,
                            child: IgnorePointer(
                              ignoring: isDisabled,
                              child: FlipCard(
                                flipped: card.flipped,
                                locked: card.flipped,
                                onTap: () {
                                  // collapse any open player cards
                                  context.read<AppState>().collapseAllPlayers();
                                  setState(() {
                                    editingPlayerIndex = null;
                                    editingPlayerCardIndex = null;
                                    selectingCommunityIndex = index;
                                  });
                                },
                                onLongPress: () {
                                  clearCard(index);
                                  context.read<AppState>().collapseAllPlayers();
                                  setState(() {
                                    editingPlayerIndex = null;
                                    editingPlayerCardIndex = null;
                                    selectingCommunityIndex = index;
                                  });
                                },
                                front: PokerCard(
                                  value: card.value ?? 0,
                                  suit: card.suit,
                                  small: true,
                                  showBack: false,
                                ),
                                back: const PokerCard(
                                  value: 0,
                                  small: true,
                                  showBack: true,
                                ),
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
