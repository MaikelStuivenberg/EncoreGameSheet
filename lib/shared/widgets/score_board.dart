import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final Widget totalScoreButton;
  final Widget settingsButton;
  final Widget endGameButton;

  const ScoreBoard({
    Key? key,
    required this.totalScoreButton,
    required this.settingsButton,
    required this.endGameButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 1),
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          totalScoreButton,
          const SizedBox(height: 4),
          settingsButton,
          const SizedBox(height: 4),
          endGameButton,
        ],
      ),
    );
  }
}
