import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/scan/scan_screen.dart';
import 'package:myapp/screens/scan/analysis_results_screen.dart';
import 'package:myapp/screens/consult/consult_screen.dart';
import 'package:myapp/screens/history/history_screen.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/authen/login_screen.dart';
import 'package:myapp/screens/scan/model_performance_screen.dart';
import 'package:myapp/screens/profile/profile_screen.dart';
import 'package:myapp/screens/authen/register_screen.dart';
import 'package:myapp/screens/startup_screen.dart';

// Import the new profile screens
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

  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const StartupScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
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
          // Extract the AnalysisScreenNavData object from the 'extra' field.
          final AnalysisScreenNavData? navData =
              state.extra as AnalysisScreenNavData?;

          // If the data is valid, show the results screen.
          if (navData != null) {
            return AnalysisResultsScreen(
              analysisResult: navData.analysisResult,
              imageFile: navData.imageFile,
            );
          } else {
            // If data is missing (e.g., user navigates directly via URL),
            // redirect to the scan screen as a fallback.
            return const ScanScreen();
          }
        },
      ),
      GoRoute(
        path: '/model_performance',
        builder: (context, state) => const ModelPerformanceScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DermAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.manropeTextTheme(),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
