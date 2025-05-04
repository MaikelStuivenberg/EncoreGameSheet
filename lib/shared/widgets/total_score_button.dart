import 'package:flutter/material.dart';
import 'package:encore_gamesheet/shared/widgets/game_button.dart';
import 'package:encore_gamesheet/shared/widgets/score_board_row.dart';

class TotalScoreButton extends StatelessWidget {
  final bool isOnline;
  final bool isMyTurn;
  final bool showScore;
  final int Function() calcTotalPoints;
  final int Function() calcClosedColorsPoints;
  final int Function() calcClosedColumnsPoints;
  final int Function() calcBonusPoints;
  final int Function() calcStarPoints;
  final bool darkMode;
  final String? currentTurn;
  final String? playerName;
  final VoidCallback onNextPlayer;

  const TotalScoreButton({
    super.key,
    required this.isOnline,
    required this.isMyTurn,
    required this.showScore,
    required this.calcTotalPoints,
    required this.calcClosedColorsPoints,
    required this.calcClosedColumnsPoints,
    required this.calcBonusPoints,
    required this.calcStarPoints,
    required this.darkMode,
    required this.currentTurn,
    required this.playerName,
    required this.onNextPlayer,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return GameButton.primary(
        isMyTurn ? 'Next Player' : 'Waiting...',
        isMyTurn ? onNextPlayer : () {},
      );
    }
    return GameButton.secondary(
      showScore ? '${calcTotalPoints()} points' : 'Score',
      () {
        final rowBonusPoints = calcClosedColorsPoints();
        final closedPoints = calcClosedColumnsPoints();
        final bonusPoints = calcBonusPoints();
        final starPoints = calcStarPoints();

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Total score'),
            content: Column(
              children: [
                Row(
                  children: [
                    ScoreBoardRow(
                      iconPrefix: null,
                      textPrefix: "BONUS",
                      text: "=",
                      number: rowBonusPoints,
                      darkMode: darkMode,
                      showScore: showScore,
                    ),
                    const SizedBox(width: 8),
                    ScoreBoardRow(
                      iconPrefix: Icons.priority_high,
                      textPrefix: "(+1)",
                      text: "+",
                      number: bonusPoints,
                      darkMode: darkMode,
                      showScore: showScore,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ScoreBoardRow(
                      iconPrefix: null,
                      textPrefix: "A-O",
                      text: "+",
                      number: closedPoints,
                      darkMode: darkMode,
                      showScore: showScore,
                    ),
                    const SizedBox(width: 8),
                    ScoreBoardRow(
                      iconPrefix: Icons.star,
                      textPrefix: "(-2)",
                      text: "-",
                      number: starPoints,
                      darkMode: darkMode,
                      showScore: showScore,
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              GameButton.primary(
                'Ok',
                () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
      isDarkMode: darkMode,
    );
  }
}
