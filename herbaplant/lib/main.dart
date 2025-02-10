import 'package:flutter/material.dart';
import 'package:herbaplant/frontend/Auth/UserSignin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontend/user/Screen/main_navigation.dart';
import 'frontend/user/Screen/onboarding.dart';
import 'splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'frontend/Auth/Forgotpass.dart';
import 'frontend/Auth/Resetpass.dart'; 
import 'frontend/Auth/Checkemail.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>(); 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initDeepLink();
  final prefs = await SharedPreferences.getInstance();

  bool hasSeenOnboarding = prefs.getBool("onboarding_seen") ?? false;
  String? token = prefs.getString("token");

  runApp(MyApp(token: token, hasSeenOnboarding: hasSeenOnboarding));
}

// Initialize Deep Linking
StreamSubscription<String?>? _sub;

void _initDeepLink() async {
  try {
    Uri? initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _sub = linkStream.listen((String? link) {
      if (link != null) {
        Uri uri = Uri.parse(link); 
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint("Deep link error: $err");
    });
  } catch (e) {
    debugPrint("Deep link initialization failed: $e");
  }
}

void disposeDeepLinkListener() {
  _sub?.cancel();
}

// Deep Link Navigation
void _handleDeepLink(Uri uri) {
  if (uri.path == "/reset-password") {
    String? token = uri.queryParameters['token'];
    if (token != null && _navigatorKey.currentContext != null) {
      GoRouter.of(_navigatorKey.currentContext!).go('/reset-password?token=$token'); 
    }
  }
}

class MyApp extends StatelessWidget {
  final String? token;
  final bool hasSeenOnboarding;
  
  const MyApp({super.key, required this.token, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Herbal App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',  
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      routerConfig: _router,
    );
  }
}

// GoRouter Configuration
final GoRouter _router = GoRouter(
  navigatorKey: _navigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const UserSignin(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        return ResetPasswordScreen(token: token);
      },
    ),
    GoRoute(
      path: '/check-email',
      builder: (context, state) => const CheckEmailScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(),
    ),
  ],
);
