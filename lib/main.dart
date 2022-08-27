import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'pages/game_page.dart';

void main() {
  runApp(EncoreGameSheet());
}

class EncoreGameSheet extends StatelessWidget {
    final _key = GlobalKey();

  EncoreGameSheet({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    Wakelock.enable();

    return MaterialApp(
      title: 'Encore Game Sheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(key: _key),
    );
  }
}
