import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:encore_game_sheet/cards/level_1.dart';
import 'package:encore_game_sheet/cards/level_2.dart';
import 'package:encore_game_sheet/cards/level_3.dart';
import 'package:encore_game_sheet/cards/level_4.dart';
import 'package:encore_game_sheet/cards/level_5.dart';
import 'package:encore_game_sheet/cards/level_6.dart';
import 'package:encore_game_sheet/cards/level_7.dart';
import 'package:encore_game_sheet/constants/box_colors.dart';
import 'package:encore_game_sheet/constants/card_points.dart';
import 'package:encore_game_sheet/constants/settings.dart';
import 'package:encore_game_sheet/models/box_color.dart';
import 'package:encore_game_sheet/pages/settings_page.dart';
import 'package:encore_game_sheet/painters/cross_painter.dart';
import 'package:encore_game_sheet/painters/slash_painter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'choose_card.dart';

class GamePage extends StatefulWidget {
  const GamePage({required Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // UI Settings (with default values, async loaded)
  var showScore = true;
  var darkMode = true;
  var highscore = true;
  var sounds = false;
  var colorblind = false;

  // Game settings
  var lvl = "1";
  var singlePlayerMode = false;
  var card = Level1Card().getCard();

  // Gameplay variables
  var maxBonus = 8;
  var bonusUsed = 0;
  var manualClosedColumns = [];
  var manualClosedColors = [];

  // Single player mode variables
  var turnCount = 0;
  var partlyClosedColumns = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode
          ? const Color.fromARGB(255, 30, 30, 30)
          : const Color.fromARGB(255, 240, 240, 240),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                showHeadRow(),
                showPlayField(),
                showScoreRow(),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        for (int i = 0; i < maxBonus; i = i + 2)
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 4, 0, 0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  showBonusField(i),
                                  showBonusField(i + 1)
                                ]),
                          ),
                      ],
                    ),
                    Column(
                      children: [
                        showClosedScoreRow(BoxColors.greenBox),
                        showClosedScoreRow(BoxColors.yellowBox),
                        showClosedScoreRow(BoxColors.blueBox),
                        showClosedScoreRow(BoxColors.pinkBox),
                        showClosedScoreRow(BoxColors.orangeBox),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [showScoreBoard()],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showScoreBoard() {
    final rowBonusPoints = calcClosedColorsPoints();
    final closedPoints = calcClosedColumnsPoints();
    final bonusPoints = calcBonusPoints();
    final starPoints = calcStarPoints();
    final totalPoints = calcTotalPoints();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 1),
      child: Column(
        children: [
          Row(
            children: [
              showScoreBoardRow(null, "BONUS", "=", rowBonusPoints),
              showScoreBoardRow(Icons.priority_high, "(+1)", "+", bonusPoints),
            ],
          ),
          Row(
            children: [
              showScoreBoardRow(null, "A-O", "+", closedPoints),
              showScoreBoardRow(Icons.star, "(-2)", "-", starPoints),
            ],
          ),
          Row(
            children: [
              showScoreBoardRow(null, "", "=", totalPoints, true),
              showSettingsButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget showScoreBoardRow(IconData? iconPrefix, textPrefix, text, number,
      [large = false]) {
    var children = [];
    if (iconPrefix != null) {
      children.add(Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Icon(iconPrefix,
            color: darkMode ? Colors.white : Colors.black, size: 20),
      ));
    }

    if (textPrefix != "") {
      children.add(Container(
        margin: EdgeInsets.fromLTRB(children.isEmpty ? 10 : 5, 0, 0, 0),
        child: Text(
          textPrefix,
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ));
    }

    var optionalElements = [];
    if (children.isNotEmpty) {
      optionalElements.add(SizedBox(
        width: 70,
        height: 32,
        child: Row(
          children: [
            ...children,
          ],
        ),
      ));
    } else {
      optionalElements.add(const SizedBox(width: 0, height: 20));
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(1.5, 0, 1.5, 0),
      child: Column(
        children: [
          ...optionalElements,
          Container(
            width: large ? 90 : 55,
            height: large ? 28 : 22,
            decoration: BoxDecoration(
              border: Border.all(
                  color: darkMode ? Colors.white : Colors.black,
                  width: large ? 2 : 1),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: darkMode
                  ? const Color.fromARGB(225, 30, 30, 30)
                  : const Color.fromARGB(225, 255, 255, 255),
            ),
            child: Row(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                width: 12,
                child: Text(
                  text,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: large ? 14 : 11,
                  ),
                ),
              ),
              SizedBox(
                width: large ? 55 : 25,
                child: Text(
                  showScore ? number.toString() : "?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: large ? 16 : 14,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget showSettingsButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(1.5, 0, 1.5, 0),
      width: 35,
      height: 22,
      child: IconButton(
        icon: Icon(
          Icons.settings,
          color: darkMode ? Colors.white : Colors.black,
        ),
        onPressed: () {
          Navigator.push<List<String>>(
            context,
            MaterialPageRoute(
                builder: (context) => SettingsPage(key: GlobalKey())),
          ).then((value) => {
                if (value!.isNotEmpty && value[0] != "resume")
                  {
                    setState(() {
                      lvl = value[0];
                      singlePlayerMode = value[1] == "single" ? true : false;
                      resetGame();
                    }),
                  },

                // Always load the new settings (can be changed without starting a new game)
                loadSettings(),
              });
        },
      ),
    );
  }

  Widget showClosedScoreRow(BoxColor color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 1, 0, 0),
      child: Row(
        children: [
          showColoredBox(
              color,
              false,
              false,
              manualClosedColors.contains(color),
              !manualClosedColors.contains(color) && isBoxColorClosed(color),
              false,
              "5", () {
            setState(() {
              if (singlePlayerMode) return;

              playClickSound();
              if (manualClosedColors.contains(color)) {
                manualClosedColors.remove(color);
              } else {
                manualClosedColors.add(color);
              }
            });
          }),
          showColoredBox(
              color,
              false,
              false,
              false,
              manualClosedColors.contains(color) && isBoxColorClosed(color),
              false,
              "3")
        ],
      ),
    );
  }

  Widget showBonusField(int bonusNr) {
    return GestureDetector(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(
                color: darkMode ? Colors.white : Colors.black, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(50)),
          ),
          child: Center(
            child: Icon(
              bonusNr < bonusUsed ? Icons.close : Icons.priority_high,
              size: 20,
              color: darkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        onTap: () {
          playClickSound();

          setState(() {
            if (bonusNr <= bonusUsed - 1) {
              bonusUsed--;
            } else {
              if (bonusUsed == maxBonus) {
                return;
              } else {
                bonusUsed++;
              }
            }
          });
        });
  }

  Widget showHeadRow() {
    var list = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O"
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            for (var i = 0; i < list.length; i++)
              showBox(
                  list[i],
                  list[i] == "H",
                  false,
                  partlyClosedColumns.contains(i),
                  manualClosedColumns.contains(i) ||
                      (!singlePlayerMode && isColumnFinished(i)), () {
                setState(() {
                  if (!singlePlayerMode && isColumnFinished(i)) {
                    return;
                  }

                  playClickSound();

                  if (singlePlayerMode) {
                    if (!partlyClosedColumns.contains(i)) {
                      partlyClosedColumns.add(i);
                    } else if (!manualClosedColumns.contains(i)) {
                      manualClosedColumns.add(i);

                      if (checkIfGameIsFinished()) {
                        gameFinished();
                      }
                    } else {
                      partlyClosedColumns.remove(i);
                      manualClosedColumns.remove(i);
                    }
                  } else {
                    if (manualClosedColumns.contains(i)) {
                      manualClosedColumns.remove(i);
                    } else if (!singlePlayerMode) {
                      manualClosedColumns.add(i);
                    }
                  }
                });
              })
          ],
        ),
      ],
    );
  }

  Widget showPlayField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < card.length; i++)
          Row(
            children: [
              for (var j = 0; j < card[i].length; j++)
                showColoredBox(
                    card[i][j].color,
                    j == 7,
                    card[i][j].star,
                    card[i][j].checked,
                    false,
                    colorblind,
                    colorblind ? card[i][j].color.textValue : "", () {
                  setState(() {
                    // Check if allowed
                    // One of TRBL-boxes should be crossed already
                    // Middle column always allowed
                    if ((j > 0 && card[i][j - 1].checked) ||
                        (j < (CardPoints.first.length - 1) &&
                            card[i][j + 1].checked) ||
                        ((i > 0 && card[i - 1][j].checked) ||
                            (i < 6 && card[i + 1][j].checked)) ||
                        j == 7) {
                      // Flip boolean
                      card[i][j].checked = !card[i][j].checked;

                      playClickSound();
                    }

                    if (checkIfGameIsFinished()) {
                      gameFinished();
                    }
                  });
                }),
            ],
          ),
      ],
    );
  }

  Widget showScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            for (var i = 0; i < CardPoints.first.length; i++)
              showBox(
                  // Show always the first row in single player mode
                  (manualClosedColumns.contains(i) && !singlePlayerMode
                          ? CardPoints.second[i]
                          : CardPoints.first[i])
                      .toString(),
                  false,
                  isColumnFinished(i))
          ],
        ),
      ],
    );
  }

  Widget showBox(String text,
      [bool highlight = false,
      circle = false,
      slashed = false,
      checked = false,
      onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(1.5, 1.5, 1.5, 1.5),
        width: getDefaultBoxSize() - 3,
        height: getDefaultBoxSize() - 3,
        decoration: BoxDecoration(
          border: Border.all(
              color: darkMode ? Colors.white : Colors.black, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: darkMode
              ? const Color.fromARGB(225, 30, 30, 30)
              : const Color.fromARGB(225, 255, 255, 255),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              circle
                  ? Icon(
                      Icons.circle_outlined,
                      color: darkMode ? Colors.white : Colors.black,
                    )
                  : const Text(""),
              Text(
                text,
                style: TextStyle(
                  color: highlight
                      ? Colors.red
                      : darkMode
                          ? Colors.white
                          : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: circle ? 16 : 20,
                ),
              ),
              checked || slashed
                  ? CustomPaint(
                      size: Size(
                          getDefaultBoxSize() - 3, getDefaultBoxSize() - 3),
                      painter: checked
                          ? CrossPainter(
                              color: darkMode ? Colors.white : Colors.black)
                          : SlashPainter(
                              color: darkMode ? Colors.white : Colors.black),
                    )
                  : const Text(""),
            ],
          ),
        ),
      ),
    );
  }

  Widget showColoredBox(BoxColor color,
      [bool highlight = false,
      bool showStar = false,
      bool checked = false,
      bool circle = false,
      bool smallTxt = false,
      String text = "",
      onTap]) {
    Widget content = Opacity(
      opacity: 0.4,
      child: Text(
        text,
        style: TextStyle(
          color: darkMode ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: circle ? 14 : 20,
        ),
      ),
    );

    if (showStar) {
      var star = Opacity(
        opacity: 0.8,
        child: Icon(
          showStar ? Icons.star : null,
          color: darkMode ? color.dmColorText : color.colorText,
        ),
      );

      if (text.isNotEmpty)
        content = Stack(alignment: Alignment.center, children: [star, content]);
      else
        content = star;
    }

    if (checked) {
      var opWidget = Opacity(
        opacity: 0.8,
        child: CustomPaint(
          size: Size(getDefaultBoxSize() - 3, getDefaultBoxSize() - 3),
          painter: CrossPainter(color: Colors.black),
        ),
      );

      // if (showStar) {
      content =
          Stack(alignment: Alignment.center, children: [content, opWidget]);
      // } else {
      //   content = opWidget;
      // }
    }

    if (circle) {
      content = Stack(alignment: Alignment.center, children: [
        const Icon(
          Icons.circle_outlined,
          color: Colors.black,
        ),
        content
      ]);
    }

    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: getDefaultBoxSize(),
          height: getDefaultBoxSize(),
          decoration: BoxDecoration(
            border: Border.all(
                color: highlight ? Colors.white : Colors.black, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: darkMode ? color.dmColor : color.color,
          ),
          child: Center(
            child: content,
          ),
        ));
  }

  double getDefaultBoxSize() {
    var maxWidth = (MediaQuery.of(context).size.width - 170) / 16;
    var maxHeight = MediaQuery.of(context).size.height / 11;
    return maxHeight > maxWidth ? maxWidth : maxHeight;
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      showScore = prefs.getBool(Settings.showCurrentPoints) ?? true;
      darkMode = prefs.getBool(Settings.darkMode) ?? true;
      highscore = prefs.getBool(Settings.highscore) ?? true;
      sounds = prefs.getBool(Settings.sounds) ?? false;
      colorblind = prefs.getBool(Settings.colorblind) ?? false;

      // currentHighscore = prefs.getInt(CURRENT_HIGHSCORE);
    });
  }

  bool isColumnFinished(int column) {
    return card.every((element) => element[column].checked);
  }

  int calcClosedColumnsPoints() {
    var points = 0;

    for (int i = 0; i < CardPoints.first.length; i++) {
      if (!card.every((row) => row[i].checked)) continue;

      if (manualClosedColumns.contains(i) && !singlePlayerMode) {
        points += CardPoints.second[i];
      } else {
        // Use also these points in single player mode
        points += CardPoints.first[i];
      }
    }

    return points;
  }

  int calcClosedColorsPoints() {
    var points = 0;

    if (isBoxColorClosed(BoxColors.greenBox)) {
      points += manualClosedColors.contains(BoxColors.greenBox) ? 3 : 5;
    }
    if (isBoxColorClosed(BoxColors.yellowBox)) {
      points += manualClosedColors.contains(BoxColors.yellowBox) ? 3 : 5;
    }
    if (isBoxColorClosed(BoxColors.blueBox)) {
      points += manualClosedColors.contains(BoxColors.blueBox) ? 3 : 5;
    }
    if (isBoxColorClosed(BoxColors.pinkBox)) {
      points += manualClosedColors.contains(BoxColors.pinkBox) ? 3 : 5;
    }
    if (isBoxColorClosed(BoxColors.orangeBox)) {
      points += manualClosedColors.contains(BoxColors.orangeBox) ? 3 : 5;
    }

    return points;
  }

  int calcBonusPoints() {
    return maxBonus - bonusUsed;
  }

  int calcStarPoints() {
    return card
            .expand((element) => element)
            .where((element) => element.star && !element.checked)
            .length *
        2;
  }

  int calcTotalPoints() {
    return calcClosedColorsPoints() +
        calcClosedColumnsPoints() +
        calcBonusPoints() -
        calcStarPoints();
  }

  bool isBoxColorClosed(BoxColor color) {
    return card.every((row) => row
        .where((element) => element.color == color)
        .every((element) => element.checked));
  }

  bool checkIfGameIsFinished() {
    if (singlePlayerMode) {
      return manualClosedColumns.length == 15;
    }

    var closedCount = 0;
    if (isBoxColorClosed(BoxColors.greenBox)) closedCount++;
    if (isBoxColorClosed(BoxColors.yellowBox)) closedCount++;
    if (isBoxColorClosed(BoxColors.blueBox)) closedCount++;
    if (isBoxColorClosed(BoxColors.pinkBox)) closedCount++;
    if (isBoxColorClosed(BoxColors.orangeBox)) closedCount++;

    return closedCount >= 2;
  }

  void gameFinished() {
    playWinSound();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Finished!'),
        content:
            Text('You finished the game with ${calcTotalPoints()} points!'),
        actions: <Widget>[
          TextButton(
            onPressed: () => {Navigator.pop(context, "Cancel")},
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {
              Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                    builder: (context) => ChooseCardPage(key: GlobalKey())),
              ).then((value) => {
                    if (value![0] != "Cancel")
                      {
                        lvl = value[0],
                        singlePlayerMode = value[1] == "single" ? true : false,
                        resetGame(),
                        Navigator.pop(context, "Ok")
                      }
                  }),
            },
            child: const Text('Start new game'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      bonusUsed = 0;
      manualClosedColors = [];
      manualClosedColumns = [];
      partlyClosedColumns = [];

      switch (lvl) {
        case "1":
          card = Level1Card().getCard();
          break;
        case "2":
          card = Level2Card().getCard();
          break;
        case "3":
          card = Level3Card().getCard();
          break;
        case "4":
          card = Level4Card().getCard();
          break;
        case "5":
          card = Level5Card().getCard();
          break;
        case "6":
          card = Level6Card().getCard();
          break;
        case "7":
          card = Level7Card().getCard();
          break;
      }
    });
  }

  void playWinSound() {
    if (!sounds) return;
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/win.wav"),
      autoStart: true,
      showNotification: false,
    );
  }

  void playClickSound() {
    if (!sounds) return;
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/click.wav"),
      autoStart: true,
      showNotification: false,
    );
  }
}
