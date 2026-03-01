import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:undealer/components/primary_button.dart';
import 'package:undealer/screens/table_screen.dart';

class GameOptionsScreen extends StatefulWidget {
  const GameOptionsScreen({super.key});

  @override
  State<GameOptionsScreen> createState() => _GameOptionsScreenState();
}

class _GameOptionsScreenState extends State<GameOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Game Options",
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF532B2B), fontSize: 30, letterSpacing: 2),
        ),
        leading: IconButton(onPressed: () => {Navigator.pop(context)}, icon: const Icon(Icons.arrow_back_ios)),
        actions: [IconButton(onPressed: () => {}, icon: const Icon(Icons.menu))],
      ),
      body: Container(),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 150,
        color: Colors.transparent,
        child: Column(
          // spacing: 20,
          children: [
            PrimaryButton(
              buttonText: "Create new game",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TableRoom(title: 'undealer')));
              },
            ),
            PrimaryButton(secondary: true, buttonText: "Cancel"),
          ],
        ),
      ),
    );
  }
}
