import 'dart:ui';
import 'package:encore_game_sheet/models/box_color.dart';

class BoxColors {
  BoxColors._();

  static var greenBox = BoxColor(
      const Color.fromRGBO(118, 158, 59, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(118, 158, 59, 1),
      const Color.fromRGBO(0, 0, 0, 1));

  static var pinkBox = BoxColor(
      const Color.fromRGBO(238, 62, 117, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(238, 62, 117, 1),
      const Color.fromRGBO(0, 0, 0, 1));

  static var yellowBox = BoxColor(
      const Color.fromRGBO(226, 177, 51, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(226, 177, 51, 1),
      const Color.fromRGBO(0, 0, 0, 1));

  static var blueBox = BoxColor(
      const Color.fromRGBO(97, 177, 241, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(97, 177, 241, 1),
      const Color.fromRGBO(0, 0, 0, 1));

  static var orangeBox = BoxColor(
      const Color.fromRGBO(238, 122, 68, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(238, 122, 68, 1),
      const Color.fromRGBO(0, 0, 0, 1));
}
