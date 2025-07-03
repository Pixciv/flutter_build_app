import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: LocalWebViewApp()));
}

class LocalWebViewApp extends StatefulWidget {
  const LocalWebViewApp({Key? key}) : super(key: key);

  @override
  State<LocalWebViewApp> createState() => _LocalWebViewAppState();
}

class _LocalWebViewAppState extends State<LocalWebViewApp> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/web/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Local WebView")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
