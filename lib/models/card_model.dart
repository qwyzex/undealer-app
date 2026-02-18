import './suit.dart';

class CommunityCardData {
  int? value;
  Suit? suit;
  bool flipped;
  bool locked;

  CommunityCardData({this.value, this.suit, this.flipped = false, this.locked = false});
}
