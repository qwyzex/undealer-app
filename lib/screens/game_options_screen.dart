import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ensure provider is imported
import 'package:undealer/app_state.dart';
import 'package:undealer/components/primary_button.dart';
import 'package:undealer/models/game_options.dart';
import 'package:undealer/screens/table_screen.dart';

class GameOptionsScreen extends StatefulWidget {
  const GameOptionsScreen({super.key});

  @override
  State<GameOptionsScreen> createState() => _GameOptionsScreenState();
}

class _GameOptionsScreenState extends State<GameOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    // Use context.watch to make this widget rebuild when state changes
    final appState = context.watch<AppState>();
    final options = appState.gameOptions;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Game Options",
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF532B2B), fontSize: 30, letterSpacing: 2),
        ),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
        actions: [IconButton(onPressed: () => {}, icon: const Icon(Icons.menu))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Displaying the values to verify they update
            Text("Debug Test: ${options.test}", style: const TextStyle(fontSize: 20)),
            Text("Lock Player: ${options.lockPlayerCount}", style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // Toggleable Button for Debugging
            CupertinoButton(
              color: Colors.blueGrey,
              onPressed: () {
                // Toggle the boolean and change the test string
                final newOptions = GameOptionsModel(lockPlayerCount: !options.lockPlayerCount, setPlayerCount: options.setPlayerCount, dontCalculateFolds: options.dontCalculateFolds, playerAssignTheirOwnCard: options.playerAssignTheirOwnCard, test: !options.lockPlayerCount ? "LOCKED" : "UNLOCKED");

                appState.updateGameOptions(newOptions);
              },
              child: const Text("Toggle Debug State"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 150,
        color: Colors.transparent,
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              buttonText: "Create new game",
              height: 50,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
              },
            ),
            PrimaryButton(height: 50, onTap: () => Navigator.pop(context), secondary: true, buttonText: "Cancel"),
          ],
        ),
      ),
    );
  }
}
