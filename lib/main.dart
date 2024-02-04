import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sounds_message/sounds_button/sounds_button.dart';

void main() {
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
                return Text('$index xxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              },
              itemCount: 100,
            ),
          ),
          AnimatedPadding(
            padding: _padding,
            duration: const Duration(milliseconds: 200),
          ),
          SoundsMessageButton(
            onChanged: (status) {
              setState(() {
                // 120 是遮罩层的视图高度
                _padding = EdgeInsets.symmetric(
                    vertical: status == SoundsMessageStatus.none
                        ? 0
                        : (120 + 70) / 2);
              });
              _controller.animateTo(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
