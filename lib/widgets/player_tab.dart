import 'package:flutter/material.dart';
import 'package:undealer/theme/colors.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'package:undealer/models/card_model.dart';
import 'flip_card.dart';
import 'poker_card.dart';

class PlayerTab extends StatelessWidget {
  /// Index of the player that is currently being edited, or null if none.
  final int? editingPlayerIndex;

  /// Which card of the player is being edited (0 or 1).
  final int? editingPlayerCardIndex;

  /// Called when the user taps the collapsed player card to toggle expansion.
  final void Function(int playerIndex) onExpand;

  /// Called when the user taps one of two cards while the player is expanded.
  final void Function(int playerIndex, int cardIndex) onSelectCard;

  /// Called when the user taps an already active card to clear the selection.
  final void Function() onClearCard;

  const PlayerTab({
    super.key,
    required this.editingPlayerIndex,
    required this.editingPlayerCardIndex,
    required this.onExpand,
    required this.onSelectCard,
    required this.onClearCard,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: appState.players.length + 1,
        itemBuilder: (context, index) {
          if (index == appState.players.length) {
            // Add player card
            if (appState.players.length >= AppState.maxPlayers) {
              return const SizedBox();
            }
            return _AddPlayerCard();
          }

          final anyActive =
              editingPlayerIndex != null && editingPlayerCardIndex != null;
          final activeForThis = editingPlayerIndex == index
              ? editingPlayerCardIndex
              : null;
          return AnimatedPlayerCard(
            child: _PlayerCard(
              player: appState.players[index],
              playerIndex: index,
              isEditing: editingPlayerIndex == index,
              editingCardIndex: editingPlayerCardIndex,
              activeCardIndex: activeForThis,
              isAnyCardActive: anyActive,
              onExpand: () => onExpand(index),
              onSelectCard: (cardIndex) => onSelectCard(index, cardIndex),
              onClearCard: onClearCard,
            ),
          );
        },
      ),
    );
  }
}

class _AddPlayerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return GestureDetector(
      onTap: () => appState.addPlayer(),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}

// the stateful version replaced by a simple stateless widget that delegates
// expansion to the AppState and handles taps via callbacks.

/// wrapper used purely to fade a card in when it first appears.
class AnimatedPlayerCard extends StatefulWidget {
  final Widget child;
  const AnimatedPlayerCard({super.key, required this.child});

  @override
  State<AnimatedPlayerCard> createState() => _AnimatedPlayerCardState();
}

