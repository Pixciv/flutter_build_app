import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LocalHtmlWebView(),
  ));
}

class LocalHtmlWebView extends StatefulWidget {
  const LocalHtmlWebView({super.key});

  @override
  State<LocalHtmlWebView> createState() => _LocalHtmlWebViewState();
}

class _LocalHtmlWebViewState extends State<LocalHtmlWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Android için platforma özel WebView ayarla
    if (Platform.isAndroid) {
      WebView.platform = const SurfaceAndroidWebView();
    }

    // WebView controller'ı oluştur
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadLocalHtml(); // HTML'yi yükle
  }

  void loadLocalHtml() async {
    final htmlContent =
        await DefaultAssetBundle.of(context).loadString('assets/web/index.html');

    final uri = Uri.dataFromString(
      htmlContent,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    );

    _controller.loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
