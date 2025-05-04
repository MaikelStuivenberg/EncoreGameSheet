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
import 'package:encore_gamesheet/shared/widgets/score_board.dart';
import 'package:encore_gamesheet/shared/widgets/score_board_row.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/supabase_client.dart';
import 'package:encore_gamesheet/shared/widgets/total_score_button.dart';
import 'package:encore_gamesheet/shared/widgets/settings_button.dart';
import 'package:encore_gamesheet/shared/widgets/end_game_button.dart';

class GamePage extends StatefulWidget {
  final int level; // Add level parameter
  final bool singlePlayer; // Add singlePlayer parameter
  final String? gameCode; // For online multiplayer
  final String? playerName; // For online multiplayer

  const GamePage({
    super.key,
    required this.level,
    required this.singlePlayer,
    this.gameCode,
    this.playerName,
  });

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

  String? currentTurn;
  List<String> onlinePlayers = [];
  RealtimeChannel? _gameChannel;
  RealtimeChannel? _playerChannel;
  RealtimeChannel? _gameColumnsChannel;
  bool get isOnline => widget.gameCode != null && widget.playerName != null;

  // Add this to the state variables at the top of the class
  Map<int, String> dbClosedColumns = {};
  Map<String, String> dbClosedColors = {};

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadSinglePlayerGamesPlayed();
    loadMultiplayerGamesPlayed();
    loadLevelsPlayed();
    setLevel(widget.level);
    singlePlayerMode = widget.singlePlayer;
    loadGamesWon();
    loadWinStreak();

