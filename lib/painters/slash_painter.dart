import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SlashPainter extends CustomPainter {
  Color color;

  SlashPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.lines;

    // final points1 = [
    //   const Offset(8, 8),
    //   Offset(size.width - 8, size.height - 8),
    // ];

    final points2 = [
      Offset(size.width - 8, 8),
      Offset(8, size.height - 8),
    ];

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(pointMode, points2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
