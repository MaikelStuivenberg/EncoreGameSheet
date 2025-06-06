import 'package:flutter/material.dart';

class GameButton extends StatefulWidget {
  final String text;
  final String? badgeLabel;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final bool isDarkMode;

  const GameButton._({
    required this.text,
    this.badgeLabel,
    required this.onPressed,
    required this.color,
    required this.textColor,
    this.isDarkMode = false,
  });

  factory GameButton.primary(String text, VoidCallback onPressed,
      {String? badgeLabel, bool isDarkMode = false}) {
    return GameButton._(
      text: text,
      badgeLabel: badgeLabel,
      onPressed: onPressed,
      color: Colors.blue,
      textColor: Colors.white,
      isDarkMode: isDarkMode,
    );
  }

  factory GameButton.secondary(String text, VoidCallback onPressed,
      {String? badgeLabel, bool isDarkMode = false}) {
    return GameButton._(
      text: text,
      badgeLabel: badgeLabel,
      onPressed: onPressed,
      color: isDarkMode ? Colors.blue[900]! : Colors.white,
      textColor: isDarkMode ? Colors.white : Colors.black,
      isDarkMode: isDarkMode,
    );
  }

  @override
  _GameButtonState createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: _isPressed ? 2 : 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            top: BorderSide(
                color:
                    widget.isDarkMode ? Colors.blue[700]! : Colors.blue[900]!,
                width: 2),
            left: BorderSide(
                color:
                    widget.isDarkMode ? Colors.blue[700]! : Colors.blue[900]!,
                width: 2),
            right: BorderSide(
                color:
                    widget.isDarkMode ? Colors.blue[700]! : Colors.blue[900]!,
                width: 2),
            bottom: BorderSide(
                color:
                    widget.isDarkMode ? Colors.blue[700]! : Colors.blue[900]!,
                width: _isPressed ? 2 : 4),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: widget.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.badgeLabel != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.badgeLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
