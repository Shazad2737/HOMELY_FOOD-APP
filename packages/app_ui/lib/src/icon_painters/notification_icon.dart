import 'package:flutter/material.dart';

/// A widget that paints an Notification Icon.
class NotificationIcon extends StatelessWidget {
  /// Creates an Notification Icon.
  const NotificationIcon({
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
      painter: _NotificationIconPainter(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _NotificationIconPainter extends CustomPainter {
  _NotificationIconPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.5,
  });

  final Color color;

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path_0 = Path()
      ..moveTo(18, 8.4)
      ..cubicTo(18, 6.703, 17.368, 5.075, 16.243, 3.875)
      ..cubicTo(15.117999999999999, 2.675, 13.59, 2, 12, 2)
      ..cubicTo(10.41, 2, 8.883, 2.674, 7.757, 3.875)
      ..cubicTo(6.632, 5.075, 6, 6.703, 6, 8.4)
      ..cubicTo(6, 15.867, 3, 18, 3, 18)
      ..lineTo(21, 18)
      ..cubicTo(21, 18, 18, 15.867, 18, 8.4)
      ..moveTo(13.73, 21)
      ..arcToPoint(
        const Offset(10.27, 21),
        radius: const Radius.elliptical(2, 2),
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
