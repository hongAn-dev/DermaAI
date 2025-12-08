
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/main_layout.dart';
import 'package:myapp/register_screen.dart';
import 'package:myapp/scan_screen.dart';
import 'package:myapp/startup_screen.dart';

// Navigator key for the root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Navigator key for the shell navigator
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Routes outside of the shell
    GoRoute(
      path: '/',
      builder: (context, state) => const StartupScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ShellRoute for tabs
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/scan',
          builder: (context, state) => const ScanScreen(),
        ),
      ],
    ),
  ],
);
