import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:undealer/app_state.dart';
import 'package:undealer/components/primary_button.dart';
import 'package:undealer/models/game_options.dart';
import 'package:undealer/screens/table_screen.dart';
import 'package:undealer/theme/colors.dart';

class GameOptionsScreen extends StatefulWidget {
  const GameOptionsScreen({super.key});

  @override
  State<GameOptionsScreen> createState() => _GameOptionsScreenState();
}

class _GameOptionsScreenState extends State<GameOptionsScreen> {
  // Local state to hold modifications before starting the game
  late bool _lockPlayerCount;
  late int _playerCount;
  late bool _dontCalculateFolds;
  late bool _playerAssignTheirOwnCard;

  @override
  void initState() {
    super.initState();
    // Initialize local state from current AppState
    final initialOptions = context.read<AppState>().gameOptions;
    _lockPlayerCount = initialOptions.lockPlayerCount;
    _playerCount = initialOptions.setPlayerCount;
    _dontCalculateFolds = initialOptions.dontCalculateFolds;
    _playerAssignTheirOwnCard = initialOptions.playerAssignTheirOwnCard;
  }

  Widget _buildOptionRow({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    //*************************************************************************//

    Widget sectionName(String text, [bool? disableTopMargin = false]) {
      return Column(
        children: [
          SizedBox(height: disableTopMargin == true ? 0 : 30),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    Widget sectionDivider() {
      return const Divider(height: 40);
    }

    //*************************************************************************//

    void onNewGame() {
      appState.initializeNewGame(
        GameOptionsModel(
          lockPlayerCount: _lockPlayerCount,
          setPlayerCount: _playerCount,
          dontCalculateFolds: _dontCalculateFolds,
          playerAssignTheirOwnCard: _playerAssignTheirOwnCard,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')),
      );
    }

    void onCancel() {
      Navigator.pop(context);
    }

    //*************************************************************************//

    void handleToggleLockPlayerCount() {
      setState(() {
        _lockPlayerCount = !_lockPlayerCount;
      });
    }

    void incrementPlayerCount() {
      if (_playerCount >= 20) return;

      setState(() {
        _playerCount++;
      });
    }

    void decrementPlayerCount() {
      if (_playerCount <= 1) return;

      setState(() {
        _playerCount--;
      });
    }

    void handleTogglePassiveMode() {
      setState(() {
        _dontCalculateFolds = !_dontCalculateFolds;
      });
    }

    void handleToggleCardAssigner() {
      setState(() {
        _playerAssignTheirOwnCard = !_playerAssignTheirOwnCard;
      });
    }

    //*************************************************************************//

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Game Options",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF532B2B),
            fontSize: 26,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: /* REPLACE WITH BURGER MENU LOGIC */ [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionName("PREFERENCES", true),

            // Fixed Player Count Toggle
            _buildOptionRow(
              title: "Fixed Player Count",
              subtitle: "Lock the table to a specific number of players",
              trailing: CupertinoSwitch(
                value: _lockPlayerCount,
                activeTrackColor: Colors.pinkAccent,
                onChanged: (val) => handleToggleLockPlayerCount(),
              ),
            ),

            // Set Player Count (Conditional UI)
            AnimatedOpacity(
              opacity: _lockPlayerCount ? 1.0 : 0.3,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_lockPlayerCount,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Number of Players",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: decrementPlayerCount,
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.pinkAccent),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.deepShade, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$_playerCount",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: incrementPlayerCount,
                            icon: const Icon(Icons.add_circle_outline, color: Colors.pinkAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            sectionDivider(),

            // Don't Calculate Folds
            _buildOptionRow(
              title: "Passive Mode",
              subtitle: "Disregards cards fold state when evaluating",
              trailing: CupertinoCheckbox(
                value: _dontCalculateFolds,
                activeColor: Colors.pinkAccent,
                onChanged: (val) => handleTogglePassiveMode(),
              ),
            ),

            sectionName("GAMEPLAY MODE"),

            // Dealer vs Player Assignment
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _playerAssignTheirOwnCard,
                backgroundColor: AppColors.deepShade,
                thumbColor: Colors.white,
                padding: const EdgeInsets.all(4),
                children: const {
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Dealer Controlled", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Player Controlled", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) handleToggleCardAssigner();
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 5),
              child: Text(
                "Determines if the dealer scans all cards or if players scan their own hole cards.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 150,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(buttonText: "Create New Game", height: 55, onTap: onNewGame),
            const SizedBox(height: 12),
            PrimaryButton(buttonText: "Cancel", height: 50, secondary: true, onTap: onCancel),
          ],
        ),
      ),
    );
  }
}
