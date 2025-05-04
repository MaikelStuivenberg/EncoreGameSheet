import 'package:flutter/material.dart';
import 'package:encore_gamesheet/shared/widgets/game_button.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback onSettings;
  final bool darkMode;

  const SettingsButton({
    super.key,
    required this.onSettings,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GameButton.secondary(
      'Settings',
      onSettings,
      isDarkMode: darkMode,
    );
  }
}
