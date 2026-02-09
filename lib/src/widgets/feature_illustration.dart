import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcq_grader/src/widgets/glass_card.dart';

class FeatureIllustration extends StatelessWidget {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String title;

  const FeatureIllustration({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(0.4),
                  secondaryColor.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(duration: 2.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),

          // Glass Card Container
          GlassCard(
            width: 180,
            height: 180,
            borderRadius: 30,
            child: Center(
              child: Icon(
                icon,
                size: 80,
                color: Colors.white,
              ).animate()
               .shimmer(delay: 1.seconds, duration: 2.seconds, color: Colors.white.withOpacity(0.5)),
            ),
          ).animate()
           .slideY(begin: 0.1, end: -0.1, duration: 3.seconds, curve: Curves.easeInOut)
           .then()
           .slideY(begin: -0.1, end: 0.1, duration: 3.seconds, curve: Curves.easeInOut), // Float effect

          // Floating Particles (Decorations)
          Positioned(
            top: 40,
            right: 40,
            child: _buildParticle(secondaryColor, 15),
          ),
          Positioned(
            bottom: 60,
            left: 50,
            child: _buildParticle(primaryColor, 10),
          ),
          Positioned(
            top: 80,
            left: 40,
            child: _buildParticle(Colors.white, 8),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .fade(duration: 1500.ms, begin: 0.4, end: 1.0)
     .scale(duration: 1500.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2));
  }
}
