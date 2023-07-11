import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firedart/firedart.dart';
import 'package:textsharer/Components/backgroundwrapper.dart';
import 'package:textsharer/Pages/devices.dart';
import 'package:textsharer/Pages/history.dart';
import 'package:textsharer/Pages/home.dart';
import 'package:textsharer/Pages/pair_device.dart';
import 'package:textsharer/Pages/register.dart';

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  String projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
  FirebaseAuth.initialize(apiKey, VolatileStore());
  Firestore.initialize(projectId);
  _enablePlatformOverrideForDesktop();
  runApp(const MainApp());
}

final fireauth = FirebaseAuth.instance;
final firestore = Firestore.instance;
Map<String, dynamic> deviceInfo = {
  'deviceId': '',
  'username': '',
  'deviceName': '',
  'deviceIcon': '',
};

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TextSharer',
      initialRoute: '/register',
      routes: {
        '/register': (context) => const BackgroundWrapper(child: Register()),
        '/home': (context) => const BackgroundWrapper(child: HomePage()),
        '/devices': (context) => const BackgroundWrapper(child: Devices()),
        '/pair-device': (context) =>
            const BackgroundWrapper(child: PairDevice()),
        '/history': (context) => const BackgroundWrapper(child: History())
      },
    );
  }
}
