import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/modern_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/feature_illustration.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Welcome",
      "description": "The ultimate MCQ grading solution for modern educators.",
      "image": const Center(child: AppLogo(size: 180)),
    },
    {
      "title": "Smart Scanning",
      "description": "Instantly grade multiple choice questions using your camera with high precision.",
      "image": const FeatureIllustration(
        icon: Icons.document_scanner_rounded,
        primaryColor: Colors.blueAccent,
        secondaryColor: Colors.cyanAccent, 
        title: "Scan",
      ),
    },
    {
      "title": "AI Powered",
      "description": "Advanced algorithms ensure accurate results even with imperfect lighting.",
      "image": const FeatureIllustration(
        icon: Icons.psychology_rounded,
        primaryColor: Colors.purpleAccent,
        secondaryColor: Colors.deepPurple,
        title: "AI",
      ),
    },
    {
      "title": "Detailed Analytics",
      "description": "Get instant insights into student performance and identify areas for improvement.",
      "image": const FeatureIllustration(
        icon: Icons.analytics_rounded,
        primaryColor: Colors.orangeAccent,
        secondaryColor: Colors.redAccent,
        title: "Stats",
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // App Logo on first page only, or maybe small at top?
                        // Let's put the illustration here
                        Expanded(child: page['image'] as Widget),
                        
                        const SizedBox(height: 40),
                        
                        Text(
                          page['title'],
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: 0.3),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          page['description'],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.blueAccent : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ModernButton(
                    label: _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                    icon: _currentPage == _pages.length - 1 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: 500.ms, 
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => const HomeScreen())
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
