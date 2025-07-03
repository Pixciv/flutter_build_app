import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(
    home: ImagePickerWithPermission(),
    debugShowCheckedModeBanner: false,
  ));
}

class ImagePickerWithPermission extends StatefulWidget {
  const ImagePickerWithPermission({Key? key}) : super(key: key);

  @override
  State<ImagePickerWithPermission> createState() => _ImagePickerWithPermissionState();
}

class _ImagePickerWithPermissionState extends State<ImagePickerWithPermission> {
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.photos, // iOS
      Permission.storage, // Android < 13
      if (Platform.isAndroid && (await _androidVersion()) >= 33)
        Permission.photos, // Android 13+
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  Future<int> _androidVersion() async {
    try {
      var sdkInt = await MethodChannel('com.kina.night/device').invokeMethod<int>('getSdkInt');
      return sdkInt ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _pickImage() async {
    bool granted = await _requestPermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gerekli izinler verilmedi")));
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Galeriden Resim Seç")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pickedImage == null
                ? const Text("Henüz resim seçilmedi")
                : Image.file(File(_pickedImage!.path), width: 250),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Galeriden Resim Seç"),
            ),
          ],
        ),
      ),
    );
  }
}
