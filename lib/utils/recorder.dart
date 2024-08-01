// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum SendContentType {
  voice,

  text,
}

enum SoundsMessageStatus {
  /// 默认状态 未交互/交互完成
  none,

  /// 录制
  recording,

  /// 取消录制
  canceling,

  /// 语音转文字
  textProcessing,

  /// 语音转文字 - 管理操作
  textProcessed;

  String get title {
    switch (this) {
      case none:
        return '按住 说话';
      case recording:
        return '松开 发送';
      case canceling:
        return '松开 取消';
      case textProcessing:
      case textProcessed:
        return '转文字';
    }
  }
}

/// 录音类
class SoundsRecorderController {
  SoundsRecorderController();

  /// 修改语音转文字的内容
  final TextEditingController textProcessedController = TextEditingController();

  /// 是否完成了语音转文字的操作
  bool isTranslated = false;

  /// 音频地址
  final path = ValueNotifier<String?>('');

  /// 录音操作的状态
  final status = ValueNotifier(SoundsMessageStatus.none);

  /// 当前区间间隔的音频振幅
  // final amplitude = ValueNotifier<Amplitude>(Amplitude(current: 0, max: 1));

  /// 录音操作时间内的音频振幅集合，最新值在前
  /// [0.0 ~ 1.0]
  final amplitudeList = ValueNotifier<List<double>>([]);

  RecorderController? recorderController;
  // StreamSubscription<RecordState>? _recordSub;
  // StreamSubscription<Amplitude>? _amplitudeSub;

  final duration = ValueNotifier<Duration>(Duration.zero);
  Timer? _timer;

  /// 开始录制前就已经结束
  /// 用于录音还未开始，用户就已经松开手指结束录制的特殊情况
  //  bool beforeEnd = false;
  /// 用途同上
  Function(String? path, Duration duration)? _onAllCompleted;

  /// 录制
  beginRec({
    /// 录制状态
    ValueChanged<RecorderState>? onStateChanged,

    /// 音频振幅
    ValueChanged<List<double>>? onAmplitudeChanged,

    /// 录制时间
    ValueChanged<Duration>? onDurationChanged,

    /// 结束录制
    /// 录制时长超过60s时，自动断开的处理
    required Function(String? path, Duration duration) onCompleted,
  }) async {
    try {
      reset();
      _onAllCompleted = onCompleted;

      recorderController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;

      updateStatus(SoundsMessageStatus.recording);

      // 录制状态
      recorderController?.onRecorderStateChanged.listen((state) {
        onStateChanged?.call(state);
      });

      // 时间间隔
      recorderController?.onCurrentDuration.listen((value) {
        duration.value = value;

        if (value.inSeconds >= 60) {
          endRec();
        }

        onDurationChanged?.call(value);

        amplitudeList.value = recorderController!.waveData.reversed.toList();
        print(duration);
      });

      // 录制
      await recorderController!.record(); // Path is optional
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
  }

  /// 停止录音
  Future endRec() async {
    if (recorderController!.isRecording) {
      path.value = await recorderController!.stop();

      if (path.value?.isNotEmpty == true) {
        debugPrint(path.value);
        // debugPrint("Recorded file size: ${File(path.value!).lengthSync()}");
      }

      _onAllCompleted?.call(path.value, duration.value);
    } else {
      _onAllCompleted?.call(null, Duration.zero);
    }
    reset();
  }

  /// 重置
  reset() {
    _timer?.cancel();
    duration.value = Duration.zero;
    recorderController?.dispose();
  }

  /// 权限
  Future<bool> hasPermission() async {
    final state = await Permission.microphone.request();

    return state == PermissionStatus.granted;
  }

  /// 更新状态
  updateStatus(SoundsMessageStatus value) {
    status.value = value;
  }

  /// 语音转文字
  void updateTextProcessed(String text) {
    isTranslated = true;
    textProcessedController.text = text;
  }
}
