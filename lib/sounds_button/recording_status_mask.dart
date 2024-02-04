// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sounds_button.dart';

/// 当正在录制的时候，页面显示的 `OverlayEntry`
class RecordingMaskOverlayData {
  /// 底部圆形的高度
  final double sendAreaHeight;

  /// 圆形图形大小
  final double iconSize;

  /// 圆形图形大小 - 响应
  final double iconFocusSize;

  /// 录音气泡大小
  // final EdgeInsets soundsMargin;

  /// 圆形图形颜色
  final Color iconColor;

  /// 圆形图形颜色 - 响应
  final Color iconFocusColor;

  /// 文字颜色
  final Color iconTxtColor;

  /// 文字颜色 - 响应
  final Color iconFocusTxtColor;

  /// 遮罩文字样式
  final TextStyle maskTxtStyle;

  const RecordingMaskOverlayData({
    this.sendAreaHeight = 120,
    this.iconSize = 66,
    this.iconFocusSize = 82,
    this.iconColor = const Color(0xff393939),
    this.iconFocusColor = const Color(0xffffffff),
    this.iconTxtColor = const Color(0xff909090),
    this.iconFocusTxtColor = const Color(0xff000000),
    // this.soundsMargin = const EdgeInsets.symmetric(horizontal: 24),
    this.maskTxtStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xff909090),
    ),
  });
}

class RecordingStatusMaskView extends StatelessWidget {
  const RecordingStatusMaskView(this.status, this.data, {super.key});

  final ValueNotifier<SoundsMessageStatus> status;

  /// 语音输入时遮罩配置
  final RecordingMaskOverlayData data;

  @override
  Widget build(BuildContext context) {
    final paddingSide = (ScreenUtil().screenWidth - data.iconFocusSize * 3) / 3;

    return Material(
      // type: MaterialType.transparency,
      color: Colors.black.withOpacity(0.72),
      child: ValueListenableBuilder(
        valueListenable: status,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: data.sendAreaHeight + 15,
                left: paddingSide,
                child: _Circle(
                  data: data,
                  title: value.title,
                  isFocus: value == SoundsMessageStatus.canceling,
                ),
              ),
              Positioned(
                bottom: data.sendAreaHeight + 15,
                right: paddingSide,
                child: _Circle(
                  data: data,
                  title: value.title,
                  isFocus: value == SoundsMessageStatus.textProcessing,
                  isLeft: false,
                ),
              ),
              _Bubble(
                paddingSide: paddingSide,
                data: data,
                status: value,
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
                    size: Size(double.infinity, data.sendAreaHeight),
                    painter: _RecordingPainter(
                        value == SoundsMessageStatus.recording),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 显示气泡
class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.paddingSide,
    required this.data,
    required this.status,
  });

  final double paddingSide;
  final RecordingMaskOverlayData data;
  final SoundsMessageStatus status;

  @override
  Widget build(BuildContext context) {
    const height = 80.0;
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
    return Positioned(
      left: 0,
      right: 0,
      bottom: data.sendAreaHeight * 2 + data.iconFocusSize * 2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(left: rect.left, right: rect.right),
        height: rect.height,
        width: rect.width,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _BubblePainter(data, status, paddingSide),
            child: Container(
              // height: rect.height,
              // width: rect.width,
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 10, bottom: 10),
              child: const Center(
                child: Text('xxxxxxxxxxxxxx'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 圆形按钮
class _Circle extends StatelessWidget {
  const _Circle({
    required this.data,
    required this.title,
    this.isFocus = false,
    this.isLeft = true,
  });

  final String title;

  final RecordingMaskOverlayData data;

  /// 是否为焦点
  final bool isFocus;

  /// 是否为左边
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
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
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
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
                    color: isFocus ? data.iconFocusTxtColor : data.iconTxtColor,
                  )
                : Text(
                    '文',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isFocus ? data.iconFocusTxtColor : data.iconTxtColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
