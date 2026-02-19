import 'package:flutter/foundation.dart';
import 'package:undealer/models/card_model.dart';
import 'package:undealer/models/suit.dart';

class AppState extends ChangeNotifier {
  final List<CommunityCardData> communityCards = List.generate(5, (_) => CommunityCardData());

  // In the future, you can add player hands here

  Set<Suit> getUnavailableSuitsForValue(int value) {
    final Set<Suit> unavailable = {};
    for (var card in communityCards) {
      if (card.value == value && card.suit != null) {
        unavailable.add(card.suit!);
      }
    }
    // In the future, also check player hands
    return unavailable;
  }

  void setCommunityCard(int index, int value, Suit suit) {
    communityCards[index].value = value;
    communityCards[index].suit = suit;
    communityCards[index].flipped = true;
    notifyListeners();
  }

  void clearCard(int index) {
    communityCards[index] = CommunityCardData();
    notifyListeners();
  }
}
