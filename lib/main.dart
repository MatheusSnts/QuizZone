import 'package:flutter/material.dart';

// Importa o ecrã principal da aplicação.
import 'screens/home_screen.dart';

// Importa a configuração do tema global da aplicação.
import 'theme/app_theme.dart';

/// Ponto de entrada da aplicação.
/// A função main() é a primeira a ser executada quando a app inicia.
void main() {
  runApp(const QuizZoneApp());
}

/// Widget principal da aplicação.
/// Responsável por configurar o MaterialApp e definir
/// as configurações globais da app.
class QuizZoneApp extends StatelessWidget {
  const QuizZoneApp({super.key});

  @override
  Widget build(BuildContext context) {

    // MaterialApp é o widget raiz da aplicação.
    // Contém configurações globais como tema,
    // navegação e ecrã inicial.
    return MaterialApp(
        // Nome da aplicação.
      title: 'QuizZone',
       // Remove a faixa "DEBUG" apresentada por defeito.
      debugShowCheckedModeBanner: false,
        // Aplica o tema personalizado definido em AppTheme.
      theme: AppTheme.build(),
      // Define o primeiro ecrã apresentado ao utilizador.
      home: const HomeScreen(),
    );
  }
}
