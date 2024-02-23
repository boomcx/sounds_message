import 'package:flutter/material.dart';

class SoundsAmplitudes extends StatelessWidget {
  const SoundsAmplitudes(this.items, {super.key});
  final List<double> items;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavePainter(items),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.ampList);

  /// values 0.0 ~ 1.0
  final List<double> ampList;

  @override
  void paint(Canvas canvas, Size size) {
    // 振幅数量
    const count = 13;
    const centerConut = count ~/ 2;

    const lineSize = Size(2, 6);
    const lineSpec = 2.0;
    const radius = Radius.circular(2);

    final center = Offset(size.width / 2, size.height / 2);

    final tempList = List.generate(count, (index) {
      if (index < ampList.length - 1) {
        return ampList[index];
      }
      return 0.0;
    });

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    // 中间值
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: center,
              width: lineSize.width,
              height: lineSize.height * (tempList[centerConut] * 4 + 1)),
          radius,
        ),
        paint);

    // 边缘值
    for (var i = 0; i <= centerConut; i++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(
                    center.dx + (lineSize.width + lineSpec) * i, center.dy),
                width: lineSize.width,
                height: lineSize.height * (tempList[i] * 4 + 1)),
            radius,
          ),
          paint);

      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(
                    center.dx - (lineSize.width + lineSpec) * i, center.dy),
                width: lineSize.width,
                height: lineSize.height * (tempList[i] * 4 + 1)),
            radius,
          ),
          paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_WavePainter oldDelegate) => false;
}