class _AnimatedPlayerCardState extends State<AnimatedPlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _ctrl, child: widget.child);
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerData player;
  final int playerIndex;
  final bool isEditing;
  final int? editingCardIndex;

  /// null if this player has no card currently chosen; non-null indicates the
  /// index of the card that is actively being assigned.
  final int? activeCardIndex;

  /// whether any card (in any player) is currently selected for assignment.
  final bool isAnyCardActive;
  final VoidCallback onExpand;
  final void Function(int cardIndex) onSelectCard;
  final void Function() onClearCard;

  const _PlayerCard({
    required this.player,
    required this.playerIndex,
    required this.isEditing,
    required this.editingCardIndex,
    required this.activeCardIndex,
    required this.isAnyCardActive,
    required this.onExpand,
    required this.onSelectCard,
    required this.onClearCard,
  });

  @override
  Widget build(BuildContext context) {
    // width grows when expanded so the second card has space; wrapping ine
    // ClipRect prevents children from overflowing during the animation.

    final playerDisabled = isAnyCardActive && activeCardIndex == null;
    return SizedBox(
      width: player.isExpanded ? 200 : 130,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // only allow tapping to collapse/expand when the player is not
        // already expanded; when expanded we rely on the inner cards' own
        // detectors so they can be tapped.
        onTap: player.isExpanded ? null : onExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          margin: const EdgeInsets.only(right: 16),
          child: player.isExpanded
              ? _ExpandedCards(
                  player: player,
                  playerIndex: playerIndex,
                  isEditingThisPlayer: isEditing,
                  editingCardIndex: editingCardIndex,
                  activeCardIndex: activeCardIndex,
                  isAnyCardActive: isAnyCardActive,
                  onSelectCard: onSelectCard,
                  onClearCard: onClearCard,
                  onLongPressCard: (cardIndex) {
                    // clear a card when long‑pressed
                    context.read<AppState>().clearPlayerCard(
                      playerIndex,
                      cardIndex,
                    );
                  },
                )
              : _StackedCards(
                  player: player,
                  playerIndex: playerIndex,
                  disabled: playerDisabled,
                  onLongPressCard: (cardIndex) {
                    context.read<AppState>().clearPlayerCard(
                      playerIndex,
                      cardIndex,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _StackedCards extends StatelessWidget {
  final PlayerData player;
  final int playerIndex;
  final bool disabled;
  final void Function(int cardIndex) onLongPressCard;

  const _StackedCards({
    required this.player,
    required this.playerIndex,
    required this.disabled,
    required this.onLongPressCard,
  });

  @override
  Widget build(BuildContext context) {
    // when disabled we will reduce opacity of both cards
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(left: 28, top: 15, child: _buildCard(player.card1, 0)),
        Positioned(right: 27, child: _buildCard(player.card2, 1)),
      ],
    );
  }

  Widget _separator() {
    return Container(
      width: 2,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.textColorDim.withAlpha(60),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCard(CommunityCardData card, int cardIndex) {
    return Opacity(
      opacity: disabled ? 0.35 : 1,
      child: GestureDetector(
        onLongPress: disabled ? null : () => onLongPressCard(cardIndex),
        child: SizedBox(
          width: 70,
          child: PokerCard(
            value: card.value ?? 0,
            suit: card.suit,
            small: true,
            showBack: true,
          ),
        ),
      ),
    );
  }
}

class _ExpandedCards extends StatelessWidget {
  final PlayerData player;
  final int playerIndex;
  final bool isEditingThisPlayer;
  final int? editingCardIndex;
  final int? activeCardIndex;
  final bool isAnyCardActive;
  final void Function(int cardIndex) onSelectCard;
  final void Function(int cardIndex) onLongPressCard;
  final void Function() onClearCard;

  const _ExpandedCards({
    required this.player,
    required this.playerIndex,
    required this.isEditingThisPlayer,
    required this.editingCardIndex,
    required this.activeCardIndex,
    required this.isAnyCardActive,
    required this.onSelectCard,
    required this.onLongPressCard,
    required this.onClearCard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _separator(),
        _buildCard(player.card1, 0),
        _buildCard(player.card2, 1),
        _separator(),
      ],
    );
  }

  Widget _separator() {
    return Container(
      width: 2,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.textColorDim.withAlpha(60),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCard(CommunityCardData card, int cardIndex) {
    final bool isActive = isEditingThisPlayer && editingCardIndex == cardIndex;
    final bool isDisabled = isAnyCardActive && !isActive;

    return GestureDetector(
      // if already active, tapping again clears the selection.
      // otherwise, select this card for editing.
      onTap: isActive ? onClearCard : () => onSelectCard(cardIndex),
      onLongPress: isDisabled ? null : () => onLongPressCard(cardIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()
            ..scaleByVector3(Vector3.all(isActive ? 1.1 : 1.0)),
          transformAlignment: Alignment.center,
          child: Opacity(
            opacity: isDisabled ? 0.35 : 1,
            child: FlipCard(
              flipped: card.value != null,
              locked: false,
              onTap: isActive ? onClearCard : () => onSelectCard(cardIndex),
              front: PokerCard(
                value: card.value ?? 0,
                suit: card.suit,
                small: true,
                showBack: false,
              ),
              back: PokerCard(value: 0, small: true, showBack: true),
            ),
          ),
        ),
      ),
    );
  }
}
