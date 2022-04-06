import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final StreamSubscription _intentDataStreamSubscription;
  String? _sharedText = 'no data';

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = (value == null) ? 'no data' : value;
      });
    });
  }

  @override
  void dispose() {
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
        child: Center(
          child: Column(
            children: [
              // Text("Shared files:"),
              // Text((_sharedFiles == null) ? 'no shared files' : _sharedFiles!.map((f) => f.path).join(",")),
              SizedBox(height: 100),
              Text("Shared urls/text:"),
              GestureDetector(
                child: Text(_sharedText == null ? 'no shared text' : _sharedText!),
                onTap: () {
                  if (_sharedText == null) {
                    return;
                  }
                  launchURL(_sharedText!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
