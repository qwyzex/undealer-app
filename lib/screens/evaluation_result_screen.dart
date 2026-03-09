import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/evaluation.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';

class EvaluationResultScreen extends StatefulWidget {
  final List<PlayerData> players;
  final List<CommunityCardData> communityCards;
  final List<PlayerData> winners;
  final Map<PlayerData, HandResult?> results;

  const EvaluationResultScreen({
    super.key,
    required this.players,
    required this.communityCards,
    required this.winners,
    required this.results,
  });

  @override
  State<EvaluationResultScreen> createState() => _EvaluationResultScreenState();
}

class _EvaluationResultScreenState extends State<EvaluationResultScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.results[widget.players[0]]);
    return Scaffold(
      body: SafeArea(
        child: Center(
          // child: Container(height: 200, width: 200, color: Colors.red, child: Text("TEST")),
          child: Column(
            children: widget.results.entries.map((entry) {
              final player = entry.key;
              final hand = entry.value;

              return Text("${player.playerName} — ${hand?.rankName}");
            }).toList(),
          ),
        ),
      ),
    );
  }
}
