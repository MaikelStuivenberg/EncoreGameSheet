import 'package:encore_gamesheet/pages/settings_page.dart';
import 'package:encore_gamesheet/shared/widgets/game_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_page.dart'; // Import the game page
import 'achievements_page.dart'; // Import the achievements page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedLevel = 1;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SettingsPage(showNewGameButton: false),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Hey!',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Choose a sheet to start',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Carousel(
                  onImageTap: (level) {
                    setState(() {
                      selectedLevel = level;
                    });
                  },
                  onPageChanged: (level) {
                    setState(() {
                      selectedLevel = level;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GameButton.secondary(
                      'Single Player',
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(
                                level: selectedLevel, singlePlayer: true),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GameButton.primary(
                      'Multiplayer',
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(
                                level: selectedLevel, singlePlayer: false),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Carousel extends StatelessWidget {
  final List<String> images = [
    'assets/images/lvl1.jpg',
    'assets/images/lvl2.jpg',
    'assets/images/lvl3.jpg',
    'assets/images/lvl4.jpg',
    'assets/images/lvl5.jpg',
    'assets/images/lvl6.jpg',
    'assets/images/lvl7.jpg',
  ];

  final Function(int) onImageTap;
  final Function(int) onPageChanged;

  Carousel({super.key, required this.onImageTap, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        itemCount: images.length,
        onPageChanged: (index) {
          onPageChanged(index + 1);
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onImageTap(index + 1);
            },
            child: Hero(
              tag: images[index],
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 30, 30, 30),
                      image: DecorationImage(
                        image: AssetImage(images[index]),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    child: Text(
                      ' Level ${index + 1} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
