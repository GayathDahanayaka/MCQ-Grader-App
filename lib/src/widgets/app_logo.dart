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
          colors: [
            Color(0xFF4F46E5), // Indigo 600
            Color(0xFF7C3AED), // Violet 600
            Color(0xFF9333EA), // Purple 600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
            spreadRadius: -size * 0.05,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background circles
            Positioned(
              top: -size * 0.3,
              left: -size * 0.3,
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Floating "Smart Document" (Scanner)
            Container(
              width: size * 0.52,
              height: size * 0.62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(size * 0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                   // Document Lines
                  Padding(
                    padding: EdgeInsets.all(size * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: size * 0.25, height: size * 0.02, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
                        SizedBox(height: size * 0.04),
                        Container(width: size * 0.35, height: size * 0.02, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                        SizedBox(height: size * 0.04),
                        Container(width: size * 0.3, height: size * 0.02, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  ),

                  // "Scan Line" - The horizontal glowing line
                  Positioned(
                    top: size * 0.3,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Refined Checkmark Badge (Status)
            Positioned(
              bottom: size * 0.12,
              right: size * 0.12,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: size * 0.22,
                  color: Colors.white,
                  weight: 800,
                ),
              ),
            ),
          ],
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
