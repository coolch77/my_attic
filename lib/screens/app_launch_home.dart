import 'package:flutter/material.dart';

class AppLaunchHome extends StatelessWidget {
  const AppLaunchHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('AppLaunchHome'),
      ),
      body: Placeholder(),
    );
  }
}
