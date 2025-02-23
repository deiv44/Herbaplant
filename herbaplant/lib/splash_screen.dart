import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize Lottie animation controller
    _controller = AnimationController(vsync: this);

    // Play Lottie animation and navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), _navigateToNextScreen);
  }

  /// **Navigation Logic**
  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLogin = prefs.getBool("first_login") ?? true;
    String? token = prefs.getString("token");

    if (token != null && isFirstLogin) {
      await prefs.setBool("first_login", false);
      if (mounted) context.go('/onboarding');
    } else if (token != null) {
      if (mounted) context.go('/home');
    } else {
      if (mounted) context.go('/login');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand, // Ensures full-screen layout
        children: [
          // Full-Screen Lottie Background
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller,
              fit: BoxFit.cover, // Covers the entire screen
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
            ),
          ),

          // Centered Logo
          Center(
            child: Image.asset(
              'assets/image/logonobg.png',
              width: 200, // Adjust size as needed
            ),
          ),
        ],
      ),
    );
  }

  // Custom Left Slide Transition
  PageRouteBuilder _createSlideTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 3000), // Slide duration
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); 
        const end = Offset.zero; 
        const curve = Curves.easeInOut; 

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
