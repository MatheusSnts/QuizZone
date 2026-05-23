import 'package:go_router/go_router.dart';

import '../screens/authentication/forgot_password_screen.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../services/auth_service.dart';

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
      path: '/quiz/:categoryId',
      builder: (context, state) => QuizScreen(
        categoryId: int.parse(state.pathParameters['categoryId']!),
      ),
    ),
  ],
  redirect: (context, state) {
    final isSignedIn = authService.value.currentUser != null;
    final location = state.matchedLocation;
    final isAuthRoute = location == '/login' ||
        location == '/register' ||
        location == '/forgot-password';
    final isProtectedRoute =
        location == '/home' || location.startsWith('/quiz');

    if (isSignedIn && isAuthRoute) return '/home';
    if (!isSignedIn && isProtectedRoute) return '/login';
    return null;
  },
);
