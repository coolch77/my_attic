import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_attic/controllers/app_launch_home_controller.dart';
import 'package:my_attic/controllers/store_data_home_controller.dart';

import 'package:my_attic/screens/app_launch_home.dart';
import 'package:my_attic/screens/store_data_home.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'screens/index_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final StreamSubscription _textStreamSubscription;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    // 앱이 실행되고 있는 상태에서 링크가 전달 될 때
    _textStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String textStream) async {
      print("[MyApp] getTextStream() - textStream : $textStream");
      if (textStream.isNotEmpty && RegExp(r'(?:(https?):\/\/)').hasMatch(textStream)) {
        Get.find<StoreDataHomeController>().data.value = textStream;
        Get.offAllNamed('/StoreDataHome');
      } else {
        Get.offAllNamed('/AppLaunchHome');
      }
    }, onError: (err) {
      print("[MyApp] getTextStream() - error: $err");
    });
    // For sharing or opening urls/text coming from outside the app while the app is closed
    // 앱이 실행되지 않고 있는 상태에서 링크가 전달 될 때
    ReceiveSharingIntent.getInitialText().then((String? initialText) async {
      print("[MyApp] getInitialText() - initialText : $initialText");
      if (initialText != null &&
          initialText.isNotEmpty &&
          RegExp(r'(?:(https?):\/\/)').hasMatch(initialText)) {
        Get.find<StoreDataHomeController>().data.value = initialText;
        Get.offAllNamed('/StoreDataHome');
      } else {
        Get.offAllNamed('/AppLaunchHome');
      }
    }, onError: (err) {
      print("[MyApp] getInitialText() - error: $err");
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _textStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Attic',
      home: IndexHome(),
      initialBinding: BindingsBuilder(() {
        // Get.put(IndexHomeController());
        Get.put(AppLaunchHomeController());
        Get.put(StoreDataHomeController()); // set theme controller first
      }),
      getPages: [
        GetPage(
          name: '/',
          page: () => IndexHome(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/AppLaunchHome',
          page: () => AppLaunchHome(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/StoreDataHome',
          page: () => StoreDataHome(),
          transition: Transition.noTransition,
        ),
      ],
    );
  }
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      // 앱이 표시되고 사용자 입력에 응답합니다.
      // 주의! 최초 앱 실행때는 해당 이벤트가 발생하지 않습니다.
      print("[MyApp] didChangeAppLifecycleState() - resumed");
      break;
    case AppLifecycleState.inactive:
      // 앱이 비활성화 상태이고 사용자의 입력을 받지 않습니다.
      // ios에서는 포 그라운드 비활성 상태에서 실행되는 앱 또는 Flutter 호스트 뷰에 해당합니다.
      // 안드로이드에서는 화면 분할 앱, 전화 통화, PIP 앱, 시스템 대화 상자 또는 다른 창과 같은 다른 활동이 집중되면 앱이이 상태로 전환됩니다.
      // inactive가 발생되고 얼마후 pasued가 발생합니다.
      print("[MyApp] didChangeAppLifecycleState() - inactive");
      break;
    case AppLifecycleState.paused:
      // 앱이 현재 사용자에게 보이지 않고, 사용자의 입력을 받지 않으며, 백그라운드에서 동작 중입니다.
      // 안드로이드의 onPause()와 동일합니다.
      // 응용 프로그램이 이 상태에 있으면 엔진은 Window.onBeginFrame 및 Window.onDrawFrame 콜백을 호출하지 않습니다.
      print("[MyApp] didChangeAppLifecycleState() - paused");
      break;
    case AppLifecycleState.detached:
      // 응용 프로그램은 여전히 flutter 엔진에서 호스팅되지만 "호스트 View"에서 분리됩니다.
      // 앱이 이 상태에 있으면 엔진이 "View"없이 실행됩니다.
      // 엔진이 처음 초기화 될 때 "View" 연결 진행 중이거나 네비게이터 팝으로 인해 "View"가 파괴 된 후 일 수 있습니다.
      print("[MyApp] didChangeAppLifecycleState() - detached");
      break;
  }
}
