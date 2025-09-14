import 'package:flutter/material.dart';

class DashedUnderline extends StatelessWidget {
  const DashedUnderline({
    super.key,
    this.color = Colors.white70,
    this.thickness = 1.5,
  });

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 2),
      painter: _DashedLinePainter(color: color, thickness: thickness),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      final double endX = (startX + dashWidth) > size.width
          ? size.width
          : (startX + dashWidth);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
