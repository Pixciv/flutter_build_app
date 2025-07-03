import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    // İzinleri iste
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Kamera izni
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showPermissionDeniedDialog('Kamera izni reddedildi!');
      }
    }

    // Depolama/galeri izni
    // Android 13+ için READ_MEDIA_IMAGES izni
    if (await Permission.photos.isDenied) {
      var photosStatus = await Permission.photos.request();
      if (!photosStatus.isGranted) {
        _showPermissionDeniedDialog('Galeri izni reddedildi!');
      }
    } else {
      // Android 13 öncesi için READ_EXTERNAL_STORAGE
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          _showPermissionDeniedDialog('Depolama izni reddedildi!');
        }
      }
    }
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İzin Gerekiyor'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadLocalHtml();
  }

  void loadLocalHtml() async {
    final fileHtml =
        await DefaultAssetBundle.of(context).loadString('assets/web/index.html');

    final uri = Uri.dataFromString(
      fileHtml,
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
