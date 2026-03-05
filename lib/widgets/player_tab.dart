import 'package:flutter/material.dart';
import 'package:undealer/theme/colors.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'package:undealer/models/card_model.dart';
import '../models/player_model.dart';
import 'flip_card.dart';
import 'poker_card.dart';

class PlayerTab extends StatelessWidget {
  final int? editingPlayerIndex;
  final int? editingPlayerCardIndex;

  final void Function(int playerIndex) onExpand;
  final void Function(int playerIndex, int cardIndex) onSelectCard;

  final void Function() onClearCard;
  final void Function(int playerIndex) onChangeName;

  const PlayerTab({
    super.key,
    required this.editingPlayerIndex,
    required this.editingPlayerCardIndex,
    required this.onExpand,
    required this.onSelectCard,
    required this.onClearCard,
    required this.onChangeName,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: appState.players.length + 2,
        itemBuilder: (context, index) {
          if (index == appState.players.length + 1) {
            return _GhostReference(key: appState.addPlayerRefKey);
          }

          if (index == appState.players.length) {
            // "Add player" card
            if (appState.players.length >= AppState.maxPlayers) {
              return const SizedBox();
            }
            return appState.gameOptions.lockPlayerCount ? null : _AddPlayerCard();
          }

          final anyActive = editingPlayerIndex != null && editingPlayerCardIndex != null;
          final activeForThis = editingPlayerIndex == index ? editingPlayerCardIndex : null;
          return AnimatedPlayerCard(
            child: _PlayerCard(
              player: appState.players[index],
              playerIndex: index,
              isEditing: editingPlayerIndex == index,
              editingCardIndex: editingPlayerCardIndex,
              activeCardIndex: activeForThis,
              isAnyCardActive: anyActive,
              onExpand: () => onExpand(index),
              onCallChangeName: () => onChangeName(index),
              onSelectCard: (cardIndex) => onSelectCard(index, cardIndex),
              onClearCard: onClearCard,
            ),
          );
        },
      ),
    );
  }
}

class _GhostReference extends StatelessWidget {
  const _GhostReference({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 165, color: Colors.transparent);
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
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.deepShadeHeavy,
            style: BorderStyle.solid,
            width: 3,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Icon(Icons.add, size: 40, color: AppColors.deepShadeHeavy)),
      ),
    );
  }
}

class AnimatedPlayerCard extends StatefulWidget {
  final Widget child;

  const AnimatedPlayerCard({super.key, required this.child});

  @override
  State<AnimatedPlayerCard> createState() => _AnimatedPlayerCardState();
}

class _AnimatedPlayerCardState extends State<AnimatedPlayerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
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
  final VoidCallback? onCallChangeName;

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
    required this.onCallChangeName,
  });

  // PASSES
  final Duration animationDuration = const Duration(milliseconds: 250);

  final animationCurves = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    void handleDeletePlayer() {
      appState.deletePlayer(playerIndex);
    }

    void handleTogglePlayerFold() {
      appState.togglePlayerFold(playerIndex);
    }

    Widget separator() {
      return IgnorePointer(
        ignoring: true,
        child: Container(
          width: 2,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.textColorDim.withAlpha(player.isExpanded ? 100 : 0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }

    Widget indicator(int cardNum) {
      return IgnorePointer(
        ignoring: true,
        child: AnimatedOpacity(
          duration: animationDuration,
          opacity: player.isExpanded ? 0 : 1,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: cardNum == 0
                  ? player.card1.value != null && player.card1.value! > 1
                        ? Colors.green
                        : Colors.red
                  : player.card2.value != null && player.card2.value! > 1
                  ? Colors.green
                  : Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      );
    }

    Widget buildCard(CommunityCardData card, int cardIndex, bool showPlayerIndex) {
      final bool isActive = isEditing && editingCardIndex == cardIndex;
      final bool isDisabled = isAnyCardActive && !isActive;

      return GestureDetector(
        onTap: isActive ? onClearCard : () => onSelectCard(cardIndex),
        onLongPress: isDisabled
            ? null
            : () => (cardIndex) {
                context.read<AppState>().clearPlayerCard(playerIndex, cardIndex);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedContainer(
            duration: animationDuration,
            transform: Matrix4.identity()..scaleByVector3(Vector3.all(isActive ? 1.1 : 1.0)),
            transformAlignment: Alignment.center,
            child: AnimatedOpacity(
              duration: animationDuration,
              opacity: isDisabled ? 0.35 : 1,
              child: FlipCard(
                flipped: card.value != null && player.isExpanded,
                locked: false,
                onTap: () => {
                  if (!player.isFolded) () => {isActive ? onClearCard : () => onSelectCard(cardIndex)},
                },

                front: PokerCard(value: card.value ?? 0, suit: card.suit, small: true, showBack: false),
                back: PokerCard(
                  value: 0,
                  small: true,
                  showBack: true,
                  showPlayerIndex: showPlayerIndex ? playerIndex + 1 : null,
                  playerName: player.playerName,
                ),
              ),
            ),
          ),
        ),
      );
    }

    const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: player.isExpanded ? 180 : 90,
      margin: const EdgeInsets.only(right: 16),
      child: ColorFiltered(
        colorFilter: player.isFolded ? greyscaleFilter : ColorFilter.saturation(1),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Margin separator
            AnimatedPositioned(
              duration: animationDuration,
              left: player.isExpanded ? 8 : 0,
              child: separator(),
            ),
            AnimatedPositioned(
              duration: animationDuration,
              right: player.isExpanded ? 8 : 0,
              child: separator(),
            ),

            // CARDs
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: player.isExpanded ? 90 : 10,
              top: player.isExpanded ? 10 : 20,
              child: buildCard(player.card1, 0, false),
            ),
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: player.isExpanded ? 12 : 0,
              top: player.isFolded ? 30 : 10,
              child: buildCard(player.card2, 1, true),
            ),

            // Card assigned indicator
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: 9 + (player.isExpanded ? 15 : 0),
              bottom: 18,
              child: indicator(0),
            ),
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: 9 + (player.isExpanded ? 15 : 0),
              bottom: 30,
              child: indicator(1),
            ),

            // Overlay
            Positioned.fill(
              child: IgnorePointer(
                ignoring: player.isExpanded,
                child: FlipCard(
                  flipped: true,
                  locked: false,
                  inverseLocked: true,
                  onTap: player.isExpanded ? null : onExpand,
                  onDoubleTap: onCallChangeName,
                  onCancelPress: RadialFunctionCall(() => {}, "CANCEL"),
                  onActionOne: RadialFunctionCall(
                    handleTogglePlayerFold,
                    player.isFolded ? "UNFOLD" : "FOLD",
                  ),
                  onActionTwo: appState.gameOptions.lockPlayerCount
                      ? RadialFunctionCall(handleTogglePlayerFold, player.isFolded ? "UNFOLD" : "FOLD")
                      : RadialFunctionCall(handleDeletePlayer, "DELETE"),
                  front: Container(color: Colors.transparent),
                  back: Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
