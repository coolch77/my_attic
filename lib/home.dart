import 'dart:async';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late final StreamSubscription _intentDataStreamSubscription;

  String? _sharedLink = '';
  String? _sharedLinkShortCut = '';
  String? _sharedTitle = '';
  String? _sharedImage = '';
  String? _sharedDescription = '';

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    // 앱이 실행되고 있는 상태에서 링크가 전달 될 때
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String externalUrl) async {
      await updateLinkInfo(externalUrl);
    }, onError: (err) {
      print("[Home] getTextStream() - error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    // 앱이 실행되지 않고 있는 상태에서 링크가 전달 될 때
    ReceiveSharingIntent.getInitialText().then((String? externalUrl) async {
      await updateLinkInfo(externalUrl);
    }, onError: (err) {
      print("[Home] getInitialText() - error: $err");
    });
  }

  Future<void> updateLinkInfo(String? externalUrl) async {
    print('[Home] updateLinkInfo() - externalUrl = $externalUrl');
    if (externalUrl == null || externalUrl.isEmpty) {
      return;
    } else {
      var url = '';
      var values = externalUrl.split(RegExp(r'\s'));
      url = values.last;

      setState(() {
        _sharedLink = url;
        _sharedLinkShortCut = url.split('/')[2].trim();
      });

      try {
        var headers = {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64)AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36'
        };
        http.Response data = await http.get(Uri.parse(url), headers: headers);

        if (data.body.isEmpty) {
          setState(() {
            _sharedTitle = externalUrl;
          });
        } else {
          print('[Home] updateLinkInfo() - data.body = ${data.body}');
          BeautifulSoup soup = BeautifulSoup(data.body);

          print('[Home] updateLinkInfo() - soup = $soup');

          var title = '';
          Bs4Element? titleElement = soup.find('', selector: 'meta[property="og:title"]');
          if (titleElement != null) {
            title = titleElement['content']!;
            print('[Home] updateLinkInfo() - title = $title');
          }

          var image = '';
          Bs4Element? imageElement = soup.find('', selector: 'meta[property="og:image"]');
          if (imageElement != null) {
            image = imageElement['content']!;
            print('[Home] updateLinkInfo() - image = $image');
          }

          var description = '';
          Bs4Element? descriptionElement = soup.find('', selector: 'meta[property="og:description"]');
          if (descriptionElement != null) {
            description = descriptionElement['content']!;
            print('[Home] updateLinkInfo() - description = $description');
          }

          setState(() {
            _sharedTitle = (title.isEmpty) ? externalUrl : title;
            _sharedImage = (image.isEmpty) ? '' : image;
            _sharedDescription = (description.isEmpty) ? '' : description;
          });
        }
      } catch (e) {
        print('[Home] updateLinkInfo() - MetadataFetch.extract - error - $e');
        setState(() {
          _sharedLink = url;
          _sharedTitle = externalUrl;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  void launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Attic')),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.05),
            GestureDetector(
              onTap: () {
                print('[Home] onTap() - _sharedLink - $_sharedLink, _sharedImage - $_sharedImage');
                if (_sharedLink == null || _sharedLink!.isEmpty) {
                  return;
                }
                Vibrate.feedback(FeedbackType.impact);
                launchURL(_sharedLink!);
              },
              child: Container(
                width: Get.width * 0.9,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: _sharedImage != null && _sharedImage!.isNotEmpty,
                        child: Container(
                          width: double.maxFinite,
                          height: Get.height * 0.2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            child: (_sharedImage == null || _sharedImage!.isEmpty)
                                ? SizedBox()
                                : FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: _sharedImage!,
                                    fit: BoxFit.cover,
                                    width: Get.width * 0.9,
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.015),
                      SizedBox(
                        height: Get.height * 0.025,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                          child: Text(
                            _sharedTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Get.height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.01),
                      SizedBox(
                        height: Get.height * 0.025,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                          child: Text(
                            _sharedDescription!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Get.height * 0.016,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.01),
                      SizedBox(
                        height: Get.height * 0.025,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                          child: Text(
                            _sharedLinkShortCut!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Get.height * 0.014,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 표시되고 사용자 입력에 응답합니다.
        // 주의! 최초 앱 실행때는 해당 이벤트가 발생하지 않습니다.
        print("resumed");
        break;
      case AppLifecycleState.inactive:
        // 앱이 비활성화 상태이고 사용자의 입력을 받지 않습니다.
        // ios에서는 포 그라운드 비활성 상태에서 실행되는 앱 또는 Flutter 호스트 뷰에 해당합니다.
        // 안드로이드에서는 화면 분할 앱, 전화 통화, PIP 앱, 시스템 대화 상자 또는 다른 창과 같은 다른 활동이 집중되면 앱이이 상태로 전환됩니다.
        // inactive가 발생되고 얼마후 pasued가 발생합니다.
        print("inactive");
        break;
      case AppLifecycleState.paused:
        // 앱이 현재 사용자에게 보이지 않고, 사용자의 입력을 받지 않으며, 백그라운드에서 동작 중입니다.
        // 안드로이드의 onPause()와 동일합니다.
        // 응용 프로그램이 이 상태에 있으면 엔진은 Window.onBeginFrame 및 Window.onDrawFrame 콜백을 호출하지 않습니다.
        print("paused");
        break;
      case AppLifecycleState.detached:
        // 응용 프로그램은 여전히 flutter 엔진에서 호스팅되지만 "호스트 View"에서 분리됩니다.
        // 앱이 이 상태에 있으면 엔진이 "View"없이 실행됩니다.
        // 엔진이 처음 초기화 될 때 "View" 연결 진행 중이거나 네비게이터 팝으로 인해 "View"가 파괴 된 후 일 수 있습니다.
        print("detached");
        break;
    }
  }
}
