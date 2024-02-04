import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoiceBubble extends StatefulWidget {
  const VoiceBubble({super.key});

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  /// 音频播放状态
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        _isPlaying.value = !_isPlaying.value;
        Future.delayed(const Duration(seconds: 5), () {
          _isPlaying.value = false;
        });
      },
      pressedOpacity: 0.7,
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 160,
        child: Row(
          children: [
            // ValueListenableBuilder(
            //   valueListenable: _isPlaying,
            //   builder: (context, value, child) {
            //     if (value) {
            //       return Text('data');
            //     }
            //     return Image.asset(
            //       'assets/images/ic_voice.png',
            //       width: 24,
            //       fit: BoxFit.contain,
            //     );
            //   },
            // ),
            const SizedBox(width: 5),
            Container(
              color: Colors.grey.withOpacity(0.5),
              child: CustomPaint(
                /// width * 1.5
                size: const Size(20, 20),
                painter: _VoicePlayPainter(),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              '12 \'\'',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoicePlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Path path = Path()
    //   ..addArc(Rect.fromLTWH(0, 0, size.width, size.height), 7 * pi / 4, pi / 2)
    //   ..close();

    // canvas.drawPath(path, paint);

    final center = Offset(0, size.height / 2);

    canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: size.width / 2,
          height: size.height / 2,
        ),
        7 * pi / 4,
        pi / 2,
        true,
        paint);

    paint.style = PaintingStyle.stroke;

    canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: size.width,
          height: size.height,
        ),
        7 * pi / 4,
        pi / 2,
        false,
        paint);

    canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: size.width * 1.5,
          height: size.height * 1.5,
        ),
        7 * pi / 4,
        pi / 2,
        false,
        paint);
  }

  @override
  bool shouldRepaint(_VoicePlayPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_VoicePlayPainter oldDelegate) => false;
}
