import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EvaluationResultScreen extends StatefulWidget {
  const EvaluationResultScreen({super.key});

  @override
  State<EvaluationResultScreen> createState() => _EvaluationResultScreenState();
}

class _EvaluationResultScreenState extends State<EvaluationResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(height: 200, width: 200, color: Colors.red));
  }
}
