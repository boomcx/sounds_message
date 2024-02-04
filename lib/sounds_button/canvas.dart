part of 'sounds_button.dart';

// 自定义画布

class _RecordingPainter extends CustomPainter {
  final bool isFocus;
  _RecordingPainter(this.isFocus);

  @override
  void paint(Canvas canvas, Size size) {
    final bgOvalRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 3.6 / 2),
        width: size.width * 1.6,
        height: size.height * 3.6);

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
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RecordingPainter oldDelegate) => false;

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

    final rect = const Offset(0, 0) & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final path = Path();

    // 三角形
    var dx = rect.center.dx;
    // if (status == SoundsMessageStatus.canceling) {
    //   dx = paddingSide + data.iconFocusSize / 2 - 24;
    // } else
    if (status == SoundsMessageStatus.textProcessing) {
      dx = size.width - paddingSide + 24 - data.iconFocusSize / 2;
    }
    path.moveTo(dx - 8, size.height);
    path.lineTo(dx, size.height + 7);
    path.lineTo(dx + 8, size.height);

    // 矩形
    path.addRRect(rrect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_BubblePainter oldDelegate) => false;
}
