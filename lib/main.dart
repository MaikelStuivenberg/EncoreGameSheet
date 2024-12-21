import 'package:encore_gamesheet/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();

  runApp(const EncoreGameSheet());
}

class EncoreGameSheet extends StatelessWidget {
  const EncoreGameSheet({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    WakelockPlus.enable();

    return const MaterialApp(
      title: 'Encore Game Sheet',
      home: HomePage(),
    );
  }
}
