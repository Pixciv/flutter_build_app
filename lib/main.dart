import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String appName = '{{APP_NAME}}'; // Bu metin sed ile değiştirilecek

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appName),
        ),
        body: Center(
          child: Text('Welcome to $appName!'),
        ),
      ),
    );
  }
}
