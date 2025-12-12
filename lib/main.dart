
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'package:myapp/screens/scan/scan_screen.dart';
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

import 'firebase_options.dart';

void main() async {
  developer.log("--- Starting main() ---");
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    developer.log("--- Firebase not initialized, initializing now... ---");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseDatabase.instance.databaseURL = 'https://realtimefrb-27357-default-rtdb.asia-southeast1.firebasedatabase.app';
  } else {
    developer.log("--- Firebase already initialized, skipping initialization. ---");
  }

  developer.log("--- Running runApp() ---");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authStateChanges = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      refreshListenable: GoRouterRefreshStream(authStateChanges),
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(path: 'personal_information', builder: (context, state) => const PersonalInformationScreen()),
            GoRoute(path: 'appearance', builder: (context, state) => const AppearanceScreen()),
            GoRoute(path: 'subscription', builder: (context, state) => const SubscriptionManagementScreen()),
            GoRoute(path: 'change_password', builder: (context, state) => const ChangePasswordScreen()),
            GoRoute(path: 'terms_of_service', builder: (context, state) => const TermsOfServiceScreen()),
            GoRoute(path: 'privacy_policy', builder: (context, state) => const PrivacyPolicyScreen()),
          ],
        ),
        GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
        GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
        GoRoute(path: '/consult', builder: (context, state) => const ConsultScreen()),
        GoRoute(path: '/model_performance', builder: (context, state) => const ModelPerformanceScreen()),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = FirebaseAuth.instance.currentUser != null;
        final bool onAuthScreen = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!loggedIn && !onAuthScreen) {
          return '/login';
        }

        if (loggedIn && onAuthScreen) {
          return '/home';
        }

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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
