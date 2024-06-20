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

    const lineSize = Size(2, 6);
    const lineSpec = 2.0;
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
  bool shouldRepaint(WavePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(WavePainter oldDelegate) => false;
}
