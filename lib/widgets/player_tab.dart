import 'package:flutter/material.dart';
import 'package:flutter_custom_icons/flutter_custom_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:undealer/theme/colors.dart';
import 'package:undealer/widgets/player_option_menu.dart';
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
              onChangeName: () => onChangeName(index),
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

class _PlayerCard extends StatefulWidget {
  final PlayerData player;
  final int playerIndex;
  final bool isEditing;
  final int? editingCardIndex;
  final VoidCallback onChangeName;

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
    required this.onChangeName,
  });

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  // PASSES
  final Duration animationDuration = const Duration(milliseconds: 250);
  final animationCurves = Curves.easeInOut;

  OverlayEntry? _menuOverlay;
  int? _hoveredIndex;
  Offset? _menuTriggerPosition;

  List<PlayerOption> _getOptions() {
    final appState = context.read<AppState>();

    List<String> svgIconPath = [
      "assets/svgs/icon_remove_player.svg",
      "assets/svgs/icon_rename.svg",
      "assets/svgs/icon_fold.svg",
    ];

    Widget SVGIcon(String assetName) {
      return SvgPicture.asset(
        assetName,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          assetName == svgIconPath[0] ? Colors.redAccent : AppColors.textColor,
          BlendMode.srcIn,
        ),
        semanticsLabel: 'A description of the icon',
      );
    }

    return [
      if (!appState.gameOptions.lockPlayerCount)
        PlayerOption(
          label: 'Remove',
          icon: SVGIcon(svgIconPath[0]),
          color: Colors.redAccent,
          onTap: () {
            _hideMenu();
            appState.deletePlayer(widget.playerIndex);
          },
        ),
      PlayerOption(
        label: 'Rename',
        icon: SVGIcon(svgIconPath[1]),
        onTap: () {
          _hideMenu();
          widget.onChangeName();
        },
      ),
      PlayerOption(
        label: 'Fold',
        icon: SVGIcon(svgIconPath[2]),
        onTap: () {
          _hideMenu();
          appState.togglePlayerFold(widget.playerIndex);
        },
      ),
      // PlayerOption(label: 'Cancel', icon: Icons.person, color: Colors.redAccent, onTap: _hideMenu),
    ];
  }

  void _showMenu(BuildContext context, Offset position) {
    _menuOverlay = OverlayEntry(
      builder: (context) =>
          PlayerOptionMenu(position: position, options: _getOptions(), hoveredIndex: _hoveredIndex),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _updateMenu(Offset globalPosition) {
    if (_menuOverlay == null || _menuTriggerPosition == null) return;

    final newHoveredIndex = PlayerOptionMenu.getHoveredIndex(
      globalPosition,
      _menuTriggerPosition!,
      _getOptions().length,
      context,
    );

    if (newHoveredIndex != _hoveredIndex) {
      setState(() {
        _hoveredIndex = newHoveredIndex;
      });
      _menuOverlay?.markNeedsBuild();
    }
  }

  void _hideMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
    _menuTriggerPosition = null;
    _hoveredIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    Widget separator() {
      return IgnorePointer(
        ignoring: true,
        child: Container(
          width: 2,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.textColorDim.withAlpha(widget.player.isExpanded ? 100 : 0),
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
          opacity: widget.player.isExpanded ? 0 : 1,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: cardNum == 0
                  ? widget.player.card1.value != null && widget.player.card1.value! > 1
                        ? Colors.green
                        : Colors.red
                  : widget.player.card2.value != null && widget.player.card2.value! > 1
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
      final bool isActive = widget.isEditing && widget.editingCardIndex == cardIndex;
      final bool isDisabled = widget.isAnyCardActive && !isActive;

      return GestureDetector(
        onTap: isActive ? widget.onClearCard : () => widget.onSelectCard(cardIndex),
        onLongPress: isDisabled
            ? null
            : () => (cardIndex) {
                context.read<AppState>().clearPlayerCard(widget.playerIndex, cardIndex);
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
                flipped: card.value != null && widget.player.isExpanded,
                locked: false,
                onTap: isActive ? widget.onClearCard : () => widget.onSelectCard(cardIndex),
                front: PokerCard(value: card.value ?? 0, suit: card.suit, small: true, showBack: false),
                back: PokerCard(
                  value: 0,
                  small: true,
                  showBack: true,
                  showPlayerIndex: showPlayerIndex ? widget.playerIndex + 1 : null,
                  playerName: widget.player.playerName,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: widget.player.isExpanded ? 180 : 90,
      margin: const EdgeInsets.only(right: 16),
      child: ColorFiltered(
        colorFilter: ColorFilter.saturation(widget.player.isFolded ? 0 : 1),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Margin separator
            AnimatedPositioned(
              duration: animationDuration,
              left: widget.player.isExpanded ? 8 : 0,
              child: separator(),
            ),
            AnimatedPositioned(
              duration: animationDuration,
              right: widget.player.isExpanded ? 8 : 0,
              child: separator(),
            ),

            // CARDs
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: widget.player.isExpanded ? 90 : 10,
              top: widget.player.isExpanded ? 10 : 20,
              child: buildCard(widget.player.card1, 0, false),
            ),
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: widget.player.isExpanded ? 12 : 0,
              top: widget.player.isExpanded
                  ? 10
                  : widget.player.isFolded
                  ? 30
                  : 10,
              child: buildCard(widget.player.card2, 1, true),
            ),

            // Card assigned indicator
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: 9 + (widget.player.isExpanded ? 15 : 0),
              bottom: widget.player.isExpanded
                  ? 18
                  : widget.player.isFolded
                  ? -2
                  : 18,
              child: indicator(0),
            ),
            AnimatedPositioned(
              duration: animationDuration,
              curve: animationCurves,
              left: 9 + (widget.player.isExpanded ? 15 : 0),
              bottom: widget.player.isExpanded
                  ? 30
                  : widget.player.isFolded
                  ? 10
                  : 30,
              child: indicator(1),
            ),

            // Overlay
            Positioned.fill(
              child: IgnorePointer(
                ignoring: widget.player.isExpanded,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.player.isExpanded ? null : widget.onExpand,
                  onLongPressStart: (details) {
                    _menuTriggerPosition = details.globalPosition;
                    _hoveredIndex = null;
                    _showMenu(context, details.globalPosition);
                  },
                  onLongPressMoveUpdate: (details) => _updateMenu(details.globalPosition),
                  onLongPressEnd: (details) {
                    if (_hoveredIndex != null) {
                      _getOptions()[_hoveredIndex!].onTap();
                    } else {
                      _hideMenu();
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
