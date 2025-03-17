import 'package:flutter/material.dart';
import 'dart:math' as math;

class Round3DView extends StatefulWidget {
  final double progress;
  final Color color;
  final String label;

  const Round3DView({
    super.key,
    required this.progress,
    required this.color,
    required this.label,
  });

  @override
  State<Round3DView> createState() => _Round3DViewState();
}

class _Round3DViewState extends State<Round3DView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationAngle = 0.0;
  double _manualRotation = 0.0;
  double _lastRotation = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _controller.addListener(() {
      if (!_isDragging) {
        setState(() {
          _rotationAngle = _controller.value * 2 * math.pi;
        });
      }
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Większe zaokrąglenie karty
      ),
      child: Container(
        height: 120,
        width: 80,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Zaokrąglenie kontenera
          border: Border.all(
            color: Colors.black87, // Ciemna krawędź
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black12,
              Colors.transparent,
              Colors.amber.withAlpha(25), // Delikatny złoty akcent
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dodane
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10, // Mniejsza czcionka
              ),
              textAlign: TextAlign.center, // Dodane
              overflow: TextOverflow.ellipsis, // Dodane
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspektywa
                  ..rotateY(_isDragging ? _manualRotation : _rotationAngle)
                  ..translate(0.0, 0.0, -10.0), // Przesunięcie w głąb
                alignment: Alignment.center,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    _isDragging = true;
                    _controller.stop();
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _manualRotation = _lastRotation + details.primaryDelta! / 100;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    _isDragging = false;
                    _lastRotation = _manualRotation;
                    _controller.forward(from: _manualRotation / (2 * math.pi));
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: RoundPainter(
                      progress: widget.progress,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundPainter extends CustomPainter {
  final double progress;
  final Color color;

  RoundPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber.withAlpha(76),  // 0.3 * 255 = 76
          Colors.transparent,
          Colors.black26,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;

    // Rysowanie cylindra
    final Path cylinderPath = Path();
    
    // Górna elipsa z większym zaokrągleniem
    final topRect = Rect.fromCenter(
      center: center.translate(0, -radius / 2),
      width: radius * 2,
      height: radius,
    );
    cylinderPath.addOval(topRect);

    // Boczne ściany z zaokrąglonymi rogami
    final double cornerRadius = radius / 4;
    
    cylinderPath.moveTo(center.dx - radius, center.dy - radius / 2);
    cylinderPath.lineTo(center.dx - radius, center.dy + radius - cornerRadius);
    cylinderPath.quadraticBezierTo(
      center.dx - radius, center.dy + radius,
      center.dx - radius + cornerRadius, center.dy + radius
    );
    cylinderPath.lineTo(center.dx + radius - cornerRadius, center.dy + radius);
    cylinderPath.quadraticBezierTo(
      center.dx + radius, center.dy + radius,
      center.dx + radius, center.dy + radius - cornerRadius
    );
    cylinderPath.lineTo(center.dx + radius, center.dy - radius / 2);

    // Dolna elipsa z zaokrągleniem
    final bottomRect = Rect.fromCenter(
      center: center.translate(0, radius),
      width: radius * 2,
      height: radius,
    );
    cylinderPath.addOval(bottomRect);

    // Rysowanie głównego kształtu
    canvas.drawPath(cylinderPath, paint);
    canvas.drawPath(cylinderPath, borderPaint);
    canvas.drawPath(cylinderPath, highlightPaint);

    // Rysowanie wypełnienia dla postępu z zaokrągleniem
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = Colors.white.withAlpha(76)  // 0.3 * 255 = 76
        ..style = PaintingStyle.fill;

      final progressHeight = (radius * 3) * progress;
      final progressPath = Path();
      
      final progressRadius = radius / 3;
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - radius + progressRadius,
          center.dy + radius - progressHeight,
          radius * 2 - progressRadius * 2,
          progressHeight,
        ),
        Radius.circular(progressRadius),
      );
      
      progressPath.addRRect(progressRect);
      canvas.drawPath(progressPath, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RoundPainter oldDelegate) => 
    oldDelegate.progress != progress || oldDelegate.color != color;
}
