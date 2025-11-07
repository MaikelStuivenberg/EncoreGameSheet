import 'package:encore_gamesheet/constants/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  int gamesPlayed = 0;
  int singlePlayerGamesPlayed = 0; // Add this variable
  int multiplayerGamesPlayed = 0; // Add this variable
  Set<int> levelsPlayed = {}; // Add this variable
  int gamesWon = 0;
  int winStreak = 0;

  @override
  void initState() {
    super.initState();
    loadSinglePlayerGamesPlayed(); // Load the count of single player games played
    loadMultiplayerGamesPlayed(); // Load the count of multiplayer games played
    loadLevelsPlayed(); // Load the levels played
    loadGamesWon();
    loadWinStreak();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView(
        children: [
          buildAchievementTile(
            'Solo Adventurer',
            'Play a single player game',
            Icons.person,
            singlePlayerGamesPlayed >= 1,
          ),
          buildAchievementTile(
            'Team Player',
            'Play a multiplayer game',
            Icons.group,
            multiplayerGamesPlayed >= 1,
          ),
          buildAchievementTile(
            'First Steps',
            'Play the game 5 times in total',
            Icons.directions_walk,
            (singlePlayerGamesPlayed + multiplayerGamesPlayed) >= 5,
          ),
          buildAchievementTile(
            'Dedicated Player',
            'Play the game 25 times in total',
            Icons.star,
            (singlePlayerGamesPlayed + multiplayerGamesPlayed) >= 25,
          ),
          buildAchievementTile(
            'Seasoned Gamer',
            'Play the game 100 times in total',
            Icons.gamepad, // Changed icon
            (singlePlayerGamesPlayed + multiplayerGamesPlayed) >= 100,
          ),
          buildAchievementTile(
            'Marathon Gamer',
            'Play the game 500 times in total',
            Icons.directions_run,
            (singlePlayerGamesPlayed + multiplayerGamesPlayed) >= 500,
          ),
          buildAchievementTile(
            'Explorer',
            'Play all 7 different levels',
            Icons.explore,
            levelsPlayed.length == 7,
          ),
          buildAchievementTile(
            'First Victory',
            'Win your first game',
            Icons.emoji_events,
            gamesWon >= 1,
          ),
          buildAchievementTile(
            'Winning Streak',
            'Win 10 games in a row',
            Icons.whatshot,
            winStreak >= 10,
          ),
          buildAchievementTile(
            'Unstoppable',
            'Win 100 games in a row',
            Icons.flash_on,
            winStreak >= 100,
          ),
        ],
      ),
    );
  }

  Widget buildAchievementTile(
      String title, String subtitle, IconData icon, bool achieved) {
    return Container(
      color: achieved ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: achieved ? Colors.blueAccent : Colors.grey),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
            achieved ? const Icon(Icons.check, color: Colors.green) : null,
      ),
    );
  }
}
