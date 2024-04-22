// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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
class SoundsRecorderController with AudioRecorderMixin {
  /// 录音配置
  final RecordConfig config;

  SoundsRecorderController({
    this.config =
        const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
  });

  /// 修改语音转文字的内容
  final TextEditingController textProcessedController = TextEditingController();

  /// 是否完成了语音转文字的操作
  bool isTranslated = false;

  /// 音频地址
  final path = ValueNotifier<String?>('');

  /// 录音操作的状态
  final status = ValueNotifier(SoundsMessageStatus.none);

  /// 当前区间间隔的音频振幅
  final amplitude = ValueNotifier<Amplitude>(Amplitude(current: 0, max: 1));

  /// 录音操作时间内的音频振幅集合，最新值在前
  /// [0.0 ~ 1.0]
  final amplitudeList = ValueNotifier<List<double>>([]);

  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<RecordState>? _recordSub;
  StreamSubscription<Amplitude>? _amplitudeSub;

  final duration = ValueNotifier<int>(0);
  Timer? _timer;

  Completer<String?>? _stopCompleter;

  /// 开始录制前就已经结束
  /// 用于录音还未开始，用户就已经松开手指结束录制的特殊情况
  //  bool beforeEnd = false;
  /// 用途同上
  late Function(String? path, int time) _onAllCompleted;

  /// 录制
  beginRec({
    /// 录制状态
    ValueChanged<RecordState>? onStateChanged,

    /// 音频振幅
    ValueChanged<Amplitude>? onAmplitudeChanged,

    /// 录制时间
    ValueChanged<int>? onDurationChanged,

    /// 结束录制
    /// 录制时长超过60s时，自动断开的处理
    required Function(String? path, int time) onCompleted,
  }) async {
    reset();

    _stopCompleter = Completer();
    _onAllCompleted = onCompleted;

    updateStatus(SoundsMessageStatus.recording);

    // 记录时间
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      duration.value++;
      if (duration.value >= 60) {
        endRec();
      }
      onDurationChanged?.call(duration.value);
    });

    // 录制状态
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) async {
      onStateChanged?.call(recordState);
      if (recordState == RecordState.stop) {
        // 返回地址
        path.value = await _stopCompleter?.future;
        onCompleted.call(path.value, duration.value);
        //
        reset();
      }
    });

    // 音频振幅
    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 110))
        .listen((amp) {
      // print(20 * log10(amp.current / amp.max));
      amplitude.value = amp;
      amplitudeList.value = [
        (50 + amp.current) / 50,
        ...amplitudeList.value,
      ];
      onAmplitudeChanged?.call(amp);
    });

    await recordFile(_audioRecorder, config);
  }

  /// 停止录音
  Future endRec() async {
    if (_stopCompleter != null && await _audioRecorder.isRecording()) {
      _stopCompleter?.complete(_audioRecorder.stop());
    } else {
      _onAllCompleted(null, 0);
      reset();
    }
  }

  /// 重置
  reset() {
    textProcessedController.clear();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _timer?.cancel();
    _stopCompleter = null;
    duration.value = 0;
    amplitude.value = Amplitude(current: 0, max: 1);
    amplitudeList.value = [];
    isTranslated = false;
  }

  /// 权限
  Future<bool> hasPermission() {
    return _audioRecorder.hasPermission();
  }

  Future<bool> isEncoderSupported() async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      config.encoder,
    );

    if (!isSupported) {
      debugPrint('${config.encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${config.encoder.name}');
        }
      }
    }

    return isSupported;
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

/// 录音类扩展
mixin AudioRecorderMixin {
  Future<void> recordFile(AudioRecorder recorder, RecordConfig config) async {
    final path = await _getPath();

    await recorder.start(config, path: path);
  }

  Future<void> recordStream(AudioRecorder recorder, RecordConfig config) async {
    final path = await _getPath();

    final file = File(path);

    final stream = await recorder.startStream(config);

    stream.listen(
      (data) {
        print(
          recorder.convertBytesToInt16(Uint8List.fromList(data)),
        );
        file.writeAsBytesSync(data, mode: FileMode.append);
      },
      onDone: () {
        print('End of stream. File written to $path.');
      },
    );
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
      dir.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }
}
