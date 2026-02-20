import 'package:flutter/material.dart';
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

  const PlayerTab({
    super.key,
    required this.editingPlayerIndex,
    required this.editingPlayerCardIndex,
    required this.onExpand,
    required this.onSelectCard,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
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

          return _PlayerCard(
            player: appState.players[index],
            playerIndex: index,
            isEditing: editingPlayerIndex == index,
            editingCardIndex: editingPlayerCardIndex,
            onExpand: () => onExpand(index),
            onSelectCard: (cardIndex) => onSelectCard(index, cardIndex),
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

class _PlayerCard extends StatelessWidget {
  final PlayerData player;
  final int playerIndex;
  final bool isEditing;
  final int? editingCardIndex;
  final VoidCallback onExpand;
  final void Function(int cardIndex) onSelectCard;

  const _PlayerCard({
    required this.player,
    required this.playerIndex,
    required this.isEditing,
    required this.editingCardIndex,
    required this.onExpand,
    required this.onSelectCard,
  });

  @override
  Widget build(BuildContext context) {
    // width grows when expanded so the second card has space; wrapping ine
    // ClipRect prevents children from overflowing during the animation.

    return SizedBox(
      width: player.isExpanded ? 200 : 130,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onExpand,
        child: ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 16),
            child: player.isExpanded
                ? _ExpandedCards(
                    player: player,
                    isEditingThisPlayer: isEditing,
                    editingCardIndex: editingCardIndex,
                    onSelectCard: onSelectCard,
                  )
                : _StackedCards(player: player),
          ),
        ),
      ),
    );
  }
}

// class _PlayerCard extends StatelessWidget {
//   final int index;
//
//   const _PlayerCard({required this.index});
//
//   @override
//   Widget build(BuildContext context) {
//     final appState = context.watch<AppState>();
//     final player = appState.players[index];
//
//     print(player.isExpanded);
//     print(player.isExpanded);
//     print(player.isExpanded);
//
//     return SizedBox(
//       width: player.isExpanded ? 200 : 100,
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () {
//           appState.togglePlayerExpansion(index);
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           margin: const EdgeInsets.only(right: 16),
//           child: player.isExpanded ? _ExpandedCards(player: player) : _StackedCards(player: player),
//         ),
//       ),
//     );
//
//     // return AnimatedContainer(
//     //   duration: const Duration(milliseconds: 250),
//     //
//     //   width: player.isExpanded ? 200 : 100,
//     //   margin: const EdgeInsets.only(right: 16),
//     //   child: Material(
//     //     color: Colors.transparent,
//     //     child: InkWell(
//     //       onTap: () => appState.togglePlayerExpansion(index),
//     //       child: player.isExpanded ? _ExpandedCards(player: player) : _StackedCards(player: player),
//     //     ),
//     //   ),
//     // );
//   }
// }

class _StackedCards extends StatelessWidget {
  final PlayerData player;

  const _StackedCards({required this.player});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(left: 15, top: 15, child: _buildCard(player.card1)),
        Positioned(right: 40, child: _buildCard(player.card2)),
      ],
    );
  }

  Widget _buildCard(CommunityCardData card) {
    return Container(
      width: 70,
      color: Colors.transparent,
      child: IgnorePointer(
        child: FlipCard(
          flipped: card.flipped,
          locked: false,
          onLongPress: () {},
          front: PokerCard(
            value: card.value ?? 0,
            suit: card.suit,
            small: true,
            showBack: false,
          ),
          back: const PokerCard(value: 0, small: true, showBack: true),
        ),
      ),
    );
  }
}

class _ExpandedCards extends StatelessWidget {
  final PlayerData player;
  final bool isEditingThisPlayer;
  final int? editingCardIndex;
  final void Function(int cardIndex) onSelectCard;

  const _ExpandedCards({
    required this.player,
    required this.isEditingThisPlayer,
    required this.editingCardIndex,
    required this.onSelectCard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_buildCard(player.card1, 0), _buildCard(player.card2, 1)],
    );
  }

  Widget _buildCard(CommunityCardData card, int cardIndex) {
    final bool isActive = isEditingThisPlayer && editingCardIndex == cardIndex;
    return GestureDetector(
      onTap: () => onSelectCard(cardIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, isActive ? -20.0 : 0.0),
          child: FlipCard(
            flipped: card.flipped,
            locked: card.flipped,
            onTap: () => onSelectCard(cardIndex),
            front: PokerCard(
              value: card.value ?? 0,
              suit: card.suit,
              small: true,
            ),
            back: const PokerCard(value: 0, small: true, showBack: true),
          ),
        ),
      ),
    );
  }
}
