import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undealer/models/card_model.dart';
import 'package:undealer/models/player_model.dart';
import 'package:undealer/models/suit.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState() {
    loadState();
  }

  List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());
  List<PlayerData> players = [];
  final GlobalKey addPlayerRefKey = GlobalKey();

  /// 0: Flop, 1: Turn, 2: River
  int tableStage = 0;

  static const int maxPlayers = 20;

  bool get hasSavedGame => players.isNotEmpty || communityCards.any((c) => c.value != null);

  void setTableStage(int stage) {
    if (stage >= 0 && stage <= 2) {
      tableStage = stage;
      saveState();
      notifyListeners();
    }
  }

  void nextStage() {
    if (tableStage < 2) {
      tableStage++;
      saveState();
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

    saveState();

    final context = addPlayerRefKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    notifyListeners();
  }

  void deletePlayer(int index) {
    if (index < 0 || index >= players.length) return;
    if (players.length != index + 1 && players[index + 1].isExpanded) togglePlayerExpansion(index + 1);
    players.removeAt(index);
    saveState();
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

    final bool isTrueFlop = communityCards[0].value != null && communityCards[1].value != null && communityCards[2].value != null;

    if (isTrueFlop && tableStage == 0) {
      tableStage = 1;
    } else if (index == 3 && tableStage == 1) {
      tableStage = 2;
    }

    saveState();
    notifyListeners();
  }

  void setPlayerCard(int playerIndex, int cardIndex, int value, Suit suit) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final card = cardIndex == 0 ? players[playerIndex].card1 : players[playerIndex].card2;
    card.value = value;
    card.suit = suit;
    saveState();
    notifyListeners();
  }

  void clearCard(int index) {
    communityCards[index] = CommunityCardData();
    saveState();
    notifyListeners();
  }

  void clearPlayerCard(int playerIndex, int cardIndex) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final card = cardIndex == 0 ? players[playerIndex].card1 : players[playerIndex].card2;
    card.value = null;
    card.suit = null;
    card.flipped = false;
    saveState();
    notifyListeners();
  }

  void resetGame() {
    communityCards = List.generate(5, (_) => CommunityCardData());
    players = [];
    tableStage = 0;
    saveState();
    notifyListeners();
  }

  // Persistence logic
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateData = {
      'communityCards': communityCards.map((c) => c.toJson()).toList(),
      'players': players.map((p) => p.toJson()).toList(),
      'tableStage': tableStage,
    };
    await prefs.setString('game_state', jsonEncode(stateData));
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stateString = prefs.getString('game_state');
    if (stateString != null) {
      final Map<String, dynamic> stateData = jsonDecode(stateString);
      
      communityCards = (stateData['communityCards'] as List)
          .map((c) => CommunityCardData.fromJson(c))
          .toList();
      
      players = (stateData['players'] as List)
          .map((p) => PlayerData.fromJson(p))
          .toList();
      
      tableStage = stateData['tableStage'] ?? 0;
      notifyListeners();
    }
  }
}
