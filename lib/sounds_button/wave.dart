import 'dart:math';

import 'package:flutter/material.dart';

// class SoundsAmplitudes extends StatelessWidget {
//   const SoundsAmplitudes(this.items, {super.key});
//   final List<double> items;

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _WavePainter(items),
//     );
//   }
// }

class WavePainter extends CustomPainter {
  WavePainter(this.items) : super(repaint: items);

  /// values 0.0 ~ 1.0
  final ValueNotifier<List<double>> items;

  @override
  void paint(Canvas canvas, Size size) {
    // 振幅数量
    const count = 13;
    const centerConut = count ~/ 2;

    final lineSize = Size(3, size.height - 10);
    const lineSpec = 3.0;
    const radius = Radius.circular(2);

    final center = Offset(size.width / 2, size.height / 2);

    final tempList = List.generate(count, (index) {
      if (index < items.value.length - 1) {
        return items.value[index];
      }
      return 0.0;
    });

    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final height = lineSize.height;

    lineHeight(double scale) {
      return height * min(max(scale * 1.5, 0.1), 1);
    }

    // 中间值
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: lineSize.width,
            height: lineHeight(tempList[centerConut]),
          ),
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
              height: lineHeight(tempList[i]),
            ),
            radius,
          ),
          paint);

      canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                  center.dx - (lineSize.width + lineSpec) * i, center.dy),
              width: lineSize.width,
              height: lineHeight(tempList[i]),
            ),
            radius,
          ),
          paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(WavePainter oldDelegate) => false;
}
