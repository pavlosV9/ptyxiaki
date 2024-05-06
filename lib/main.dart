import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ptyxiaki/location/dynamicMap.dart';
import 'package:ptyxiaki/screens/ItemScreen.dart';
import 'package:ptyxiaki/screens/SettingsPage.dart';
import 'package:ptyxiaki/screens/mainscreen.dart';
import 'package:ptyxiaki/screens/mapScreen.dart';
import 'package:ptyxiaki/screens/welcomeScreen.dart';
import 'package:ptyxiaki/clas/Item.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin services are initialized
  SystemChrome.setPreferredOrientations([ // Allow both landscape and portrait orientations
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemBrain(),
      child: MaterialApp(
        home: Welcomescreen(),
      ),
    );
  }
}
