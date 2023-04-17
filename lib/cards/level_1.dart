import 'package:encore_gamesheet/models/card_box.dart';

import '../models/card_box.dart';
import '../constants/box_colors.dart';

class Level1Card {
  final _row1 = [
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.greenBox, true),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.orangeBox, true),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox)
  ];

  final _row2 = [
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.yellowBox, true),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.yellowBox, true),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.blueBox, true),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
  ];

  final _row3 = [
    CardBox(BoxColors.blueBox, true),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox, true),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
  ];

  final _row4 = [
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox, true),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.pinkBox, true),
    CardBox(BoxColors.blueBox),
  ];

  final _row5 = [
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
  ];

  final _row6 = [
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.blueBox, true),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.pinkBox, true),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox, true),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.pinkBox, true),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.orangeBox, true),
  ];

  final _row7 = [
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.blueBox),
    CardBox(BoxColors.pinkBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.yellowBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox),
    CardBox(BoxColors.greenBox, true),
    CardBox(BoxColors.orangeBox),
    CardBox(BoxColors.orangeBox),
  ];

  List<List<CardBox>> getCard() {
    return [_row1, _row2, _row3, _row4, _row5, _row6, _row7];
  }
}
