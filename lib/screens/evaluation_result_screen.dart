import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:undealer/theme/colors.dart';
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
    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        colors: [Color(0xFF281B1B), Color(0xFFEA8665)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.075, 1.0],
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.share))],
        title: Text("Game Results"),
        centerTitle: true,
        backgroundColor: AppColors.transparent,
      ),
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
