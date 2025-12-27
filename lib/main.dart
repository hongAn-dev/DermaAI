import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/appearance_model.dart';
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

  // 3. Chạy UI
  developer.log("📺 --- ĐANG MỞ GIAO DIỆN (RUN APP) ---");

  // Khởi tạo AppearanceModel trước khi runApp để load cài đặt
  final appearanceModel = AppearanceModel();
  await appearanceModel.load();

  runApp(ChangeNotifierProvider.value(value: appearanceModel, child: MyApp()));
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: accent, brightness: Brightness.light),
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.manropeTextTheme(),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: accent, brightness: Brightness.dark),
        useMaterial3: false,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.manropeTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
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
