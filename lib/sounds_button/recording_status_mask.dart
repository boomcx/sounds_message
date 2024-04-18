part of 'sounds_button.dart';

class PolymerData {
  PolymerData(this.controller, this.data);

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
    TextTheme;
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
            if (value == SoundsMessageStatus.textProcessed) {
              return _MaskStackView(
                children: [
                  Positioned(
                    bottom: polymerData.data.sendAreaHeight + 15,
                    right: paddingSide,
                    child: _TextProcessedCircle(
                      data: data,
                      onTap: onTextSend,
                      onLoading: () async {
                        /// 没有文字内容时，进行语音转文字操作
                        if (!polymerData.controller.isTranslated) {
                          await Future.delayed(Durations.extralong4);

                          polymerData.controller
                              .updateTextProcessed('我是语音转文字内容');
                        }
                        return true;
                      },
                    ),
                  ),
                  Positioned(
                    bottom: data.sendAreaHeight + data.iconFocusSize / 3,
                    right: paddingSide + data.iconFocusSize + 45,
                    child: _TextVoiceSend(onVoiceSend),
                  ),
                  Positioned(
                    bottom: data.sendAreaHeight + data.iconFocusSize / 3,
                    right: paddingSide + data.iconFocusSize + 45 * 4,
                    child: _TextCancelSend(onCancelSend),
                  ),
                  _Bubble(
                    paddingSide: paddingSide,
                  ),
                ],
              );
            }

            return _MaskStackView(
              children: [
                Positioned(
                  bottom: data.sendAreaHeight + 15,
                  left: paddingSide,
                  child: _Circle(
                    title: value.title,
                    isFocus: value == SoundsMessageStatus.canceling,
                  ),
                ),
                Positioned(
                  bottom: data.sendAreaHeight + 15,
                  right: paddingSide,
                  child: _Circle(
                    title: value.title,
                    isFocus: value == SoundsMessageStatus.textProcessing,
                    isLeft: false,
                  ),
                ),
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
            // color: Colors.red,
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
    Rect rect = const Rect.fromLTRB(24, 0, 24, height);

    if (status == SoundsMessageStatus.recording) {
      rect = Rect.fromLTRB(paddingSide + data.iconFocusSize / 2, 0,
          paddingSide + data.iconFocusSize / 2, height);
    } else if (status == SoundsMessageStatus.canceling) {
      rect = Rect.fromLTRB(
          paddingSide - 5,
          0,
          ScreenUtil().screenWidth - data.iconFocusSize - paddingSide - 10,
          height);
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
              child: status == SoundsMessageStatus.textProcessing ||
                      status == SoundsMessageStatus.textProcessed
                  ? const _TextProcessedContent()
                  : const AmpContent(),
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

/// 文字输入和振幅动画
class _TextProcessedContent extends StatefulWidget {
  const _TextProcessedContent();

  @override
  State<_TextProcessedContent> createState() => _TextProcessedContentState();
}

class _TextProcessedContentState extends State<_TextProcessedContent> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final polymerState = PolymerState.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        focusNode.requestFocus();
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              style: const TextStyle(fontSize: 16),
              focusNode: focusNode,
              controller: polymerState.controller.textProcessedController,
              decoration: const InputDecoration(
                fillColor: Colors.red,
                border: InputBorder.none,
                // border: OutlineInputBorder(),
                hintText: '语音转文字...',
                hintStyle:
                    TextStyle(color: ui.Color.fromARGB(148, 107, 104, 104)),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              maxLines: null,
            ),
          ),
          Visibility(
            visible: polymerState.controller.status.value ==
                SoundsMessageStatus.textProcessing,
            child: const Positioned(
              right: 25,
              bottom: 5,
              child: AmpContent(),
            ),
          )
        ],
      ),
    );
  }
}

/// 圆形按钮
class _Circle extends StatelessWidget {
  const _Circle({
    required this.title,
    this.isFocus = false,
    this.isLeft = true,
  });

  final String title;

  /// 是否为焦点
  final bool isFocus;

  /// 是否为左边
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final polymerState = PolymerState.of(context);

    final data = polymerState.data;

    final size = isFocus ? data.iconFocusSize : data.iconSize;

    double marginSide =
        0 + (isFocus ? 0.5 : 1) * (data.iconFocusSize - data.iconSize);

    return Column(
      children: [
        Visibility(
          visible: isFocus,
          child: Text(title, style: data.maskTxtStyle),
        ),
        // const SizedBox(height: 10),
        AnimatedContainer(
          duration: _duration,
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(
            bottom: marginSide,
            left: marginSide,
            right: marginSide,
            top: marginSide,
          ),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFocus ? data.iconFocusColor : data.iconColor,
            borderRadius: BorderRadius.circular(data.iconFocusSize),
          ),
          child: Transform.rotate(
              angle: isLeft ? -0.2 : 0.2,
              child: isLeft
                  ? Icon(
                      Icons.close,
                      size: 28,
                      color:
                          isFocus ? data.iconFocusTxtColor : data.iconTxtColor,
                    )
                  : Icon(
                      Icons.text_decrease,
                      size: 28,
                      color:
                          isFocus ? data.iconFocusTxtColor : data.iconTxtColor,
                    )
              // : Text(
              //     '文',
              //     style: TextStyle(
              //       fontSize: 22,
              //       fontWeight: FontWeight.bold,
              //       color:
              //           isFocus ? data.iconFocusTxtColor : data.iconTxtColor,
              //     ),
              //   ),
              ),
        ),
      ],
    );
  }
}

/// 转文字的等待按钮
class _TextProcessedCircle extends StatelessWidget {
  const _TextProcessedCircle({
    required this.data,
    this.onLoading,
    this.onTap,
  });

  final RecordingMaskOverlayData data;

  /// 解析语音的延时操作
  final Future<bool> Function()? onLoading;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = data.iconFocusSize;

    double marginSide = 0.5 * (data.iconFocusSize - data.iconSize);

    return FutureBuilder<bool>(
      future: onLoading?.call(),
      builder: (context, snapshot) {
        Widget icon = const CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.orange,
        );
        if (snapshot.data == true) {
          icon = Icon(
            Icons.check_rounded,
            size: data.iconFocusSize / 2.2,
            color: Colors.orange,
          );
        }

        return GestureDetector(
          onTap: () {
            if (snapshot.data == true) {
              onTap?.call();
            }
          },
          child: Container(
            margin: EdgeInsets.only(
              bottom: marginSide,
              left: marginSide,
              right: marginSide,
              top: marginSide,
            ),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.iconFocusColor,
              borderRadius: BorderRadius.circular(data.iconFocusSize),
            ),
            child: icon,
          ),
        );
      },
    );
  }
}

/// 语音转文字时 - 发送语音
class _TextVoiceSend extends StatelessWidget {
  const _TextVoiceSend(this.onTap);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Column(
        children: [
          VoiceIcon(
            color: Colors.white,
            size: 20.w,
          ),
          const SizedBox(height: 5),
          const Text(
            '发送原语音',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// 语音转文字时 - 取消发送
class _TextCancelSend extends StatelessWidget {
  const _TextCancelSend(this.onTap);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            Icons.close_rounded,
            size: 20.w,
            color: Colors.white,
          ),
          const SizedBox(height: 5),
          const Text(
            '取消',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
