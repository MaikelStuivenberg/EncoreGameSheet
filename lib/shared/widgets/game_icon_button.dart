import 'package:flutter/material.dart';

class GameIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color iconColor;

  const GameIconButton._({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.iconColor,
  });

  factory GameIconButton.primary(IconData icon, VoidCallback onPressed) {
    return GameIconButton._(
      icon: icon,
      onPressed: onPressed,
      color: Colors.blue,
      iconColor: Colors.white,
    );
  }

  factory GameIconButton.secondary(IconData icon, VoidCallback onPressed) {
    return GameIconButton._(
      icon: icon,
      onPressed: onPressed,
      color: Colors.white,
      iconColor: Colors.black,
    );
  }

  @override
  _GameButtonState createState() => _GameButtonState();
}

class _GameButtonState extends State<GameIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        margin: EdgeInsets.only(top: _isPressed ? 2 : 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            top: BorderSide(color: Colors.blue[900]!, width: 2),
            left: BorderSide(color: Colors.blue[900]!, width: 2),
            right: BorderSide(color: Colors.blue[900]!, width: 2),
            bottom:
                BorderSide(color: Colors.blue[900]!, width: _isPressed ? 2 : 4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Center(
          child: Icon(
            widget.icon,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}
