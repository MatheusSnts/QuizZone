import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz_zone/firebase_options.dart';
import 'package:quiz_zone/services/notification_service.dart';

// Importa a configuração de rotas da aplicação.
import 'router/app_router.dart';

// Importa a configuração do tema global da aplicação.
import 'theme/app_theme.dart';

/// Ponto de entrada da aplicação.
/// A função main() é a primeira a ser executada quando a app inicia.
/// Inicializa o Firebase antes de arrancar a interface.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa as notificações
  NotificationService().initNotification();

 // Inicializa o Firebase antes de qualquer ecrã usar Auth ou Firestore.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const QuizZoneApp());
}

/// Widget principal da aplicação.
/// Responsável por configurar o MaterialApp e definir
/// as configurações globais da app.
class QuizZoneApp extends StatelessWidget {
  const QuizZoneApp({super.key});

  @override
  Widget build(BuildContext context) {

     // MaterialApp.router usa o GoRouter definido em app_router.dart.

    // MaterialApp.router é o widget raiz da aplicação.
    // Contém configurações globais como tema e navegação
    // baseada em rotas (go_router).

    return MaterialApp.router(
      // Nome da aplicação.
      title: 'QuizZone',
      // Remove a faixa "DEBUG" apresentada por defeito.
      debugShowCheckedModeBanner: false,
      // Aplica o tema personalizado definido em AppTheme.
      theme: AppTheme.build(),
      // Define a configuração de rotas da aplicação.
      routerConfig: appRouter,
    );
  }
}
