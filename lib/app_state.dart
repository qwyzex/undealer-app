import 'package:flutter/foundation.dart';
import 'package:undealer/models/card_model.dart';
import 'package:undealer/models/suit.dart';
import 'package:flutter/material.dart';

class PlayerData {
  PlayerData({
    CommunityCardData? card1,
    CommunityCardData? card2,
    this.isExpanded = false,
  }) : card1 = card1 ?? CommunityCardData(),
       card2 = card2 ?? CommunityCardData();

  CommunityCardData card1;
  CommunityCardData card2;
  bool isExpanded;
}

class AppState extends ChangeNotifier {
  final List<CommunityCardData> communityCards = List.generate(
    5,
    (_) => CommunityCardData(),
  );

  final List<PlayerData> players = [];

  final GlobalKey addPlayerRefKey = GlobalKey();

  static const int maxPlayers = 20;

  void addPlayer() {
    if (players.length >= maxPlayers) return;

    players.add(
      PlayerData(
        card1: CommunityCardData(), // empty
        card2: CommunityCardData(),
      ),
    );

    final context = addPlayerRefKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(
          milliseconds: 500,
        ), // Optional animation duration
        curve: Curves.easeInOut, // Optional animation curve
      );
    }

    notifyListeners();
  }

  void scrollToFocus() {}

  void deletePlayer(int index) {
    if (index < 0 || index >= players.length) return;
    players.removeAt(index);
    notifyListeners();
  }

  void togglePlayerExpansion(int index) {
    players[index].isExpanded = !players[index].isExpanded;
    notifyListeners();
  }

  /// Collapse every player's expanded cards. Useful when tapping outside or
  /// after finishing edits.
  void collapseAllPlayers() {
    for (var player in players) {
      player.isExpanded = false;
    }
    notifyListeners();
  }

  // In the future, you can add player hands here

  Set<Suit> getUnavailableSuitsForValue(int value) {
    final Set<Suit> unavailable = {};
    for (var card in communityCards) {
      if (card.value == value && card.suit != null) {
        unavailable.add(card.suit!);
      }
    }
    // also include cards already assigned to players so we don't duplicate
    for (var player in players) {
      if (player.card1.value == value && player.card1.suit != null) {
        unavailable.add(player.card1.suit!);
      }
      if (player.card2.value == value && player.card2.suit != null) {
        unavailable.add(player.card2.suit!);
      }
    }
    return unavailable;
  }

  void setCommunityCard(int index, int value, Suit suit) {
    communityCards[index].value = value;
    communityCards[index].suit = suit;
    communityCards[index].flipped = true;
    notifyListeners();
  }

  /// Assign a value + suit to one of a player's two cards.
  void setPlayerCard(int playerIndex, int cardIndex, int value, Suit suit) {
    // unlike community cards we don't persist a "flipped" state; the UI
    // always hides hole cards when the player is collapsed and shows them
    // while expanded.  Storing flipped would only matter if we wanted to
    // animate the flip later, so we just set the value/suit here.
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final player = players[playerIndex];
    final card = cardIndex == 0 ? player.card1 : player.card2;
    card.value = value;
    card.suit = suit;
    notifyListeners();
  }

  void clearCard(int index) {
    communityCards[index] = CommunityCardData();
    notifyListeners();
  }

  /// Reset a player's individual hole card, leaving the player expanded if
  /// they were already.
  void clearPlayerCard(int playerIndex, int cardIndex) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final player = players[playerIndex];
    final card = cardIndex == 0 ? player.card1 : player.card2;
    card.value = null;
    card.suit = null;
    card.flipped = false;
    notifyListeners();
  }
}
