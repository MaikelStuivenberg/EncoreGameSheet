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
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
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

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 175,
                      child: GameButton.primary(
                        'Back',
                        () {
                          Navigator.pop(context, ['resume']);
                        },
                      ),
                    ),
                  ),
                  if (widget.showNewGameButton) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
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
                    ),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
