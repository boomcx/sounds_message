// ignore_for_file: avoid_print

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'recording_status_mask.dart';
part 'canvas.dart';

enum SoundsMessageStatus {
  /// 默认状态 为交互/交互完成
  none,

  /// 录制
  recording,

  /// 取消录制
  canceling,

  /// 语音转文字
  textProcessing;

  String get title {
    switch (this) {
      case none:
        return '按住 说话';
      case recording:
        return '松开 发送';
      case canceling:
        return '松开 取消';
      case textProcessing:
        return '转文字';
    }
  }
}

class SoundsMessageButton extends StatefulWidget {
  const SoundsMessageButton({
    super.key,
    this.builder,
    this.onChanged,
    this.maskData = const RecordingMaskOverlayData(),
  });

  /// 自定义发送按钮视图
  final Function(
    BuildContext context,
    SoundsMessageStatus status,
  )? builder;

  /// 状态监听， 回调到外部自定义处理
  final Function(SoundsMessageStatus status)? onChanged;

  /// 语音输入时遮罩配置
  final RecordingMaskOverlayData maskData;

  @override
  State<SoundsMessageButton> createState() => _SoundsMessageButtonState();
}

class _SoundsMessageButtonState extends State<SoundsMessageButton> {
  /// 录音状态
  final _status = ValueNotifier(SoundsMessageStatus.none);

  /// 屏幕大小
  final scSize = Size(ScreenUtil().screenWidth, ScreenUtil().screenHeight);

  /// 遮罩图层
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    // print(scSize);

    _status.addListener(() {
      widget.onChanged?.call(_status.value);
    });
  }

  _removeMask() {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
    }
  }

  _showRecordingMask() {
    _entry = OverlayEntry(
      builder: (context) {
        return RepaintBoundary(
          child: RecordingStatusMaskView(_status, widget.maskData),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _status.value = SoundsMessageStatus.recording;
        _showRecordingMask();
      },
      onLongPressMoveUpdate: (details) {
        final offset = details.globalPosition;
        if ((scSize.height - offset.dy.abs()) >
            widget.maskData.sendAreaHeight) {
          final cancelOffset = offset.dx < scSize.width / 2;
          if (cancelOffset) {
            _status.value = SoundsMessageStatus.canceling;
          } else {
            _status.value = SoundsMessageStatus.textProcessing;
          }
        } else {
          _status.value = SoundsMessageStatus.recording;
        }
      },
      onLongPressEnd: (details) {
        _status.value = SoundsMessageStatus.none;
        _removeMask();
      },
      child: ValueListenableBuilder(
        valueListenable: _status,
        builder: (context, value, child) {
          if (widget.builder != null) {
            return widget.builder?.call(context, value);
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Color(0xffeeeeee), blurRadius: 2)
              ],
            ),
            child: Text(
              value.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 语音输入是，聊天列表底部留白
// class RecordingBottomSpace extends StatelessWidget {
//   const RecordingBottomSpace({
//     super.key,
//     this.scrollController,
//     required this.statusKey,
//   });

//   final GlobalKey<State<SoundsMessageButton>> statusKey;

//   final ScrollController? scrollController;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable:
//           (statusKey.currentState as _SoundsMessageButtonState)._status,
//       builder: (context, value, child) => AnimatedPadding(
//         padding: EdgeInsets.symmetric(
//             vertical: value == SoundsMessageStatus.none ? 0 : (120 + 70) / 2),
//         duration: const Duration(milliseconds: 200),
//       ),
//     );
//   }
// }
