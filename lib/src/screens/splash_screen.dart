import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';
import '../widgets/app_logo.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Navigate to onboarding after animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Animated circles in background
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(duration: 3.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
            ),
            
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(duration: 4.seconds, begin: const Offset(1.0, 1.0), end: const Offset(1.3, 1.3)),
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo with shimmer
                          const AppLogo(size: 150, animated: true),
                          
                          const SizedBox(height: 40),
                          
                          // App Name
                          Text(
                            "MCQ Grader Pro",
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ).animate()
                           .fadeIn(delay: 600.ms, duration: 800.ms)
                           .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 800.ms),
                          
                          const SizedBox(height: 12),
                          
                          // Tagline
                          Text(
                            "Smart Grading, Instant Results",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ).animate()
                           .fadeIn(delay: 1000.ms, duration: 800.ms)
                           .slideY(begin: 0.3, end: 0, delay: 1000.ms, duration: 800.ms),
                          
                          const SizedBox(height: 60),
                          
                          // Loading indicator
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .fadeIn(delay: 1400.ms, duration: 600.ms)
                           .scale(delay: 1400.ms, duration: 600.ms),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Version text at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                "Version 1.0.0",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ).animate()
               .fadeIn(delay: 1800.ms, duration: 800.ms),
            ),
          ],
        ),
      ),
    );
  }
}
