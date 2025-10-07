import 'package:flutter/material.dart';

/// A widget that paints an Profile Icon.
class ProfileIcon extends StatelessWidget {
  /// Creates an Profile Icon.
  const ProfileIcon({
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
      painter: _ProfileIconPainter(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _ProfileIconPainter extends CustomPainter {
  _ProfileIconPainter({this.color = Colors.black, this.strokeWidth = 1.5});

  final Color color;

  final double strokeWidth;
  @override
  void paint(Canvas canvas, Size size) {
    final path_0 = Path()
      ..moveTo(5, 20)
      ..lineTo(5, 19)
      ..arcToPoint(const Offset(12, 12), radius: const Radius.elliptical(7, 7))
      ..lineTo(12, 12)
      ..arcToPoint(const Offset(19, 19), radius: const Radius.elliptical(7, 7))
      ..lineTo(19, 20)
      ..moveTo(12, 12)
      ..arcToPoint(
        const Offset(12, 4),
        radius: const Radius.elliptical(4, 4),
        largeArc: true,
        clockwise: false,
      )
      ..arcToPoint(
        const Offset(12, 12),
        radius: const Radius.elliptical(4, 4),
        clockwise: false,
      );

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
