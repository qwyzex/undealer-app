import 'card_model.dart';

enum PlayerHandState { empty, editing, collapsed }

class PlayerHand {
  List<CommunityCardData> cards = List.generate(2, (_) => CommunityCardData());
  PlayerHandState state = PlayerHandState.empty;

  PlayerHand();

  bool get isComplete {
    return cards.every((card) => card.value != null && card.suit != null);
  }
}
