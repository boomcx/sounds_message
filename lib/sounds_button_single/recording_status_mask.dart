part of 'sounds_button.dart';

class PolymerData {
  PolymerData(this.controller, this.data);

  /// 逻辑处理
  final SoundsRecorderController controller;

  /// 语音输入时遮罩配置
  final RecordingMaskOverlayData data;
}

class PolymerState extends InheritedWidget {
  const PolymerState({
    super.key,
    required this.data,
    required super.child,
  });

  final PolymerData data;

  // 子树中的widget获取共享数据
  static PolymerData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PolymerState>();
    return scope!.data;
  }

  @override
  bool updateShouldNotify(covariant PolymerState oldWidget) {
    return oldWidget.data != data;
  }
}

const _duration = Duration(milliseconds: 220);

class RecordingStatusMaskView extends StatelessWidget {
  const RecordingStatusMaskView(
    this.polymerData, {
    super.key,
    this.onCancelSend,
    this.onVoiceSend,
    this.onTextSend,
  });

  final PolymerData polymerData;

  /// 取消发送
  final VoidCallback? onCancelSend;

  /// 原音发送
  final VoidCallback? onVoiceSend;

  /// 文字发送
  final VoidCallback? onTextSend;

  @override
  Widget build(BuildContext context) {
    final paddingSide =
        (ScreenUtil().screenWidth - polymerData.data.iconFocusSize * 3) / 3;

    final data = polymerData.data;

    return Material(
      // type: MaterialType.transparency,
      color: Colors.black.withOpacity(0.7),
      // color: Colors.transparent,
      child: PolymerState(
        data: polymerData,
        child: ValueListenableBuilder(
          valueListenable: polymerData.controller.status,
          builder: (context, value, child) {
            // if (value == SoundsMessageStatus.textProcessed) {
            //   return _MaskStackView(
            //     children: [
            //       Positioned(
            //         bottom: polymerData.data.sendAreaHeight + 15,
            //         right: paddingSide,
            //         child: _TextProcessedCircle(
            //           data: data,
            //           onTap: onTextSend,
            //           onLoading: () async {
            //             /// 没有文字内容时，进行语音转文字操作
            //             if (!polymerData.controller.isTranslated) {
            //               await Future.delayed(Durations.extralong4);

            //               polymerData.controller
            //                   .updateTextProcessed('我是语音转文字内容');
            //             }
            //             return true;
            //           },
            //         ),
            //       ),
            //       Positioned(
            //         bottom: data.sendAreaHeight + data.iconFocusSize / 3,
            //         right: paddingSide + data.iconFocusSize + 45,
            //         child: _TextVoiceSend(onVoiceSend),
            //       ),
            //       Positioned(
            //         bottom: data.sendAreaHeight + data.iconFocusSize / 3,
            //         right: paddingSide + data.iconFocusSize + 45 * 4,
            //         child: _TextCancelSend(onCancelSend),
            //       ),
            //       _Bubble(
            //         paddingSide: paddingSide,
            //       ),
            //     ],
            //   );
            // }

            return _MaskStackView(
              children: [
                // Positioned(
                //   bottom: data.sendAreaHeight + 15,
                //   left: paddingSide,
                //   child: _Circle(
                //     title: value.title,
                //     isFocus: value == SoundsMessageStatus.canceling,
                //   ),
                // ),
                // Positioned(
                //   bottom: data.sendAreaHeight + 15,
                //   right: paddingSide,
                //   child: _Circle(
                //     title: value.title,
                //     isFocus: value == SoundsMessageStatus.textProcessing,
                //     isLeft: false,
                //   ),
                // ),
                _Bubble(
                  paddingSide: paddingSide,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: value == SoundsMessageStatus.recording,
                      child: Text(value.title, style: data.maskTxtStyle),
                    ),
                    const SizedBox(height: 8),
                    CustomPaint(
                      // size: Size(double.infinity, data.sendAreaHeight),
                      painter: _RecordingPainter(
                          value == SoundsMessageStatus.recording),
                      child: Container(
                        width: double.infinity,
                        height: data.sendAreaHeight,
                        alignment: Alignment.center,
                        child: VoiceIcon(color: data.iconTxtColor),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class VoiceIcon extends StatelessWidget {
  const VoiceIcon({
    super.key,
    this.color,
    this.size,
  });

  final Color? color;

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pi / 2,
      child: Icon(
        Icons.wifi_rounded,
        size: size ?? 26.w,
        color: color,
      ),
    );
  }
}

class _MaskStackView extends StatelessWidget {
  const _MaskStackView({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final polymerState = PolymerState.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(alignment: Alignment.bottomCenter, children: [
        Positioned(
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF474747),
                Color(0x00474747),
              ],
            )),
          ),
        ),
        Positioned(
          child: Container(
            height: polymerState.data.sendAreaHeight +
                polymerState.data.iconFocusSize,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF474747),
                Color(0x22474747),
              ],
            )),
          ),
        ),
        ...children,
      ]),
    );
  }
}

/// 显示气泡
class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.paddingSide,
  });

  final double paddingSide;

  @override
  Widget build(BuildContext context) {
    final polymerState = PolymerState.of(context);

    final data = polymerState.data;
    final status = polymerState.controller.status.value;

    // 80 是气泡整体高度
    const height = 64.0;
    Rect rect = Rect.fromLTRB(paddingSide + data.iconFocusSize / 2, 0,
        paddingSide + data.iconFocusSize / 2, height);

    // if (status == SoundsMessageStatus.recording) {
    //   rect = Rect.fromLTRB(paddingSide + data.iconFocusSize / 2, 0,
    //       paddingSide + data.iconFocusSize / 2, height);
    // } else
    if (status == SoundsMessageStatus.canceling) {
      rect = Rect.fromLTRB(paddingSide + data.iconFocusSize / 2 + 32, 0,
          paddingSide + data.iconFocusSize / 2 + 32, height);
    }

    double bottom = 0;
    if (status == SoundsMessageStatus.textProcessing ||
        status == SoundsMessageStatus.textProcessed) {
      bottom = 20;
    }

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Positioned(
      left: 0,
      right: 0,
      // 键盘高度
      bottom:
          max(keyboardHeight, data.sendAreaHeight * 2 + data.iconFocusSize) +
              20,
      // bottom: data.sendAreaHeight * 2 + data.iconFocusSize,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(left: rect.left, right: rect.right, bottom: 0),
        // height: rect.height,
        // width: rect.width,
        constraints: BoxConstraints(
          minHeight: rect.height + bottom,
          maxHeight: (rect.height + bottom) * 2,
          maxWidth: rect.width,
          minWidth: rect.width,
        ),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _BubblePainter(data, status, paddingSide),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              child: const AmpContent(),
            ),
          ),
        ),
      ),
    );
  }
}

/// 振幅动画
class AmpContent extends StatelessWidget {
  const AmpContent({super.key});

  @override
  Widget build(BuildContext context) {
    final polymerState = PolymerState.of(context);
    return CustomPaint(
      painter: WavePainter(polymerState.controller.amplitudeList),
    );

    // return ValueListenableBuilder(
    //   valueListenable: polymerState.controller.amplitudeList,
    //   builder: (context, value, child) {
    //     return SoundsAmplitudes(value);
    //   },
    // );
  }
}
