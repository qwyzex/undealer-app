import 'dart:math';
import 'package:undealer/logic/derangedShuffle.dart';
import 'package:undealer/widgets/player_tab.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '/app_state.dart';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:undealer/models/suit.dart';
import 'package:undealer/widgets/flip_card.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'package:undealer/widgets/suit_selector.dart';

class TableRoom extends StatefulWidget {
  const TableRoom({super.key, required this.title});

  final String title;

  @override
  State<TableRoom> createState() => _TableRoomState();
}

class _TableRoomState extends State<TableRoom> {
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

  List<int> _cardValueOrder = [14, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

  void _shuffleCardOrder() {
    _cardValueOrder = derangedShuffle(_cardValueOrder);
  }

  void _resetCardOrder() {
    _cardValueOrder = [14, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
  }

  /// Helper that forwards to the provider so we consistently account for both
  /// community and player cards when deciding which suits are already used.
  Set<Suit> getUnavailableSuitsForValue(int value) {
    final appState = context.read<AppState>();
    return appState.getUnavailableSuitsForValue(
      value,
      playerIndex: editingPlayerIndex,
      cardIndex: editingPlayerCardIndex,
      communityIndex: selectingCommunityIndex,
    );
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

  void _showSuitSelector(
    BuildContext context,
    Offset position,
    int value,
    bool hideAssignedCardFromPlayer,
  ) {
    final unavailableSuits = getUnavailableSuitsForValue(value);
    bool isAssigningPlayerCard = (editingPlayerIndex != null && editingPlayerCardIndex != null);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy - 60,
        child: SuitSelector(
          selectedSuit: _selectedSuit,
          unavailableSuits: unavailableSuits,
          letDuplicateCards: hideAssignedCardFromPlayer && isAssigningPlayerCard ? true : false,
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
      const quarterPi = pi / 4;

      // Deadzone
      double angle = atan2(offset.dy, offset.dx);
      if (angle < 0) {
        angle += 2 * pi;
      }

      if (angle >= 7 * quarterPi || angle < quarterPi) {
        newSuit = Suit.diamonds;
      } else if (angle >= quarterPi && angle < 3 * quarterPi) {
        newSuit = Suit.clubs;
      } else if (angle >= 3 * quarterPi && angle < 5 * quarterPi) {
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

  Widget valueButton(int val, bool hideAssignedCardFromPlayer) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onPanStart: (details) {
            if (selectingCommunityIndex == null &&
                (editingPlayerIndex == null || editingPlayerCardIndex == null)) {
              // nothing to edit (either no target or no card chosen)
              return;
            }
            final cardBox = context.findRenderObject() as RenderBox;
            final cardCenter = cardBox.localToGlobal(cardBox.size.center(Offset.zero));
            setState(() {
              _panningCardValue = val;
              _panOrigin = cardCenter;
              _selectedSuit = null;
            });
            _showSuitSelector(context, cardCenter, val, hideAssignedCardFromPlayer);
          },
          onPanUpdate: (details) {
            if (selectingCommunityIndex == null &&
                (editingPlayerIndex == null || editingPlayerCardIndex == null)) {
              return;
            }
            _updateSuitSelection(details.globalPosition, val);
          },
          onPanEnd: (details) {
            if (_selectedSuit != null && _panningCardValue == val) {
              if (selectingCommunityIndex != null) {
                setCommunityCard(selectingCommunityIndex!, val, _selectedSuit!);
                selectingCommunityIndex = null;
              } else if (editingPlayerIndex != null && editingPlayerCardIndex != null) {
                setPlayerCard(editingPlayerIndex!, editingPlayerCardIndex!, val, _selectedSuit!);
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
              _resetCardOrder();
            });
          },
          child: PokerCard(value: val, suit: _panningCardValue == val ? _selectedSuit : null),
        );
      },
    );
  }

  int openedCardTab = 1;

  String getStage(int tableStage) {
    switch (tableStage) {
      case 0:
        return "Flop";
      case 1:
        return "Turn";
      case 2:
        return "River";
      default:
        return "Table";
    }
  }

  void handleLongPressCommunityCard(int index) {
    clearCard(index);
    context.read<AppState>().collapseAllPlayers();
    setState(() {
      editingPlayerIndex = null;
      editingPlayerCardIndex = null;
      selectingCommunityIndex = index;
      _resetCardOrder();
    });
  }

  OverlayEntry? _nameOverlayEntry;
  final TextEditingController _nameController = TextEditingController();

  void _showChangeNameOverlay(int index) {
    final appState = context.read<AppState>();
    _nameController.text = appState.players[index].playerName ?? "P${index + 1}";

    _nameOverlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Change Player ${index + 1} Name",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter 1-3 chars",
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: _hideChangeNameOverlay, child: const Text("Cancel")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final newName = _nameController.text.trim();
                        if (newName.isNotEmpty && newName.length <= 3) {
                          appState.changePlayerName(index, newName);
                          _hideChangeNameOverlay();
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_nameOverlayEntry!);
  }

  void _hideChangeNameOverlay() {
    _nameOverlayEntry?.remove();
    _nameOverlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    bool hideAssignedCardFromPlayer = appState.gameOptions.playerAssignTheirOwnCard;

    //*************************************************************************//

    void switchTab() {
      appState.collapseAllPlayers();
      setState(() {
        _resetCardOrder();
        openedCardTab = openedCardTab == 1 ? 2 : 1;
        selectingCommunityIndex = null;
        editingPlayerIndex = null;
        editingPlayerCardIndex = null;
      });
    }

    //*************************************************************************//

    Widget buildTableCards() {
      List<Widget> plainCards = _cardValueOrder
          .map((val) => valueButton(val, hideAssignedCardFromPlayer))
          .toList();

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(spacing: 8, children: [plainCards[0], plainCards[1], plainCards[2], plainCards[3]]),
          const SizedBox(height: 12),
          Row(spacing: 8, children: [plainCards[4], plainCards[5], plainCards[6]]),
          const SizedBox(height: 12),
          Row(spacing: 8, children: [plainCards[7], plainCards[8], plainCards[9]]),
          const SizedBox(height: 12),
          Row(spacing: 8, children: [plainCards[10], plainCards[11], plainCards[12]]),
        ],
      );
    }

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
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [IconButton(onPressed: () => {}, icon: const Icon(Icons.menu))],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // tapping anywhere in the body should collapse any expanded player cards
          setState(() {
            editingPlayerIndex = null;
            editingPlayerCardIndex = null;
            selectingCommunityIndex = null;
            _resetCardOrder();
          });
          appState.collapseAllPlayers();
        },
        child: Center(
          child: Padding(padding: const EdgeInsets.all(25.0), child: buildTableCards()),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // SWITCH BETWEEN COMMUNITY AND PLAYERS HOLE CARD
                    IconButton(
                      onPressed: switchTab,
                      icon: Icon(Icons.icecream, size: 40),
                      color: openedCardTab == 1 ? Color(0xFFC59090) : Color(0xFF7E5B5B),
                    ),
                    // TEXT DISPLAYING THE CURRENT STAGE OF COMMUNITY CARDS (FLOP, TURN, RIVER)
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: GradientText(
                        getStage(appState.tableStage),
                        gradientDirection: GradientDirection.ttb,
                        colors: [Color(0xFFC59090), Color(0xFF7E5B5B)],
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                // TODO: Replace evaluation UI and add logic
                // EVALUATION LOGIC BUTTON TO DETERMINE THE WINNING HAND
                TextButton(
                  onPressed: () => {print("POPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOP")},
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
                        appState.togglePlayerExpansion(playerIndex);
                        setState(() {
                          selectingCommunityIndex = null;
                          editingPlayerIndex = null;
                          editingPlayerCardIndex = null;
                          _resetCardOrder();
                        });
                      },
                      onChangeName: (index) {
                        _showChangeNameOverlay(index);
                      },
                      onSelectCard: (playerIndex, cardIndex) {
                        setState(() {
                          if (appState.gameOptions.playerAssignTheirOwnCard) {
                            _shuffleCardOrder();
                          }
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
                          _resetCardOrder();
                        }),
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: List.generate(5, (index) {
                        final card = appState.communityCards[index];
                        bool isActive = selectingCommunityIndex == index;

                        bool isCardDisabledForSelection =
                            selectingCommunityIndex != null && !isActive;
                        bool isCardDisabledByStage =
                            (appState.tableStage == 0 && index > 2) ||
                            (appState.tableStage == 1 && index > 3);
                        bool isDisabled = isCardDisabledForSelection || isCardDisabledByStage;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          transform: Matrix4.identity()
                            ..translateByVector3(
                              Vector3(isActive ? -8 : 0, isActive ? -15.0 : 0.0, 0.0),
                            )
                            ..scaleByVector3(Vector3.all(isActive ? 1.2 : 1.0)),
                          child: Opacity(
                            opacity: isDisabled ? 0.4 : 1,
                            child: IgnorePointer(
                              ignoring: isDisabled,
                              child: FlipCard(
                                flipped: card.flipped,
                                locked: card.flipped,
                                front: PokerCard(
                                  value: card.value ?? 0,
                                  suit: card.suit,
                                  small: true,
                                  showBack: false,
                                ),
                                back: const PokerCard(value: 0, small: true, showBack: true),
                                onTap: () {
                                  appState.collapseAllPlayers();
                                  setState(() {
                                    editingPlayerIndex = null;
                                    editingPlayerCardIndex = null;

                                    if (isActive) {
                                      selectingCommunityIndex = null;
                                    } else {
                                      selectingCommunityIndex = index;
                                    }

                                    _resetCardOrder();
                                  });
                                },
                                onCancelPress: RadialFunctionCall(() => {}, "CANCEL"),
                                onActionOne: RadialFunctionCall(() => {}, "CANCEL"),
                                onActionTwo: RadialFunctionCall(() {
                                  handleLongPressCommunityCard(index);
                                }, "RESET"),
                                quickRadialCall: true,
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
