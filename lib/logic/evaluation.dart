import '../models/suit.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';

enum HandRank {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush,
}

class EvalCard {
  final int value;
  final Suit suit;

  EvalCard(this.value, this.suit);

  factory EvalCard.fromModel(CommunityCardData data) {
    return EvalCard(data.value!, data.suit!);
  }

  @override
  String toString() => '$value${suit.name[0].toUpperCase()}';
}

class HandResult implements Comparable<HandResult> {
  final HandRank rank;
  final List<int> tiebreakers;

  HandResult(this.rank, this.tiebreakers);

  @override
  int compareTo(HandResult other) {
    if (rank.index != other.rank.index) {
      return rank.index.compareTo(other.rank.index);
    }
    for (int i = 0; i < tiebreakers.length; i++) {
      if (i >= other.tiebreakers.length) return 1;
      if (tiebreakers[i] != other.tiebreakers[i]) {
        return tiebreakers[i].compareTo(other.tiebreakers[i]);
      }
    }
    if (other.tiebreakers.length > tiebreakers.length) return -1;
    return 0;
  }

  String get rankName {
    switch (rank) {
      case HandRank.highCard:
        return "High Card";
      case HandRank.onePair:
        return "One Pair";
      case HandRank.twoPair:
        return "Two Pair";
      case HandRank.threeOfAKind:
        return "Three of a Kind";
      case HandRank.straight:
        return "Straight";
      case HandRank.flush:
        return "Flush";
      case HandRank.fullHouse:
        return "Full House";
      case HandRank.fourOfAKind:
        return "Four of a Kind";
      case HandRank.straightFlush:
        return "Straight Flush";
      case HandRank.royalFlush:
        return "Royal Flush";
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HandResult && rank == other.rank && _listEquals(tiebreakers, other.tiebreakers);

  @override
  int get hashCode => rank.hashCode ^ tiebreakers.hashCode;

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class PokerEvaluator {
  /// Evaluates a 5-card hand and returns its rank and tiebreakers.
  static HandResult evaluate(List<EvalCard> cards) {
    assert(cards.length == 5);

    // Sort descending by value
    final sorted = List<EvalCard>.from(cards)..sort((a, b) => b.value.compareTo(a.value));

    final valueCounts = <int, int>{};
    final suitCounts = <Suit, int>{};
    for (var c in sorted) {
      valueCounts[c.value] = (valueCounts[c.value] ?? 0) + 1;
      suitCounts[c.suit] = (suitCounts[c.suit] ?? 0) + 1;
    }

    final distinctValues = valueCounts.keys.toList()..sort((a, b) => b.compareTo(a));
    final isFlush = suitCounts.values.any((c) => c == 5);
    final straightHighCard = _getStraightHighCard(distinctValues);
    final isStraight = straightHighCard != null;

    // Straight Flush / Royal Flush
    if (isFlush && isStraight) {
      if (straightHighCard == 14) {
        return HandResult(HandRank.royalFlush, [14]);
      }
      return HandResult(HandRank.straightFlush, [straightHighCard]);
    }

    // Four of a Kind
    final quads = _getValuesWithCount(valueCounts, 4);
    if (quads.isNotEmpty) {
      final kicker = distinctValues.firstWhere((v) => v != quads[0]);
      return HandResult(HandRank.fourOfAKind, [quads[0], kicker]);
    }

    // Full House
    final trips = _getValuesWithCount(valueCounts, 3);
    final pairs = _getValuesWithCount(valueCounts, 2);
    if (trips.isNotEmpty && pairs.isNotEmpty) {
      return HandResult(HandRank.fullHouse, [trips[0], pairs[0]]);
    }

    // Flush
    if (isFlush) {
      return HandResult(HandRank.flush, distinctValues);
    }

    // Straight
    if (isStraight) {
      return HandResult(HandRank.straight, [straightHighCard]);
    }

    // Three of a Kind
    if (trips.isNotEmpty) {
      final kickers = distinctValues.where((v) => v != trips[0]).toList();
      return HandResult(HandRank.threeOfAKind, [trips[0], ...kickers]);
    }

    // Two Pair
    if (pairs.length >= 2) {
      final kicker = distinctValues.firstWhere((v) => v != pairs[0] && v != pairs[1]);
      return HandResult(HandRank.twoPair, [pairs[0], pairs[1], kicker]);
    }

    // One Pair
    if (pairs.length == 1) {
      final kickers = distinctValues.where((v) => v != pairs[0]).toList();
      return HandResult(HandRank.onePair, [pairs[0], ...kickers]);
    }

    // High Card
    return HandResult(HandRank.highCard, distinctValues);
  }

  static int? _getStraightHighCard(List<int> values) {
    if (values.length < 5) return null;

    final vals = values.toSet().toList();
    if (vals.contains(14)) vals.add(1);
    vals.sort((a, b) => b.compareTo(a));

    int run = 1;
    for (int i = 0; i < vals.length - 1; i++) {
      if (vals[i] - 1 == vals[i + 1]) {
        run++;
        if (run >= 5) return vals[i - 3];
      } else {
        run = 1;
      }
    }
    return null;
  }

  static List<int> _getValuesWithCount(Map<int, int> counts, int n) {
    return counts.entries.where((e) => e.value == n).map((e) => e.key).toList()
      ..sort((a, b) => b.compareTo(a));
  }

  /// Finds the best 5-card hand from a list of 5 or more cards.
  static HandResult getBestHand(List<EvalCard> cards) {
    if (cards.length < 5) {
      final sortedValues = cards.map((c) => c.value).toList()..sort((a, b) => b.compareTo(a));
      return HandResult(HandRank.highCard, sortedValues);
    }

    HandResult? best;
    for (final combo in _combinations(cards, 5)) {
      final result = evaluate(combo);
      if (best == null || result.compareTo(best) > 0) {
        best = result;
      }
    }
    return best!;
  }

  static List<List<T>> _combinations<T>(List<T> items, int k) {
    final results = <List<T>>[];
    void helper(int start, List<T> current) {
      if (current.length == k) {
        results.add(List.from(current));
        return;
      }
      for (int i = start; i < items.length; i++) {
        current.add(items[i]);
        helper(i + 1, current);
        current.removeLast();
      }
    }

    helper(0, []);
    return results;
  }
}

class GameEvaluator {
  /// Evaluates the best hand for a player given the community cards.
  /// Returns null if there are fewer than 5 cards available in total.
  static HandResult? evaluatePlayer(PlayerData player, List<CommunityCardData> community) {
    final cards = <EvalCard>[];

    if (player.card1.value != null && player.card1.suit != null) {
      cards.add(EvalCard.fromModel(player.card1));
    }
    if (player.card2.value != null && player.card2.suit != null) {
      cards.add(EvalCard.fromModel(player.card2));
    }

    for (final cc in community) {
      if (cc.value != null && cc.suit != null) {
        cards.add(EvalCard.fromModel(cc));
      }
    }

    if (cards.length < 5) return null;

    return PokerEvaluator.getBestHand(cards);
  }

  /// Determines the winners among a list of players.
  static List<PlayerData> determineWinners(
    List<PlayerData> players,
    List<CommunityCardData> community,
  ) {
    final activePlayers = players.where((p) => !p.isFolded).toList();
    if (activePlayers.isEmpty) return [];

    final results = <_WinnerResult>[];
    for (final p in activePlayers) {
      final hand = evaluatePlayer(p, community);
      if (hand != null) {
        results.add(_WinnerResult(p, hand));
      }
    }

    if (results.isEmpty) return [];

    results.sort((a, b) => b.hand.compareTo(a.hand));

    final winners = <PlayerData>[results[0].player];
    for (int i = 1; i < results.length; i++) {
      if (results[i].hand.compareTo(results[0].hand) == 0) {
        winners.add(results[i].player);
      } else {
        break;
      }
    }
    return winners;
  }
}

class _WinnerResult {
  final PlayerData player;
  final HandResult hand;

  _WinnerResult(this.player, this.hand);
}
