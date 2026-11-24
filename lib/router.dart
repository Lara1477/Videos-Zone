import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'screens/feed_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

/// Nombres de las rutas (evita escribir los paths a mano por toda la app).
abstract class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const feed = '/feed';
}

/// Avisa a go_router cada vez que la sesión cambia (login, registro, logout)
/// para que vuelva a ejecutar `redirect`.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.feed,
  refreshListenable: _AuthRefresh(FirebaseAuth.instance.userChanges()),
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loc = state.matchedLocation;
    final inAuthPages = loc == AppRoutes.login || loc == AppRoutes.register;

    if (!loggedIn && !inAuthPages) return AppRoutes.login; // sin sesión -> login
    if (loggedIn && inAuthPages) return AppRoutes.feed; // con sesión -> feed
    return null; // no redirigir
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.feed,
      builder: (context, state) => const FeedScreen(),
    ),
  ],
);
