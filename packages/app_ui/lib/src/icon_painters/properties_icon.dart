import 'package:flutter/material.dart';

/// A widget that paints an Properties Icon.
class PropertiesIcon extends StatelessWidget {
  /// Creates an Properties Icon.
  const PropertiesIcon({
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
      painter: _PropertiesIconPainter(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _PropertiesIconPainter extends CustomPainter {
  _PropertiesIconPainter({this.color = Colors.black, this.strokeWidth = 1.5});

  final Color color;

  final double strokeWidth;
  @override
  void paint(Canvas canvas, Size size) {
    final path_0 = Path()
      ..moveTo(7, 9.01)
      ..lineTo(7.01, 8.999)
      ..moveTo(11, 9.01)
      ..lineTo(11.01, 8.999)
      ..moveTo(7, 13.01)
      ..lineTo(7.01, 12.999)
      ..moveTo(11, 13.01)
      ..lineTo(11.01, 12.999)
      ..moveTo(7, 17.01)
      ..lineTo(7.01, 16.999000000000002)
      ..moveTo(11, 17.01)
      ..lineTo(11.01, 16.999000000000002)
      ..moveTo(15, 21)
      ..lineTo(3.6, 21)
      ..arcToPoint(
        const Offset(3, 20.4),
        radius: const Radius.elliptical(0.6, 0.6),
      )
      ..lineTo(3, 5.6)
      ..arcToPoint(
        const Offset(3.6, 5),
        radius: const Radius.elliptical(0.6, 0.6),
      )
      ..lineTo(9, 5)
      ..lineTo(9, 3.6)
      ..arcToPoint(
        const Offset(9.6, 3),
        radius: const Radius.elliptical(0.6, 0.6),
      )
      ..lineTo(14.399999999999999, 3)
      ..arcToPoint(
        const Offset(14.999999999999998, 3.6),
        radius: const Radius.elliptical(0.6, 0.6),
      )
      ..lineTo(14.999999999999998, 9)
      ..moveTo(14.999999999999998, 21)
      ..lineTo(20.4, 21)
      ..arcToPoint(
        const Offset(21, 20.4),
        radius: const Radius.elliptical(0.6, 0.6),
        clockwise: false,
      )
      ..lineTo(21, 9.6)
      ..arcToPoint(
        const Offset(20.4, 9),
        radius: const Radius.elliptical(0.6, 0.6),
        clockwise: false,
      )
      ..lineTo(15, 9)
      ..moveTo(15, 21)
      ..lineTo(15, 17)
      ..moveTo(15, 9)
      ..lineTo(15, 13)
      ..moveTo(15, 13)
      ..lineTo(17, 13)
      ..moveTo(15, 13)
      ..lineTo(15, 17)
      ..moveTo(15, 17)
      ..lineTo(17, 17);

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
