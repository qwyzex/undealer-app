import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undealer/models/card_model.dart';
import 'package:undealer/models/game_options.dart';
import 'package:undealer/models/player_model.dart';
import 'package:undealer/models/suit.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState() {
    loadState();
  }

  //*************************************************************************//
  // PRIMITIVES

  List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());
  List<PlayerData> players = [];
  final GlobalKey addPlayerRefKey = GlobalKey();
  static const int maxPlayers = 20;

  //*************************************************************************//
  // SETTINGS OPTIONS

  // This is the "Initial" value, but loadState() will overwrite this if data exists in storage.
  GameOptionsModel gameOptions = GameOptionsModel(
    lockPlayerCount: true,
    setPlayerCount: 6,
    dontCalculateFolds: false,
    playerAssignTheirOwnCard: true,
  );

  /// TABLE STAGES
  /// 0: Flop, 1: Turn, 2: River
  int tableStage = 0;

  // PERSISTENCE SAVE STATES
  bool get hasSavedGame => players.isNotEmpty || communityCards.any((c) => c.value != null);

  //*************************************************************************//
  // ACTIONS

  void initializeNewGame(GameOptionsModel gameOptions) {
    updateGameOptions(gameOptions);

    // CHECK EVERY OPTIONS AND CALL LOGIC ACCORDINGLY
    if (gameOptions.lockPlayerCount) {
      players = List.generate(gameOptions.setPlayerCount, (_) => PlayerData());
    } else {
      players = [];
    }
  }

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

    players.add(PlayerData(card1: CommunityCardData(), card2: CommunityCardData()));

    saveState();

    final context = addPlayerRefKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }

    notifyListeners();
  }

  void deletePlayer(int index) {
    if (index < 0 || index >= players.length) return;
    players.removeAt(index);
    saveState();
    notifyListeners();
  }

  void changePlayerName(int playerIndex, String newName) {
    players[playerIndex].playerName = newName;
    saveState();
    notifyListeners();
  }

  void togglePlayerExpansion(int index) {
    collapseAllPlayers();
    players[index].isExpanded = !players[index].isExpanded;
    notifyListeners();
  }

  void togglePlayerFold(int index) {
    players[index].isFolded = !players[index].isFolded;
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

  Set<Suit> getUnavailableSuitsForValue(int value, {int? playerIndex, int? cardIndex, int? communityIndex}) {
    final Set<Suit> unavailable = {};

    // 1. Check Community Cards
    // We always block suits already taken by other community cards of the same value
    for (int i = 0; i < communityCards.length; i++) {
      if (i == communityIndex) continue;
      final card = communityCards[i];
      if (card.value == value && card.suit != null) {
        unavailable.add(card.suit!);
      }
    }

    // 2. Context-dependent Player Card checking
    if (playerIndex != null) {
      // WE ARE EDITING A PLAYER'S CARD
      if (gameOptions.playerAssignTheirOwnCard) {
        // PRIVATE MODE: Only sentient of community cards and the player's OWN other card.
        final player = players[playerIndex];
        final otherCard = (cardIndex == 0) ? player.card2 : player.card1;
        if (otherCard.value == value && otherCard.suit != null) {
          unavailable.add(otherCard.suit!);
        }
      } else {
        // PUBLIC MODE: Sentient of everything.
        for (int i = 0; i < players.length; i++) {
          final p = players[i];
          if (i == playerIndex) {
            final otherCard = (cardIndex == 0) ? p.card2 : p.card1;
            if (otherCard.value == value && otherCard.suit != null) {
              unavailable.add(otherCard.suit!);
            }
          } else {
            if (p.card1.value == value && p.card1.suit != null) unavailable.add(p.card1.suit!);
            if (p.card2.value == value && p.card2.suit != null) unavailable.add(p.card2.suit!);
          }
        }
      }
    } else {
      // WE ARE EDITING A COMMUNITY CARD (or just viewing the value selector)
      // The dealer must be sentient of ALL players' cards to ensure no duplicates on the table.
      for (var p in players) {
        if (p.card1.value == value && p.card1.suit != null) unavailable.add(p.card1.suit!);
        if (p.card2.value == value && p.card2.suit != null) unavailable.add(p.card2.suit!);
      }
    }

    return unavailable;
  }

  void setCommunityCard(int index, int value, Suit suit) {
    communityCards[index].value = value;
    communityCards[index].suit = suit;
    communityCards[index].flipped = true;

    final bool isTrueFlop =
        communityCards[0].value != null && communityCards[1].value != null && communityCards[2].value != null;

    if (isTrueFlop && tableStage == 0) {
      tableStage = 1;
    } else if (index == 3 && tableStage == 1) {
      tableStage = 2;
    }

    saveState();
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
    saveState();
    notifyListeners();
  }

  void clearCard(int index) {
    communityCards[index] = CommunityCardData();
    saveState();
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
    saveState();
    notifyListeners();
  }

  void resetGame() {
    communityCards = List.generate(5, (_) => CommunityCardData());
    players = [];
    tableStage = 0;

    // TODO: Extract this logic into a separate function
    // Reset game options to default values
    gameOptions = GameOptionsModel(
      lockPlayerCount: false,
      setPlayerCount: 6,
      dontCalculateFolds: false,
      playerAssignTheirOwnCard: true,
    );

    saveState();
    notifyListeners();
  }

  void updateGameOptions(GameOptionsModel options) {
    gameOptions = options;
    saveState();
    notifyListeners();
  }

  //*************************************************************************//
  // Persistence logic

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateData = {
      'communityCards': communityCards.map((c) => c.toJson()).toList(),
      'players': players.map((p) => p.toJson()).toList(),
      'tableStage': tableStage,
      'gameOptions': gameOptions.toJson(),
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
      players = (stateData['players'] as List).map((p) => PlayerData.fromJson(p)).toList();
      tableStage = stateData['tableStage'] ?? 0;

      if (stateData['gameOptions'] != null) {
        gameOptions = GameOptionsModel.fromJson(stateData['gameOptions']);
      }
      notifyListeners();
    } else {
      saveState();
    }
  }
}
