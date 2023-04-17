import 'dart:ui';
import 'package:encore_gamesheet/models/box_color.dart';

class BoxColors {
  BoxColors._();

  static var greenBox = BoxColor(
      const Color.fromRGBO(118, 158, 59, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(118, 158, 59, 1),
      const Color.fromARGB(255, 50, 50, 50),
      "G");

  static var pinkBox = BoxColor(
      const Color.fromRGBO(238, 62, 117, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(238, 62, 117, 1),
      const Color.fromARGB(255, 50, 50, 50),
      "R");

  static var yellowBox = BoxColor(
      const Color.fromRGBO(226, 177, 51, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(226, 177, 51, 1),
      const Color.fromARGB(255, 50, 50, 50),
      "Y");

  static var blueBox = BoxColor(
      const Color.fromRGBO(97, 177, 241, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(97, 177, 241, 1),
      const Color.fromARGB(255, 50, 50, 50),
      "B");

  static var orangeBox = BoxColor(
      const Color.fromRGBO(238, 122, 68, 1),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(238, 122, 68, 1),
      const Color.fromARGB(255, 50, 50, 50),
      "O");
}
