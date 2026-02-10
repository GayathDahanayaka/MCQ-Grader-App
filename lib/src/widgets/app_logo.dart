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
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/icon/mcq-grading-logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );

    if (animated) {
      return logo
          .animate()
          .scale(duration: 700.ms, curve: Curves.easeOutBack)
          .shimmer(
            delay: 500.ms,
            duration: 1500.ms,
            color: Colors.white.withOpacity(0.3),
          );
    }
    return logo;
  }

  Widget _buildAnswerRow(double size, double bubbleSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnswerBubble(size, bubbleSize, false),
        SizedBox(width: size * 0.03),
        _buildAnswerBubble(size, bubbleSize, true), // Filled bubble
        SizedBox(width: size * 0.03),
        _buildAnswerBubble(size, bubbleSize, false),
        SizedBox(width: size * 0.03),
        _buildAnswerBubble(size, bubbleSize, false),
      ],
    );
  }

  Widget _buildAnswerBubble(double size, double bubbleSize, bool filled) {
    return Container(
      width: size * bubbleSize,
      height: size * bubbleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white.withOpacity(0.9) : Colors.transparent,
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: size * 0.008,
        ),
      ),
    );
  }
}
