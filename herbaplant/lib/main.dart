import 'package:flutter/material.dart';
import 'package:herbaplant/frontend/Auth/UserSignin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontend/user/Screen/main_navigation.dart';
import 'splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'frontend/Auth/Forgotpass.dart';
import 'frontend/Auth/Resetpass.dart'; 
import 'frontend/Auth/Checkemail.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initDeepLink();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/home', // Always start at Home
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const UserSignin()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) {
            final token = state.uri.queryParameters['token'] ?? '';
            return ResetPasswordScreen(token: token);
          },
        ),
        GoRoute(path: '/check-email', builder: (context, state) => const CheckEmailScreen()),
        GoRoute(path: '/home', builder: (context, state) => const MainNavigation()), // Home screen as default
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
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
    );
  }
}

// Initialize Deep Linking
StreamSubscription<Uri?>? _sub;

void _initDeepLink() async {
  try {
    final appLinks = AppLinks();

    Uri? initialUri = await appLinks.getInitialAppLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _sub = appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null) {
        _handleDeepLink(link);
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
    if (token != null && navigatorKey.currentContext != null) {
      GoRouter.of(navigatorKey.currentContext!).go('/reset-password?token=$token');
    }
  } else if (uri.path == "/verification-success") {
    _showVerificationDialog("Email Verified!", "Your email has been successfully verified.");
  } else if (uri.path == "/verification-failed") {
    _showVerificationDialog("Verification Failed", "The verification link is invalid or expired.");
  } else if (uri.path == "/verification-expired") {
    _showVerificationDialog("⚠️ Verification Expired", "The verification link has expired. Please try again.");
  }
}

// Function to show verification result
void _showVerificationDialog(String title, String message) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
