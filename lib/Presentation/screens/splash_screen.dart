import 'package:flutter/material.dart';
import '../../imports.dart';
import '../onBoarading/onboarding_screen.dart';
import 'screen_layout.dart';
import 'package:serat/Presentation/Widgets/Shared/islamic_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.9),
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(opacity: _fadeAnimation.value, child: child),
                  );
                },
                child: const Image(
                  image: AssetImage('assets/logo.png'),
                  height: 200.0,
                  width: 200.0,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(opacity: _fadeAnimation.value, child: child);
                },
                child: const Text(
                  "serat - تَطْمَئِن",
                  style: TextStyle(
                    fontSize: 27,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DIN',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(opacity: _fadeAnimation.value, child: child);
                },
                child: const IslamicLoadingIndicator(
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
