import 'package:flutter/material.dart';

/// Official 4-Color Google Brand Logo rendered via pixel-perfect Canvas vector paths.
///
/// True to Google brand guidelines:
/// - Blue: #4285F4
/// - Green: #34A853
/// - Yellow: #FBBC05
/// - Red: #EA4335
class GoogleColoredLogo extends StatelessWidget {
  final double size;
  final bool withBackground;
  final double? backgroundSize;
  final BoxBorder? border;

  const GoogleColoredLogo({
    super.key,
    this.size = 22.0,
    this.withBackground = false,
    this.backgroundSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: const _GoogleLogoPainter(),
      ),
    );

    if (!withBackground) {
      return logoWidget;
    }

    final bgSize = backgroundSize ?? (size + 10.0);

    return Container(
      width: bgSize,
      height: bgSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: border ?? Border.all(color: Colors.black.withValues(alpha: 0.06), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: logoWidget,
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Blue: Horizontal bar and outer right curve (#4285F4)
    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path bluePath = Path()
      ..moveTo(23.745, 12.27)
      ..cubicTo(23.745, 11.48, 23.675, 10.73, 23.545, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.51)
      ..lineTo(18.59, 14.51)
      ..cubicTo(18.31, 15.99, 17.47, 17.24, 16.21, 18.09)
      ..lineTo(16.21, 21.09)
      ..lineTo(20.08, 21.09)
      ..cubicTo(22.34, 19.0, 23.745, 15.92, 23.745, 12.27)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 2. Green: Bottom arc (#34A853)
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path greenPath = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.96, 22.92, 20.08, 21.09)
      ..lineTo(16.21, 18.09)
      ..cubicTo(15.13, 18.81, 13.73, 19.27, 12.0, 19.27)
      ..cubicTo(8.87, 19.27, 6.22, 17.14, 5.27, 14.29)
      ..lineTo(1.27, 14.29)
      ..lineTo(1.27, 17.38)
      ..cubicTo(3.25, 21.31, 7.31, 24.0, 12.0, 24.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 3. Yellow: Bottom-left curve (#FBBC05)
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path yellowPath = Path()
      ..moveTo(5.27, 14.29)
      ..cubicTo(5.03, 13.57, 4.9, 12.8, 4.9, 12.0)
      ..cubicTo(4.9, 11.2, 5.03, 10.43, 5.27, 9.71)
      ..lineTo(5.27, 6.62)
      ..lineTo(1.27, 6.62)
      ..cubicTo(0.46, 8.24, 0.0, 10.06, 0.0, 12.0)
      ..cubicTo(0.0, 13.94, 0.46, 15.76, 1.27, 17.38)
      ..lineTo(5.27, 14.29)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Red: Top arc (#EA4335)
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path redPath = Path()
      ..moveTo(12.0, 4.73)
      ..cubicTo(13.76, 4.73, 15.34, 5.34, 16.59, 6.53)
      ..lineTo(19.97, 3.15)
      ..cubicTo(17.95, 1.27, 15.23, 0.0, 12.0, 0.0)
      ..cubicTo(7.31, 0.0, 3.25, 2.69, 1.27, 6.62)
      ..lineTo(5.27, 9.71)
      ..cubicTo(6.22, 6.86, 8.87, 4.73, 12.0, 4.73)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
