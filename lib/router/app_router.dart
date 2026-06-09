import 'package:go_router/go_router.dart';

import '../screens/authentication/forgot_password_screen.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/register_screen.dart';
import '../models/game_mode.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../services/auth_service.dart';

/// Router principal da aplicação.
///
/// Centraliza as rotas e protege os ecrãs que só podem ser vistos
/// por utilizadores autenticados.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
          path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/daily',
      builder: (context, state) => const QuizScreen(isDailyChallenge: true),
    ),
    GoRoute(
      path: '/quiz/:categoryId',
      builder: (context, state) => QuizScreen(
        categoryId: int.parse(state.pathParameters['categoryId']!),
      ),
    ),
    GoRoute(
      path: '/play/:mode',
      builder: (context, state) {
        final mode = GameMode.fromSlug(state.pathParameters['mode']!);
        if (mode == null) return const HomeScreen();
        return QuizScreen(mode: mode);
      },
    ),
  ],
  redirect: (context, state) {
    final isSignedIn = authService.value.currentUser != null;
    final location = state.matchedLocation;
    
    // Rotas de autenticação ficam disponíveis apenas antes do login.
    final isAuthRoute = location == '/login' ||
        location == '/register' ||
        location == '/forgot-password';
  
    // Rotas protegidas exigem uma sessão Firebase ativa.
    final isProtectedRoute = location == '/home' ||
        location == '/profile' ||
        location == '/daily' ||
        location.startsWith('/quiz') ||
        location.startsWith('/play');

    if (isSignedIn && isAuthRoute) return '/home';
    if (!isSignedIn && isProtectedRoute) return '/login';
    return null;
  },
);
