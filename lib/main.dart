import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'package:myapp/screens/scan/scan_screen.dart';
import 'package:myapp/screens/scan/analysis_results_screen.dart';
import 'package:myapp/screens/consult/consult_screen.dart';
import 'package:myapp/screens/history/history_screen.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/authen/login_screen.dart';
import 'package:myapp/screens/scan/model_performance_screen.dart';
import 'package:myapp/screens/profile/profile_screen.dart';
import 'package:myapp/screens/authen/register_screen.dart';

// Profile Sub-Screens
import 'package:myapp/screens/profile/personal_information_screen.dart';
import 'package:myapp/screens/profile/appearance_screen.dart';
import 'package:myapp/screens/profile/subscription_management_screen.dart';
import 'package:myapp/screens/profile/change_password_screen.dart';
import 'package:myapp/screens/profile/terms_of_service_screen.dart';
import 'package:myapp/screens/profile/privacy_policy_screen.dart';

import 'screens/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This stream tells GoRouter when the user's auth state changes.
  final authStateChanges = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      // The router listens to the auth state changes.
      refreshListenable: GoRouterRefreshStream(authStateChanges),
      initialLocation:
          '/home', // Start at home, redirect logic will handle auth
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // All routes below are protected (require login)
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'personal_information',
              builder: (context, state) => const PersonalInformationScreen(),
            ),
            GoRoute(
              path: 'appearance',
              builder: (context, state) => const AppearanceScreen(),
            ),
            GoRoute(
              path: 'subscription',
              builder: (context, state) => const SubscriptionManagementScreen(),
            ),
            GoRoute(
              path: 'change_password',
              builder: (context, state) => const ChangePasswordScreen(),
            ),
            GoRoute(
              path: 'terms_of_service',
              builder: (context, state) => const TermsOfServiceScreen(),
            ),
            GoRoute(
              path: 'privacy_policy',
              builder: (context, state) => const PrivacyPolicyScreen(),
            ),
          ],
        ),
        GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/consult',
          builder: (context, state) => const ConsultScreen(),
        ),
        GoRoute(
          path: '/analysis_results',
          builder: (context, state) {
            final AnalysisScreenNavData? navData =
                state.extra as AnalysisScreenNavData?;
            if (navData != null) {
              return AnalysisResultsScreen(
                analysisResult: navData.analysisResult,
                imageBytes: navData.imageBytes,
                imageFile: null,
              );
            } else {
              return const ScanScreen(); // Fallback
            }
          },
        ),
        GoRoute(
          path: '/model_performance',
          builder: (context, state) => const ModelPerformanceScreen(),
        ),
      ],
      // The core of the solution: the redirect logic
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = FirebaseAuth.instance.currentUser != null;
        final bool onAuthScreen =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        // If the user is NOT logged in and trying to access a protected page...
        if (!loggedIn && !onAuthScreen) {
          // ...redirect them to the login page.
          return '/login';
        }

        // If the user IS logged in and trying to access a login/register page...
        if (loggedIn && onAuthScreen) {
          // ...redirect them to the home page.
          return '/home';
        }

        // In all other cases, no redirect is needed.
        return null;
      },
    );

    return MaterialApp.router(
      title: 'DermAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.manropeTextTheme(),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Helper class to make GoRouter listen to a Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
