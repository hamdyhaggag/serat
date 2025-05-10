import 'package:flutter/material.dart';
import '../../imports.dart';
import '../onBoarading/onboarding_screen.dart';
import 'screen_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    );

    _animationController.forward();

    Timer(const Duration(seconds: 2), () {
      if (isEnterBefore) {
        navigateAndFinish(context, const ScreenLayout());
      } else {
        navigateAndFinish(context, const OnboardingScreen());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(opacity: _animation.value, child: child);
                },
                child: const Image(
                  image: AssetImage('assets/logo.png'),
                  height: 240.0,
                  width: 240.0,
                ),
              ),
              const SizedBox(height: 40),
              // App Name with Custom Font

              // AnimatedBuilder(
              //   animation: _animation,
              //   builder: (context, child) {
              //     return Opacity(
              //       opacity: _animation.value,
              //       child: child,
              //     );
              //   },
              //   child: const Text(
              //     "serat - تَطْمَئِن",
              //     style: TextStyle(
              //       fontSize: 27,
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //       fontFamily: 'DIN',
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
