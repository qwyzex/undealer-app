import 'package:flutter/material.dart';
import '../logic/evaluation.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';

class EvaluationResultScreen extends StatefulWidget {
  final List<PlayerData> players;
  final List<CommunityCardData> communityCards;
  final List<PlayerData> winners;

  final List<PlayerEvaluation> results;

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView.builder(
            itemCount: widget.results.length,
            itemBuilder: (_, i) {
              final r = widget.results[i];

              return Text("${i + 1}. ${r.player.playerName} — ${r.hand.rankName}");
            },
          ),
        ),
      ),
    );
  }
}
