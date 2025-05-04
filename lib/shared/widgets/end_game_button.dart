import 'package:flutter/material.dart';
import 'package:encore_gamesheet/shared/widgets/game_button.dart';

class EndGameButton extends StatelessWidget {
  final VoidCallback onEndGame;

  const EndGameButton({
    super.key,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton.primary(
      'End Game',
      onEndGame,
    );
  }
}
