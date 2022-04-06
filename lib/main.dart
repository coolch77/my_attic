import 'package:flutter/material.dart';

import 'package:my_attic/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Attic',
      home: Home(),
    );
  }
}
