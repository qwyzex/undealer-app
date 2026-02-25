import 'package:undealer/models/card_model.dart';
import 'package:undealer/models/suit.dart';
import 'package:flutter/material.dart';

class PlayerData {
  PlayerData({CommunityCardData? card1, CommunityCardData? card2, this.isExpanded = false}) : card1 = card1 ?? CommunityCardData(), card2 = card2 ?? CommunityCardData();

  CommunityCardData card1;
  CommunityCardData card2;
  bool isExpanded;
}

class AppState extends ChangeNotifier {
  final List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());
  final List<PlayerData> players = [];
  final GlobalKey addPlayerRefKey = GlobalKey();

  /// 0: Flop, 1: Turn, 2: River
  int tableStage = 0;

  static const int maxPlayers = 20;

  void setTableStage(int stage) {
    if (stage >= 0 && stage <= 2) {
      tableStage = stage;
      notifyListeners();
    }
  }

  void nextStage() {
    if (tableStage < 2) {
      tableStage++;
      notifyListeners();
    }
  }

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
        duration: const Duration(milliseconds: 500), // Optional animation duration
        curve: Curves.easeInOut, // Optional animation curve
      );
    }

    notifyListeners();
  }

  void scrollToFocus() {}

  void deletePlayer(int index) {
    if (index < 0 || index >= players.length) return;
    if (players.length != index + 1 && players[index + 1].isExpanded) togglePlayerExpansion(index + 1);
    players.removeAt(index);
    notifyListeners();
  }

  void togglePlayerExpansion(int index) {
    bool wasExpanded = players[index].isExpanded;
    collapseAllPlayers();
    players[index].isExpanded = !wasExpanded;
    notifyListeners();
  }

  void collapseAllPlayers() {
    for (var player in players) {
      player.isExpanded = false;
    }
    notifyListeners();
  }

  Set<Suit> getUnavailableSuitsForValue(int value) {
    final Set<Suit> unavailable = {};
    for (var card in communityCards) {
      if (card.value == value && card.suit != null) unavailable.add(card.suit!);
    }
    for (var player in players) {
      if (player.card1.value == value && player.card1.suit != null) unavailable.add(player.card1.suit!);
      if (player.card2.value == value && player.card2.suit != null) unavailable.add(player.card2.suit!);
    }
    return unavailable;
  }

  void setCommunityCard(int index, int value, Suit suit) {
    communityCards[index].value = value;
    communityCards[index].suit = suit;
    communityCards[index].flipped = true;

    // Auto-advance logic:
    // If we just finished the Flop (index 2), move to Turn
    if (index == 2 && tableStage == 0) {
      tableStage = 1;
    } else if (index == 3 && tableStage == 1) {
      tableStage = 2;
    }

    notifyListeners();
  }

  void setPlayerCard(int playerIndex, int cardIndex, int value, Suit suit) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final card = cardIndex == 0 ? players[playerIndex].card1 : players[playerIndex].card2;
    card.value = value;
    card.suit = suit;
    notifyListeners();
  }

  void clearCard(int index) {
    communityCards[index] = CommunityCardData();
    notifyListeners();
  }

  void clearPlayerCard(int playerIndex, int cardIndex) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final card = cardIndex == 0 ? players[playerIndex].card1 : players[playerIndex].card2;
    card.value = null;
    card.suit = null;
    card.flipped = false;
    notifyListeners();
  }
}
