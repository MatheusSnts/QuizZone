import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_zone/firebase_options.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  runApp(const QuizZoneApp());
}

class QuizZoneApp extends StatelessWidget {
  const QuizZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizZone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const HomeScreen(),
    );
  }
}
