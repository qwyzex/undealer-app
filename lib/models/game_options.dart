class GameOptionsModel {
  bool lockPlayerCount;
  int setPlayerCount;
  bool dontCalculateFolds;
  bool playerAssignTheirOwnCard;

  GameOptionsModel({
    this.lockPlayerCount = false,
    this.setPlayerCount = 6,
    this.dontCalculateFolds = false,
    this.playerAssignTheirOwnCard = true,
  });

  Map<String, dynamic> toJson() => {
    'lockPlayerCount': lockPlayerCount,
    'setPlayerCount': setPlayerCount,
    'dontCalculateFolds': dontCalculateFolds,
    'playerAssignTheirOwnCard': playerAssignTheirOwnCard,
  };

  factory GameOptionsModel.fromJson(Map<String, dynamic> json) => GameOptionsModel(
    lockPlayerCount: json['lockPlayerCount'],
    setPlayerCount: json['setPlayerCount'],
    dontCalculateFolds: json['dontCalculateFolds'],
    playerAssignTheirOwnCard: json['playerAssignTheirOwnCard'],
  );
}
