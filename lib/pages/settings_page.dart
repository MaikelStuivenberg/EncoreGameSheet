import 'package:encore_gamesheet/constants/settings.dart';
import 'package:encore_gamesheet/pages/home_page.dart';
import 'package:encore_gamesheet/shared/widgets/game_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final bool showNewGameButton;

  const SettingsPage({super.key, this.showNewGameButton = true});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showCurrentPoints = true;
  bool _useDarkMode = true;
  bool _useSounds = false;
  bool _useColorblind = false;

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
      _useSounds = prefs.getBool(Settings.sounds) ?? false;
      _useColorblind = prefs.getBool(Settings.colorblind) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SHOW CURRENT POINTS
                SwitchListTile(
                    value: _showCurrentPoints,
                    title: const Text("Show current points"),
                    secondary: const Icon(Icons.score_outlined),
                    subtitle: const Text(
                      'This option is only available for offline games.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
                    title: const Text("Dark game sheet"),
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

                // SOUNDS
                SwitchListTile(
                    value: _useColorblind,
                    title: const Text("Use colorblind mode"),
                    secondary: const Icon(Icons.color_lens),
                    onChanged: (val) async {
                      setState(() {
                        _useColorblind = val;
                      });

                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool(Settings.colorblind, val);
                    }),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 175,
                      child: GameButton.primary(
                        'Back',
                        () {
                          Navigator.pop(context, ['resume']);
                        },
                      ),
                    ),
                    if (widget.showNewGameButton) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 175,
                        child: GameButton.secondary(
                          'New Game',
                          () {
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
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
