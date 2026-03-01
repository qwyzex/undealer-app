class GameOptionsModel {
  bool lockPlayerCount;
  int setPlayerCount;
  bool dontCalculateFolds;
  bool playerAssignTheirOwnCard;
  String test;

  GameOptionsModel({this.lockPlayerCount = false, this.setPlayerCount = 6, this.dontCalculateFolds = false, this.playerAssignTheirOwnCard = true, this.test = "RAW"});

  Map<String, dynamic> toJson() => {'lockPlayerCount': lockPlayerCount, 'setPlayerCount': setPlayerCount, 'dontCalculateFolds': dontCalculateFolds, 'playerAssignTheirOwnCard': playerAssignTheirOwnCard, 'test': test};

  factory GameOptionsModel.fromJson(Map<String, dynamic> json) => GameOptionsModel(lockPlayerCount: json['lockPlayerCount'], setPlayerCount: json['setPlayerCount'], dontCalculateFolds: json['dontCalculateFolds'], playerAssignTheirOwnCard: json['playerAssignTheirOwnCard'], test: json['test']);
}
