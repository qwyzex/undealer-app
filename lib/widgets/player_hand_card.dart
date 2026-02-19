import 'package:flutter/material.dart';
import 'package:undealer/models/player_hand.dart';
import 'package:undealer/widgets/poker_card.dart';
import 'package:undealer/widgets/flip_card.dart';
import 'package:dotted_border/dotted_border.dart';

class PlayerHandCard extends StatelessWidget {
  final PlayerHand hand;
  final int playerIndex;
  final bool isEditingThisHand;
  final int? selectedCardIndex;
  final VoidCallback onExpand;
  final Function(int cardIndex) onSelectCard;

  const PlayerHandCard({super.key, required this.hand, required this.playerIndex, required this.isEditingThisHand, required this.onExpand, required this.onSelectCard, this.selectedCardIndex});

  @override
  Widget build(BuildContext context) {
    switch (hand.state) {
      case PlayerHandState.empty:
        return _buildEmpty();
      case PlayerHandState.editing:
        return _buildEditing();
      case PlayerHandState.collapsed:
        return _buildCollapsed();
    }
  }

  Widget _buildEmpty() {
    return GestureDetector(
      onTap: onExpand,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          // borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          color: Colors.white54,
          strokeWidth: 2,
          dashPattern: const [6, 4],
        ),
        child: const SizedBox(width: 70, height: 98, child: Icon(Icons.add, color: Colors.white54, size: 40)),
      ),
    );
  }

  Widget _buildEditing() {
    return Row(
      children: List.generate(2, (index) {
        final card = hand.cards[index];
        final isCardSelected = isEditingThisHand && selectedCardIndex == index;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..translate(0.0, isCardSelected ? -20.0 : 0.0),
            child: FlipCard(
              flipped: card.flipped,
              locked: card.flipped,
              onTap: () => onSelectCard(index),
              front: PokerCard(value: card.value ?? 0, suit: card.suit, small: true),
              back: const PokerCard(value: 0, small: true, showBack: true),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: onExpand, // Allow re-editing
      child: SizedBox(
        width: 80,
        height: 98,
        child: Stack(
          children: [
            Transform.translate(offset: const Offset(8, 0), child: const PokerCard(value: 0, small: true, showBack: true)),
            const PokerCard(value: 0, small: true, showBack: true),
          ],
        ),
      ),
    );
  }
}
