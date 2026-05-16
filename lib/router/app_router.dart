import 'package:go_router/go_router.dart';

import '../auth_service.dart';
import '../screens/authentication/forgot_password_screen.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/register_screen.dart';
import '../screens/home_screen.dart';

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
  ],
  redirect: (context, state) {
    final isSignedIn = authService.value.currentUser != null;
    final location = state.matchedLocation;
    final isAuthRoute = location == '/login' ||
        location == '/register' ||
        location == '/forgot-password';

    if (isSignedIn && isAuthRoute) return '/home';
    if (!isSignedIn && location == '/home') return '/login';
    return null;
  },
);
