import 'card_model.dart';

class PlayerData {
  PlayerData({
    CommunityCardData? card1,
    CommunityCardData? card2,
    this.isExpanded = false,
    this.isFolded = false,
    this.playerName = 'P',
  }) : card1 = card1 ?? CommunityCardData(),
       card2 = card2 ?? CommunityCardData();

  CommunityCardData card1;
  CommunityCardData card2;
  bool isExpanded;

  bool isFolded;

  String? playerName;

  Map<String, dynamic> toJson() => {
    'card1': card1.toJson(),
    'card2': card2.toJson(),
    'isExpanded': isExpanded,
    'isFolded': isFolded,
    'playerName': playerName,
  };

  factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
    card1: CommunityCardData.fromJson(json['card1']),
    card2: CommunityCardData.fromJson(json['card2']),
    isExpanded: json['isExpanded'] ?? false,
    isFolded: json['isFolded'] ?? false,
    playerName: json['playerName'],
  );
}
