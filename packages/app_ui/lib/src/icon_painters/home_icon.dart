import 'package:flutter/material.dart';

/// A widget that paints an Home Icon.
class HomeIcon extends StatelessWidget {
  /// Creates an Home Icon.
  const HomeIcon({
    super.key,
    this.color = Colors.black,
    this.size = 24,
    this.strokeWidth = 1.5,
  });

  /// The color of the icon.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The size of the icon.
  ///
  /// Defaults to 24.
  final double size;

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HomeIconPainter(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  _HomeIconPainter({this.color = Colors.black, this.strokeWidth = 1.5});

  final Color color;

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path_0 = Path()
      ..moveTo(10, 16)
      ..lineTo(14, 16)
      ..moveTo(2, 8)
      ..lineTo(11.732, 3.1340000000000003)
      ..arcToPoint(
        const Offset(12.267999999999999, 3.1340000000000003),
        radius: const Radius.elliptical(0.6, 0.6),
      )
      ..lineTo(22, 8)
      ..moveTo(20, 11)
      ..lineTo(20, 19)
      ..arcToPoint(
        const Offset(18, 21),
        radius: const Radius.elliptical(2, 2),
      )
      ..lineTo(6, 21)
      ..arcToPoint(
        const Offset(4, 19),
        radius: const Radius.elliptical(2, 2),
      )
      ..lineTo(4, 11);

    final paint0Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path_0, paint0Stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
