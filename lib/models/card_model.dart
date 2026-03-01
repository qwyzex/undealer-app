import './suit.dart';

class CommunityCardData {
  int? value;
  Suit? suit;
  bool flipped;
  bool locked;

  CommunityCardData({this.value, this.suit, this.flipped = false, this.locked = false});

  Map<String, dynamic> toJson() => {
        'value': value,
        'suit': suit?.index, // Save enum as index
        'flipped': flipped,
        'locked': locked,
      };

  factory CommunityCardData.fromJson(Map<String, dynamic> json) => CommunityCardData(
        value: json['value'],
        suit: json['suit'] != null ? Suit.values[json['suit']] : null,
        flipped: json['flipped'] ?? false,
        locked: json['locked'] ?? false,
      );
}
