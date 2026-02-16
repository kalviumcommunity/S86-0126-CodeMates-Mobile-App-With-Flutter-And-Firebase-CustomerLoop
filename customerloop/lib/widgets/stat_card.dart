import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final Color iconBgColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _points = List.generate(8, (_) => math.Random().nextDouble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            children: [
              // Interactive SVG Sparkline Background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SparklinePainter(
                        points: _points,
                        progress: _controller.value,
                        color: widget.gradientColors[0].withOpacity(0.15),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Top Aligned
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: widget.iconBgColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: widget.iconColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start, // Top Aligned
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: widget.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              widget.value,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> points;
  final double progress;
  final Color color;

  SparklinePainter({
    required this.points,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw a soft glow behind the line
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..strokeCap = StrokeCap.round;

    final mainPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      // Add a 'Live Data' pulse, shifted to the bottom half
      final nodeAnimation = math.sin(progress * math.pi * 2 + (i * 0.8)) * 8;
      final y = size.height * (0.6 + (points[i] * 0.3)) + nodeAnimation; // Shifted graph down

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNodeAnimation = math.sin(progress * math.pi * 2 + ((i - 1) * 0.8)) * 8;
        final prevY = size.height * (0.6 + (points[i - 1] * 0.3)) + prevNodeAnimation;

        path.cubicTo(
          prevX + stepX / 2, prevY,
          x - stepX / 2, y,
          x, y,
        );
      }
    }

    // Draw the glow and then the main vibrant line
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, mainPaint);

    // 2. Draw Data Node Markers (These now move with the data stream)
    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final nodeAnimation = math.sin(progress * math.pi * 2 + (i * 0.8)) * 8;
      final y = size.height * (0.6 + (points[i] * 0.3)) + nodeAnimation;
      
      canvas.drawCircle(
        Offset(x, y), 
        3.5, 
        Paint()..color = color.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      );
      canvas.drawCircle(
        Offset(x, y), 
        1.8, 
        Paint()..color = color
      );
    }

    // 3. Add an interactive "Data Scanner" pulse point
    final metrics = path.computeMetrics();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final pos = metric.getTangentForOffset(metric.length * progress)?.position;
      
      if (pos != null) {
        // Draw pulse glow
        canvas.drawCircle(
          pos, 
          10.0, 
          Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        );
        // Draw center scanner point
        canvas.drawCircle(
          pos, 
          4.0, 
          Paint()..color = Colors.white
        );
      }
    }

    // 4. Area Fill - Highlighted but balanced
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Secondary soft glow for the area
    final areaGlowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.15), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    canvas.drawPath(fillPath, areaGlowPaint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.7, 1.0],
        colors: [
          color.withOpacity(0.22), // Balanced highlight
          color.withOpacity(0.08), 
          Colors.transparent
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => true;
}
