import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sounds_message/sounds_button/sounds_button.dart';
import 'package:sounds_message/sounds_button_single/sounds_button.dart';
import 'package:sounds_message/utils/recorder.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 667),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          // debugShowMaterialGrid: true,
          // showPerformanceOverlay: true,
          // debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _items = List.generate(15, (index) => '文字内容 $index');
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      resizeToAvoidBottomInset: false,
      body: VoiceChatView(
        scrollController: _controller,
        onSendSounds: (type, content) {
          // 建议局部刷新
          setState(() {
            _items.insert(0, content);
          });
        },
        child: ListView.builder(
          reverse: true,
          controller: _controller,
          itemBuilder: (context, index) {
            final isLeft = index % 2 == 0;
            final color = isLeft ? Colors.yellow[200] : Colors.red[300];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                textDirection:
                    index % 2 == 0 ? TextDirection.ltr : TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: ScreenUtil().screenWidth / 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_items[index]),
                  ),
                ],
              ),
            );
          },
          itemCount: _items.length,
        ),
      ),
    );
  }
}

class VoiceChatView extends StatefulWidget {
  const VoiceChatView({
    super.key,
    this.scrollController,
    required this.child,
    required this.onSendSounds,
  });

  final Widget child;

  final ScrollController? scrollController;

  final Function(SendContentType, String) onSendSounds;

  @override
  State<VoiceChatView> createState() => _VoiceChatViewState();
}

class _VoiceChatViewState extends State<VoiceChatView> {
  final _padding = ValueNotifier(EdgeInsets.zero);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          Expanded(child: widget.child),
          ValueListenableBuilder(
            valueListenable: _padding,
            builder: (context, value, child) => AnimatedPadding(
              padding: value,
              duration: const Duration(milliseconds: 200),
            ),
          ),
          SoundsMessageButton(
            // key: _key,
            onChanged: (status) {
              debugPrint(status.toString());
              // 120 是遮罩层的视图高度
              _padding.value = EdgeInsets.symmetric(
                  vertical: status == SoundsMessageStatus.none
                      ? 0
                      : (120 + 60 - (30 + 44) / 2) / 2 + 15);
              widget.scrollController?.animateTo(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            },
            onSendSounds: widget.onSendSounds,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
