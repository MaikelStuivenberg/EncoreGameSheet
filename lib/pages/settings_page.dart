import 'package:encore_game_sheet/constants/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'choose_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showCurrentPoints = true;
  bool _useDarkMode = true;
  bool _useHighscore = true;
  bool _useSounds = false;

  @override
  void initState() {
    super.initState();
    loadCurrentSettings();
  }

  void loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCurrentPoints = prefs.getBool(Settings.showCurrentPoints) ?? true;
      _useDarkMode = prefs.getBool(Settings.darkMode) ?? true;
      _useHighscore = prefs.getBool(Settings.highscore) ?? true;
      _useSounds = prefs.getBool(Settings.sounds) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(25),
        child: Column(
          children: [
            // SHOW CURRENT POINTS
            SwitchListTile(
                value: _showCurrentPoints,
                title: const Text("Show current points"),
                secondary: const Icon(Icons.score_outlined),
                onChanged: (val) async {
                  setState(() {
                    _showCurrentPoints = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(Settings.showCurrentPoints, val);
                }),

            // DARK MODE
            SwitchListTile(
                value: _useDarkMode,
                title: const Text("Dark mode"),
                secondary: const Icon(Icons.nightlight_round),
                onChanged: (val) async {
                  setState(() {
                    _useDarkMode = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(Settings.darkMode, val);
                }),

            // HIGHSCORES
            // SwitchListTile(
            //     value: _useHighscore,
            //     title: Text("Show/Save highscore"),
            //     secondary: Icon(Icons.emoji_events),
            //     onChanged: (val) async {
            //       setState(() {
            //         _useHighscore = val;
            //       });

            //       final prefs = await SharedPreferences.getInstance();
            //       prefs.setBool(Settings.highscore, val);
            //     }),

            // SOUNDS
            SwitchListTile(
                value: _useSounds,
                title: const Text("Use sounds"),
                secondary: const Icon(Icons.speaker),
                onChanged: (val) async {
                  setState(() {
                    _useSounds = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(Settings.sounds, val);
                }),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, ['resume']);
                    },
                    child: const Text('Back'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChooseCardPage(key: GlobalKey())),
                      ).then((value) => {
                            if (value![0] != "Cancel")
                              Navigator.pop(context, value)
                          });
                    },
                    child: const Text('New Game'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
