import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/appearance_model.dart';
import 'data/repositories/doctor_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/auth_repository.dart'; // Import AuthRepository
import 'view_models/consult_view_model.dart';
import 'view_models/chat_view_model.dart';
import 'view_models/auth_view_model.dart'; // Import AuthViewModel
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// --- File cấu hình Firebase (được tạo bởi flutterfire configure) ---
import 'firebase_options.dart';

// --- Import các màn hình ---
import 'package:myapp/screens/scan/scan_screen.dart';
import 'package:myapp/screens/consult/consult_screen.dart';
import 'package:myapp/screens/consult/conversations_screen.dart';
import 'package:myapp/screens/admin/user_management_screen.dart';
import 'package:myapp/screens/history/history_screen.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/authen/login_screen.dart';
import 'package:myapp/screens/scan/model_performance_screen.dart';
import 'package:myapp/screens/profile/profile_screen.dart';
import 'package:myapp/screens/authen/register_screen.dart';
import 'package:myapp/screens/profile/personal_information_screen.dart';
import 'package:myapp/screens/profile/appearance_screen.dart';
import 'package:myapp/screens/profile/subscription_management_screen.dart';
import 'package:myapp/screens/profile/change_password_screen.dart';
import 'package:myapp/screens/profile/terms_of_service_screen.dart';
import 'package:myapp/screens/profile/privacy_policy_screen.dart';

void main() async {
  // 1. Đảm bảo Binding được khởi tạo đầu tiên
  WidgetsFlutterBinding.ensureInitialized();
  developer.log("🚀 --- BẮT ĐẦU KHỞI TẠO ỨNG DỤNG ---");

  // 2. Khởi tạo Firebase an toàn
  try {
    // Chỉ khởi tạo nếu chưa có App nào (tránh lỗi khi hot reload)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        // QUAN TRỌNG: Không đặt thuộc tính 'name'.
        // Để nó tự động dùng tên mặc định là [DEFAULT]
        options: DefaultFirebaseOptions.currentPlatform,
      );
      developer.log("✅ Firebase đã kết nối thành công!");
    } else {
      developer.log("ℹ️ Firebase đã được khởi tạo trước đó.");
    }

    // Cấu hình Database URL (chỉ cần thiết nếu bạn dùng Realtime Database)
    try {
      FirebaseDatabase.instance.databaseURL =
          'https://realtimefrb-27357-default-rtdb.asia-southeast1.firebasedatabase.app';
    } catch (e) {
      developer.log("⚠️ Lỗi cấu hình Database URL (có thể bỏ qua): $e");
    }
  } catch (e) {
    // In lỗi nhưng vẫn để App chạy tiếp để hiện màn hình báo lỗi (nếu có)
    developer.log("❌ LỖI NGHIÊM TRỌNG KHI KẾT NỐI FIREBASE: $e");
  }

  // 3. Register Providers & Run App
  developer.log("📺 --- ĐANG MỞ GIAO DIỆN (RUN APP) ---");

  // Keep AppearanceModel
  final appearanceModel = AppearanceModel();
  await appearanceModel.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appearanceModel),
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<DoctorRepository>(create: (_) => DoctorRepository()),
        Provider<ChatRepository>(create: (_) => ChatRepository()),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ConsultViewModel(
            doctorRepository: context.read<DoctorRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatViewModel(
            chatRepository: context.read<ChatRepository>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Tạo instance GoRouter
  // Di chuyển logic router vào trong để code gọn gàng hơn
  late final GoRouter _router = GoRouter(
    // Lắng nghe sự thay đổi trạng thái đăng nhập để refresh lại route
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
              path: 'personal_information',
              builder: (context, state) => const PersonalInformationScreen()),
          GoRoute(
              path: 'appearance',
              builder: (context, state) => const AppearanceScreen()),
          GoRoute(
              path: 'subscription',
              builder: (context, state) =>
                  const SubscriptionManagementScreen()),
          GoRoute(
              path: 'change_password',
              builder: (context, state) => const ChangePasswordScreen()),
          GoRoute(
              path: 'terms_of_service',
              builder: (context, state) => const TermsOfServiceScreen()),
          GoRoute(
              path: 'privacy_policy',
              builder: (context, state) => const PrivacyPolicyScreen()),
        ],
      ),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
      GoRoute(
          path: '/history', builder: (context, state) => const HistoryScreen()),
      GoRoute(
          path: '/consult', builder: (context, state) => const ConsultScreen()),
      GoRoute(
          path: '/chats',
          builder: (context, state) => const ConversationsScreen()),
      GoRoute(
          path: '/admin',
          builder: (context, state) => const UserManagementScreen()),
      GoRoute(
          path: '/model_performance',
          builder: (context, state) => const ModelPerformanceScreen()),
    ],

    // Logic chuyển hướng người dùng (Redirect)
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final bool onAuthScreen = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // 1. Nếu chưa đăng nhập mà KHÔNG ở trang Login/Register -> Đá về Login
      if (!loggedIn && !onAuthScreen) {
        return '/login';
      }

      // 2. Nếu đã đăng nhập mà vẫn cố vào trang Login/Register -> Đá về Home
      if (loggedIn && onAuthScreen) {
        return '/home';
      }

      // Không cần chuyển hướng
      return null;
    },

    // Xử lý lỗi 404
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Lỗi: Không tìm thấy trang ${state.error}')),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appearance = Provider.of<AppearanceModel>(context);
    final accent = Color(appearance.accentColorValue);
    return MaterialApp.router(
      title: 'DermaAI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent, // User preference or Default Medical Blue
          brightness: Brightness.light,
          primary: accent,
          secondary: const Color(0xFF26A69A), // Teal accent for medical feel
          surface: const Color(0xFFFFFFFF),
          surfaceContainerLowest: const Color(0xFFF8F9FA), // Soft background
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme:
            GoogleFonts.manropeTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF212529),
          displayColor: const Color(0xFF212529),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8F9FA),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212529),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: accent.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle:
                GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.manropeTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle:
                GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
        brightness: Brightness.dark,
      ),
      themeMode: appearance.darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router, // Sử dụng router đã cấu hình ở trên
      debugShowCheckedModeBanner: false,

      // --- CƠ CHẾ BẮT LỖI MÀN HÌNH TRẮNG (Error Widget) ---
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      const Text("Đã xảy ra lỗi giao diện!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(errorDetails.exceptionAsString(),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          );
        };

        // Áp dụng text scale toàn app theo fontSize trong AppearanceModel
        final appearance = Provider.of<AppearanceModel>(context);
        final scale = appearance.fontScale;
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
    );
  }
}

// Class helper để convert Stream thành Listenable cho GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
