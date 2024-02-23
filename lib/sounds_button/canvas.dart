part of 'sounds_button.dart';

// 自定义画布

class _RecordingPainter extends CustomPainter {
  final bool isFocus;
  _RecordingPainter(this.isFocus);

  @override
  void paint(Canvas canvas, Size size) async {
    final bgOvalRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 3 / 2),
        width: size.width * 1.8,
        height: size.height * 3);

    final paint = Paint()
      ..color = const Color(0xff393939)
      ..style = PaintingStyle.fill;
    Path path = Path()..addOval(bgOvalRect);

    if (isFocus) {
      paint.color = const Color(0xffb0b0b0);
      canvas.drawPath(path, paint);

      final scale = (size.height * 3 - 8) / (size.height * 3);

      final bgShaderRect = Rect.fromCenter(
        center: bgOvalRect.center,
        width: bgOvalRect.width * scale,
        height: bgOvalRect.height * scale,
      );
      canvas.drawPath(
          Path()..addOval(bgShaderRect),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(size.width / 2, size.height),
              Offset(size.width / 2, 0),
              [
                const Color(0xffd5d5d5),
                const Color(0xff999999),
              ],
            ));

      // canvas.drawImage(
      //     await 'assets/images/ic_voice.png'.uiimage, Offset.zero, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RecordingPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_RecordingPainter oldDelegate) => false;
}

/// 绘制气泡
class _BubblePainter extends CustomPainter {
  final RecordingMaskOverlayData data;
  final SoundsMessageStatus status;
  final double paddingSide;
  _BubblePainter(this.data, this.status, this.paddingSide);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff95ec6a)
      ..style = PaintingStyle.fill;

    if (status == SoundsMessageStatus.canceling) {
      paint.color = const Color(0xfffa5251);
    }

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final path = Path();

    // 三角形
    var dx = rect.center.dx;
    // if (status == SoundsMessageStatus.canceling) {
    //   dx = paddingSide + data.iconFocusSize / 2 - 24;
    // } else
    if (status == SoundsMessageStatus.textProcessing ||
        status == SoundsMessageStatus.textProcessed) {
      dx = size.width + 24 - paddingSide - data.iconFocusSize / 2;
    }
    path.moveTo(dx - 7, size.height);
    path.lineTo(dx, size.height + 6);
    path.lineTo(dx + 7, size.height);

    // 矩形
    path.addRRect(rrect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_BubblePainter oldDelegate) => false;
}

// extension on String {
//   Future<ui.Image> get uiimage async {
//     final data = await rootBundle.load(this);
//     return decodeImageFromList(data.buffer.asUint8List());
//   }
// }
  