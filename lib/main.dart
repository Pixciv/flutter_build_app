import 'dart:convert'; import 'dart:html' as html; import 'dart:typed_data'; import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget { @override Widget build(BuildContext context) { return MaterialApp( title: 'Balls of Explode', theme: ThemeData.dark().copyWith( scaffoldBackgroundColor: const Color.fromRGBO(25, 25, 25, 1), fontFamily: 'Tomorrow', ), home: ImageUploadScreen(), ); } }

class ImageUploadScreen extends StatefulWidget { @override _ImageUploadScreenState createState() => _ImageUploadScreenState(); }

class _ImageUploadScreenState extends State<ImageUploadScreen> { List<String?> base64Images = List<String?>.filled(4, null); final int maxImageSize = 250; bool allUploaded = false; String errorMessage = '';

void _pickImage(int index) async { final uploadInput = html.FileUploadInputElement(); uploadInput.accept = 'image/*'; uploadInput.click();

uploadInput.onChange.listen((event) async {
  final file = uploadInput.files?.first;
  if (file == null) return;

  final reader = html.FileReader();
  reader.readAsDataUrl(file);

  await reader.onLoad.first;
  final base64 = reader.result as String;
  setState(() {
    base64Images[index] = base64;
    allUploaded = base64Images.every((img) => img != null);
    errorMessage = allUploaded ? '' : 'Please upload all 4 photos';
  });
});

}

void startGame() { if (!allUploaded) { setState(() { errorMessage = 'Please upload all 4 photos before starting.'; }); return; } Navigator.push( context, MaterialPageRoute( builder: () => GameScreen(images: base64Images.cast<String>()), ), ); }

@override Widget build(BuildContext context) { return Scaffold( body: SafeArea( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ const Padding( padding: EdgeInsets.all(12.0), child: Text('SELECT PHOTO OF YOUR BALLS', style: TextStyle(fontSize: 24), textAlign: TextAlign.center), ), Wrap( spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: List.generate(4, (index) { final image = base64Images[index]; return GestureDetector( onTap: () => _pickImage(index), child: Container( width: 100, height: 100, decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24, width: 2), color: Colors.white10, ), child: image != null ? ClipRRect( borderRadius: BorderRadius.circular(8), child: Image.memory( base64Decode(image.split(',').last), fit: BoxFit.cover, ), ) : Center( child: Text('${index + 1}st Photo', style: TextStyle(color: Colors.white54)), ), ), ); }), ), const SizedBox(height: 20), ElevatedButton( onPressed: allUploaded ? _startGame : null, child: const Text('START GAME'), style: ElevatedButton.styleFrom( backgroundColor: allUploaded ? Colors.blue : Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), textStyle: const TextStyle(fontSize: 18), ), ), if (errorMessage.isNotEmpty) Padding( padding: const EdgeInsets.only(top: 12.0), child: Text(errorMessage, style: const TextStyle(color: Colors.orangeAccent)), ), ], ), ), ); } }

class GameScreen extends StatelessWidget { final List<String> images;

GameScreen({required this.images});

@override Widget build(BuildContext context) { return Scaffold( body: Center( child: Text("TODO: Canvas Rendering with Images"), ), ); } }

