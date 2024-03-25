import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sounds_message/sounds_button/sounds_button.dart';
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
          // showSemanticsDebugger: true,
          debugShowCheckedModeBanner: false,
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
  final ScrollController _controller = ScrollController();

  EdgeInsets _padding = EdgeInsets.zero;

  // final _key = GlobalKey();

  final List<String> _items = List.generate(20, (index) => '测试 $index');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Column(
        children: [
          Expanded(
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
          AnimatedPadding(
            padding: _padding,
            duration: const Duration(milliseconds: 200),
          ),
          // RecordingBotSpace(
          //   statusKey: _key,
          //   scrollController: _controller,
          // ),
          SoundsMessageButton(
            // key: _key,
            onChanged: (status) {
              setState(() {
                // 120 是遮罩层的视图高度
                _padding = EdgeInsets.symmetric(
                    vertical: status == SoundsMessageStatus.initialized
                        ? 0
                        : (120 + 60 - (30 + 44) / 2) / 2 + 15);
              });
              _controller.animateTo(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            },
            onSendSounds: (content) {
              setState(() {
                _items.insert(0, content);
              });
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