    if (isOnline && widget.gameCode != null) {
      _fetchCurrentTurn();
      _fetchOnlinePlayers();

      _subscribeToPlayerStates();
      _subscribeToGameUpdates();
    }
  }

  Future<void> _fetchCurrentTurn() async {
    final game = await SupabaseClientManager.client
        .from('games')
        .select('current_turn')
        .eq('code', widget.gameCode!)
        .maybeSingle();

    setState(() {
      currentTurn = game!['current_turn'] as String;
    });
  }

  Future<void> _fetchOnlinePlayers() async {
    final data = await SupabaseClientManager.client
        .from('players')
        .select('name')
        .eq('game_code', widget.gameCode!)
        .order('joined_at');

    setState(() {
      onlinePlayers = List<String>.from(data.map((e) => e['name']));
    });
  }

  Future<void> _nextPlayer() async {
    // Always save the game state before advancing to the next player
    await _saveGameState();

    // Automatically determine closed columns (A-O) before saving in online games
    await _saveClosedColumns();

    // Determine the next player
    final idx = onlinePlayers.indexOf(widget.playerName!);
    final nextIdx = (idx + 1) % onlinePlayers.length;
    final nextPlayer = onlinePlayers[nextIdx];
    debugPrint('Advancing turn from "${widget.playerName}" to "$nextPlayer"');

    try {
      await SupabaseClientManager.client
          .from('games')
          .update({'current_turn': nextPlayer}).eq('code', widget.gameCode!);
    } catch (e) {
      debugPrint('Failed to update current_turn: $e');
    }
  }

  Future<void> _saveClosedColumns() async {
    Map<int, String> autoClosedColumns = {};
    for (int i = 0; i < card[0].length; i++) {
      if (card.every((row) => row[i].checked)) {
        autoClosedColumns[i] = widget.playerName!;
      }
    }
    // Merge with dbClosedColumns, but don't overwrite existing
    final updatedClosedColumns = Map<int, String>.from(dbClosedColumns);
    autoClosedColumns.forEach((k, v) {
      updatedClosedColumns.putIfAbsent(k, () => v);
    });
    dbClosedColumns = updatedClosedColumns;

    // --- Closed Colors logic ---
    Map<String, String> autoClosedColors = {};
    for (var color in [
      BoxColors.greenBox,
      BoxColors.yellowBox,
      BoxColors.blueBox,
      BoxColors.pinkBox,
      BoxColors.orangeBox
    ]) {
      if (card.every((row) => row
          .where((element) => element.color == color)
          .every((element) => element.checked))) {
        autoClosedColors[color.textValue] = widget.playerName!;
      }
    }
    final updatedClosedColors = Map<String, String>.from(dbClosedColors);
    autoClosedColors.forEach((k, v) {
      updatedClosedColors.putIfAbsent(k, () => v);
    });
    dbClosedColors = updatedClosedColors;

    await SupabaseClientManager.client.from('games').update({
      'closed_columns':
          dbClosedColumns.map((k, v) => MapEntry(k.toString(), v)),
      'closed_colors': dbClosedColors,
    }).eq('code', widget.gameCode!);
  }

  Future<void> _saveGameState() async {
    final state = _serializeGameState();
    await SupabaseClientManager.client
        .from('players')
        .update({'game_state': state})
        .eq('game_code', widget.gameCode!)
        .eq('name', widget.playerName!);
  }

  Map<String, dynamic> _serializeGameState() {
    return {
      'checked':
          card.map((row) => row.map((box) => box.checked).toList()).toList(),
      'bonusUsed': bonusUsed,
    };
  }

  void _subscribeToPlayerStates() {
    _playerChannel = SupabaseClientManager.client.channel('public:players')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'players',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'game_code',
          value: widget.gameCode!,
        ),
        callback: (payload) {
          // final newRow = payload.newRecord;
        },
      )
      ..subscribe();
  }

  void _subscribeToGameUpdates() {
    _gameColumnsChannel = SupabaseClientManager.client.channel('public:games')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'games',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'code',
          value: widget.gameCode!,
        ),
        callback: (payload) async {
          final newRow = payload.newRecord;
          debugPrint('current_turn updated to "${newRow['current_turn']}"');

          setState(() {
            dbClosedColumns = newRow['closed_columns'] != null
                ? Map<int, String>.from((newRow['closed_columns'] as Map)
                    .map((k, v) => MapEntry(int.parse(k), v)))
                : {};
            dbClosedColors = newRow['closed_colors'] != null
                ? Map<String, String>.from(newRow['closed_colors'])
                : {};
            currentTurn = newRow['current_turn'] as String;
          });
        },
      )
      ..subscribe();
  }

  @override
  void dispose() {
    _gameChannel?.unsubscribe();
    _playerChannel?.unsubscribe();
    _gameColumnsChannel?.unsubscribe();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    final isMyTurn = !isOnline || currentTurn == widget.playerName;

    debugPrint(
        'Build: currentTurn=$currentTurn, playerName=${widget.playerName}');

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
              darkMode ? const Color.fromARGB(255, 30, 30, 30) : null,
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
        ),
        if (isOnline && !isMyTurn)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Text(
                  'Waiting for $currentTurn...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget showScoreBoard() {
    return ScoreBoard(
      totalScoreButton: showTotalScoreButton(),
      settingsButton: showSettingsButton(),
      endGameButton: showEndGameButton(),
    );
  }

  Widget showScoreBoardRow(IconData? iconPrefix, textPrefix, text, number) {
    return ScoreBoardRow(
      iconPrefix: iconPrefix,
      textPrefix: textPrefix,
      text: text,
      number: number,
      darkMode: darkMode,
      showScore: showScore,
    );
  }

  Widget showTotalScoreButton() {
    final isMyTurn = currentTurn == widget.playerName;
    return TotalScoreButton(
      isOnline: isOnline,
      isMyTurn: isMyTurn,
      showScore: showScore,
      calcTotalPoints: calcTotalPoints,
      calcClosedColorsPoints: calcClosedColorsPoints,
      calcClosedColumnsPoints: calcClosedColumnsPoints,
      calcBonusPoints: calcBonusPoints,
      calcStarPoints: calcStarPoints,
      darkMode: darkMode,
      currentTurn: currentTurn,
      playerName: widget.playerName,
      onNextPlayer: _nextPlayer,
    );
  }

  Widget showSettingsButton() {
    return SettingsButton(
      onSettings: () {
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
      darkMode: darkMode,
    );
  }

  Widget showEndGameButton() {
    return EndGameButton(
      onEndGame: () {
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
              manualClosedColors.contains(color) ||
                  (dbClosedColors.containsKey(color.textValue) &&
                      !isBoxColorFirstClosedByMe(color)),
              !manualClosedColors.contains(color) &&
                  (dbClosedColors.containsKey(color.textValue) &&
                      isBoxColorFirstClosedByMe(color)),
              false,
              "5", () {
            setState(() {
              if (singlePlayerMode || isOnline) return;

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
              manualClosedColors.contains(color) ||
                  (isBoxColorClosedByMe(color) &&
                      !isBoxColorFirstClosedByMe(color)),
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
                      dbClosedColumns.containsKey(i) ||
                      (!singlePlayerMode && isColumnFinished(i)), () async {
                playClickSound();
                if (singlePlayerMode) {
                  setState(() {
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
                  });
                } else if (isOnline) {
                  // Multiplayer: do nothing, columns cannot be closed manually
                  // Optionally, show a message or ignore the tap
                } else {
                  setState(() {
                    if (manualClosedColumns.contains(i)) {
                      manualClosedColumns.remove(i);
                    } else {
                      manualClosedColumns.add(i);
                    }
                  });
                }
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
                  // Points logic: local closed = first, db closed (not local) = second, else first
                  (manualClosedColumns.contains(i)
                          ? CardPoints.first[i]
                          : dbClosedColumns.containsKey(i)
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

    if (isBoxColorFirstClosedByMe(BoxColors.greenBox)) {
      points += manualClosedColors.contains(BoxColors.greenBox) ? 3 : 5;
    }
    if (isBoxColorFirstClosedByMe(BoxColors.yellowBox)) {
      points += manualClosedColors.contains(BoxColors.yellowBox) ? 3 : 5;
    }
    if (isBoxColorFirstClosedByMe(BoxColors.blueBox)) {
      points += manualClosedColors.contains(BoxColors.blueBox) ? 3 : 5;
    }
    if (isBoxColorFirstClosedByMe(BoxColors.pinkBox)) {
      points += manualClosedColors.contains(BoxColors.pinkBox) ? 3 : 5;
    }
    if (isBoxColorFirstClosedByMe(BoxColors.orangeBox)) {
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

  bool isBoxColorFirstClosedByMe(BoxColor color) {
    return isBoxColorClosedByMe(color) &&
        (!dbClosedColors.containsKey(color.textValue) ||
            (dbClosedColors.containsKey(color.textValue) &&
                dbClosedColors[color.textValue] == widget.playerName));
  }

  bool isBoxColorClosedByMe(BoxColor color) {
    return card.every((row) => row
        .where((element) => element.color == color)
        .every((element) => element.checked));
  }

  bool checkIfGameIsFinished() {
    if (singlePlayerMode) {
      return manualClosedColumns.length == 15;
    }

    var closedCount = 0;
    if (isBoxColorFirstClosedByMe(BoxColors.greenBox)) closedCount++;
    if (isBoxColorFirstClosedByMe(BoxColors.yellowBox)) closedCount++;
    if (isBoxColorFirstClosedByMe(BoxColors.blueBox)) closedCount++;
    if (isBoxColorFirstClosedByMe(BoxColors.pinkBox)) closedCount++;
    if (isBoxColorFirstClosedByMe(BoxColors.orangeBox)) closedCount++;

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
