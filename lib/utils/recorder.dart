import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum SoundsMessageStatus {
  /// 默认状态 未交互/交互完成
  initialized,

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
      case initialized:
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
  /// 修改语音转文字的内容
  final TextEditingController textProcessedController = TextEditingController();

  /// 音频地址
  final path = ValueNotifier<String?>('');

  /// 录音操作的状态
  final status = ValueNotifier(SoundsMessageStatus.initialized);

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

  /// 录制
  beginRec({
    RecordConfig config =
        const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),

    /// 录制状态
    ValueChanged<RecordState>? onStateChanged,

    /// 音频振幅
    ValueChanged<Amplitude>? onAmplitudeChanged,

    /// 录制时间
    ValueChanged<int>? onDurationChanged,

    /// 结束录制
    /// 方便录制时长超过60s时，自动断开的处理
    required Function(String? path, int time) onCompleted,
  }) async {
    reset();
    // 额外添加首次授权时，不能开启录音
    if (await _audioRecorder.hasPermission() == false) {
      return;
    }
    if (!await _isEncoderSupported(config.encoder)) {
      return;
    }

    _stopCompleter = Completer();

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
        .onAmplitudeChanged(const Duration(milliseconds: 60))
        .listen((amp) {
      // print(20 * log10(amp.current / amp.max));
      amplitude.value = amp;
      amplitudeList.value = [
        (50 + amp.current) / 50,
        ...amplitudeList.value,
      ];
      onAmplitudeChanged?.call(amp);
    });

    // 记录时间
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      duration.value++;
      if (duration.value >= 60) {
        endRec();
      }
      onDurationChanged?.call(duration.value);
    });

    await recordFile(_audioRecorder, config);
  }

  /// 停止录音
  Future endRec() async {
    // final res = await _audioRecorder.isRecording();
    if (_stopCompleter != null) {
      _stopCompleter?.complete(_audioRecorder.stop());
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
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }

  /// 更新状态
  updateStatus(SoundsMessageStatus value) {
    status.value = value;
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
        // ignore: avoid_print
        print(
          recorder.convertBytesToInt16(Uint8List.fromList(data)),
        );
        file.writeAsBytesSync(data, mode: FileMode.append);
      },
      // ignore: avoid_print
      onDone: () {
        // ignore: avoid_print
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
