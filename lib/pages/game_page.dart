import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:encore_gamesheet/cards/level_1.dart';
import 'package:encore_gamesheet/cards/level_2.dart';
import 'package:encore_gamesheet/cards/level_3.dart';
import 'package:encore_gamesheet/cards/level_4.dart';
import 'package:encore_gamesheet/cards/level_5.dart';
import 'package:encore_gamesheet/cards/level_6.dart';
import 'package:encore_gamesheet/cards/level_7.dart';
import 'package:encore_gamesheet/constants/box_colors.dart';
import 'package:encore_gamesheet/constants/card_points.dart';
import 'package:encore_gamesheet/constants/settings.dart';
import 'package:encore_gamesheet/models/box_color.dart';
import 'package:encore_gamesheet/pages/home_page.dart';
import 'package:encore_gamesheet/pages/settings_page.dart';
import 'package:encore_gamesheet/painters/cross_painter.dart';
import 'package:encore_gamesheet/painters/slash_painter.dart';
import 'package:encore_gamesheet/shared/widgets/game_button.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  final int level; // Add level parameter
  final bool singlePlayer; // Add singlePlayer parameter

  const GamePage({super.key, required this.level, required this.singlePlayer});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
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
  var singlePlayerGamesPlayed = 0; // Add this variable
  var multiplayerGamesPlayed = 0; // Add this variable
  Set<int> levelsPlayed = {}; // Add this variable
  int gamesWon = 0;
  int winStreak = 0;

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadSinglePlayerGamesPlayed(); // Load the count of single player games played
    loadMultiplayerGamesPlayed(); // Load the count of multiplayer games played
    loadLevelsPlayed(); // Load the levels played
    setLevel(widget.level); // Set the level based on the passed parameter
    singlePlayerMode = widget.singlePlayer; // Set the singlePlayer mode
    loadGamesWon();
    loadWinStreak();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    return Scaffold(
      backgroundColor: darkMode ? const Color.fromARGB(255, 30, 30, 30) : null,
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
                showScoreBoard(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showScoreBoard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 1),
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          showTotalScoreButton(),
          const SizedBox(height: 4),
          showSettingsButton(),
          const SizedBox(height: 4),
          showEndGameButton(),
        ],
      ),
    );
  }

  Widget showScoreBoardRow(IconData? iconPrefix, textPrefix, text, number) {
    var children = [];
    if (iconPrefix != null) {
      children.add(Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Icon(iconPrefix,
            color:
                darkMode ? const Color.fromARGB(225, 30, 30, 30) : Colors.black,
            size: 20),
      ));
    }

    if (textPrefix != "") {
      children.add(Container(
        margin: EdgeInsets.fromLTRB(children.isEmpty ? 10 : 5, 0, 0, 0),
        child: Text(
          textPrefix,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 12,
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
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(1.5, 0, 1.5, 0),
      child: Column(
        children: [
          ...optionalElements,
          Container(
            width: 90,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(
                  color: darkMode ? Colors.white : Colors.black, width: 1),
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
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(
                width: 55,
                child: Text(
                  showScore ? number.toString() : "?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget showTotalScoreButton() {
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
                    showScoreBoardRow(null, "BONUS", "=", rowBonusPoints),
                    const SizedBox(width: 8),
                    showScoreBoardRow(
                        Icons.priority_high, "(+1)", "+", bonusPoints),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    showScoreBoardRow(null, "A-O", "+", closedPoints),
                    const SizedBox(width: 8),
                    showScoreBoardRow(Icons.star, "(-2)", "-", starPoints),
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

  Widget showSettingsButton() {
    return GameButton.secondary(
      'Settings',
      () {
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
      isDarkMode: darkMode,
    );
  }

  Widget showEndGameButton() {
    return GameButton.primary(
      'End Game',
      () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Total score'),
            content:
                Text('You finished the game with ${calcTotalPoints()} points!'),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: GameButton.secondary(
                      'Cancel',
                      () {
                        Navigator.pop(context, "Cancel");
                      },
                      // isDarkMode: darkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GameButton.primary(
                      'Ok',
                      () async {
                        updateAmountOfPlayedGames();

                        final prefs = await SharedPreferences.getInstance();
                        winStreak = 0;
                        prefs.setInt(Settings.winStreak, winStreak);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
          color: darkMode ? color.colorText : color.dmColorText,
        ),
      );

      if (text.isNotEmpty) {
        content = Stack(alignment: Alignment.center, children: [star, content]);
      } else {
        content = star;
      }
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

  void updateAmountOfPlayedGames() async {
    final prefs = await SharedPreferences.getInstance();

    if (singlePlayerMode) {
      singlePlayerGamesPlayed++;
      prefs.setInt(Settings.singlePlayerGamesPlayed, singlePlayerGamesPlayed);
    } else {
      multiplayerGamesPlayed++;
      prefs.setInt(Settings.multiplayerGamesPlayed, multiplayerGamesPlayed);
    }

    levelsPlayed.add(widget.level);
    prefs.setStringList(
        Settings.levelsPlayed, levelsPlayed.map((e) => e.toString()).toList());
  }

  Future<void> loadSinglePlayerGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      singlePlayerGamesPlayed =
          prefs.getInt(Settings.singlePlayerGamesPlayed) ?? 0;
    });
  }

  Future<void> loadMultiplayerGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      multiplayerGamesPlayed =
          prefs.getInt(Settings.multiplayerGamesPlayed) ?? 0;
    });
  }

  Future<void> loadLevelsPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      levelsPlayed = (prefs.getStringList(Settings.levelsPlayed) ?? [])
          .map((e) => int.parse(e))
          .toSet();
    });
  }

  Future<void> loadGamesWon() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gamesWon = prefs.getInt(Settings.gamesWon) ?? 0;
    });
  }

  Future<void> loadWinStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      winStreak = prefs.getInt(Settings.winStreak) ?? 0;
    });
  }

  Future<bool> isSecondGame() async {
    var singlePlayerGamesPlayed = (await SharedPreferences.getInstance())
            .getInt(Settings.singlePlayerGamesPlayed) ??
        0;
    var multiplePlayerGamesPlayed = (await SharedPreferences.getInstance())
            .getInt(Settings.multiplayerGamesPlayed) ??
        0;

    return (singlePlayerGamesPlayed + multiplePlayerGamesPlayed) == 2;
  }

  void gameFinished() {
    playWinSound();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('You won!'),
        content:
            Text('You finished the game with ${calcTotalPoints()} points!'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (await InAppReview.instance.isAvailable() &&
                  await isSecondGame()) {
                InAppReview.instance.requestReview();
              }

              if (!context.mounted) return;

              Navigator.pop(context, "Cancel");
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              updateAmountOfPlayedGames();
              final prefs = await SharedPreferences.getInstance();
              gamesWon++;
              winStreak++;
              prefs.setInt(Settings.gamesWon, gamesWon);
              prefs.setInt(Settings.winStreak, winStreak);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,
              );
            },
            child: const Text('New game'),
          ),
          // TextButton(
          //   onPressed: () async {
          //     if (await InAppReview.instance.isAvailable() &&
          //         await isSecondGame()) {
          //       InAppReview.instance.requestReview();
          //     }

          //     if (!context.mounted) return;

          //     Navigator.push<List<String>>(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => ChooseCardPage(key: GlobalKey())),
          //     ).then((value) => {
          //           if (value![0] != "Cancel")
          //             {
          //               lvl = value[0],
          //               singlePlayerMode = value[1] == "single" ? true : false,
          //               resetGame(),
          //               if (context.mounted) Navigator.pop(context, "Ok")
          //             }
          //         });
          //   },
          //   child: const Text('Start new game + Show short ad'),
          // ),
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

  void setLevel(int level) {
    setState(() {
      switch (level) {
        case 1:
          card = Level1Card().getCard();
          break;
        case 2:
          card = Level2Card().getCard();
          break;
        case 3:
          card = Level3Card().getCard();
          break;
        case 4:
          card = Level4Card().getCard();
          break;
        case 5:
          card = Level5Card().getCard();
          break;
        case 6:
          card = Level6Card().getCard();
          break;
        case 7:
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
