 import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isPlaying;
  final double height;
  final Color color;
  final double speedMultiplier;

  const WaveformVisualizer({
    super.key,
    required this.isPlaying,
    this.height = 80.0,
    this.color = AppTheme.primary,
    this.speedMultiplier = 1.0,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _baseHeights = [];
  final Random _random = Random();
  final int _barCount = 36;

  @override
  void initState() {
    super.initState();
    // Initialize random base heights for the visualizer bars
    for (int i = 0; i < _barCount; i++) {
      // Create a nice parabolic distribution (taller in the middle, shorter at the edges)
      double centerFactor = 1.0 - ((i - _barCount / 2).abs() / (_barCount / 2));
      _baseHeights.add(0.2 + 0.8 * centerFactor * (0.6 + 0.4 * _random.nextDouble()));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: WaveformPainter(
              heights: _baseHeights,
              animationValue: _controller.value,
              isPlaying: widget.isPlaying,
              color: widget.color,
              speedMultiplier: widget.speedMultiplier,
            ),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> heights;
  final double animationValue;
  final bool isPlaying;
  final Color color;
  final double speedMultiplier;

  WaveformPainter({
    required this.heights,
    required this.animationValue,
    required this.isPlaying,
    required this.color,
    required this.speedMultiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = size.width / (heights.length * 1.5);
    final double spacing = barWidth * 0.5;
    
    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth;

    // Glowing effect
    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth * 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < heights.length; i++) {
      final double x = i * (barWidth + spacing) + barWidth / 2;
      
      // Calculate dynamic scale factor based on sine wave and time
      double scale = heights[i];
      if (isPlaying) {
        final double phase = i * 0.25;
        scale *= (0.4 + 0.6 * sin(animationValue * 2 * pi * speedMultiplier + phase).abs());
      } else {
        // Subtle resting pulse
        scale *= 0.2;
      }
      
      final double barHeight = size.height * scale;
      final double yStart = (size.height - barHeight) / 2;
      final double yEnd = yStart + barHeight;

      // Draw glow
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), glowPaint);
      // Draw main bar
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.color != color ||
        oldDelegate.speedMultiplier != speedMultiplier;
  }
}
