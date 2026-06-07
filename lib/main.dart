import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_zone/firebase_options.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 // Inicializa o Firebase antes de qualquer ecrã usar Auth ou Firestore.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const QuizZoneApp());
}

class QuizZoneApp extends StatelessWidget {
  const QuizZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
     // MaterialApp.router usa o GoRouter definido em app_router.dart.
    return MaterialApp.router(
      title: 'QuizZone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: appRouter,
    );
  }
}
