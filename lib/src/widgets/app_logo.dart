import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 100,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Deep Purple to Blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withOpacity(0.4),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background shine
          Positioned(
            top: -size * 0.1,
            right: -size * 0.1,
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          // Main Icon
          Icon(
            Icons.assignment_turned_in_rounded,
            size: size * 0.6,
            color: Colors.white,
          ),
        ],
      ),
    );

    if (animated) {
      return logo.animate()
          .scale(duration: 600.ms, curve: Curves.easeOutBack)
          .shimmer(delay: 400.ms, duration: 1200.ms, color: Colors.white.withOpacity(0.2));
    }
    return logo;
  }
}
