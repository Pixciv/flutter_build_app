import 'dart:async'; import 'dart:math'; import 'dart:ui' as ui; import 'package:flutter/material.dart'; import 'package:flutter/scheduler.dart'; import 'package:image_picker/image_picker.dart';

void main() { runApp(const GameApp()); }

class GameApp extends StatelessWidget { const GameApp({super.key});

@override Widget build(BuildContext context) { return MaterialApp( title: 'Balls of Explode', debugShowCheckedModeBanner: false, home: const GameHomePage(), ); } }

class GameHomePage extends StatefulWidget { const GameHomePage({super.key});

@override State<GameHomePage> createState() => _GameHomePageState(); }

class _GameHomePageState extends State<GameHomePage> with SingleTickerProviderStateMixin { late Ticker _ticker; int fps = 0; int _frameCount = 0; late DateTime _lastFpsUpdate; List<ui.Image> images = []; final List<Ball> balls = []; final picker = ImagePicker(); final Random _random = Random();

@override void initState() { super.initState(); _lastFpsUpdate = DateTime.now(); _ticker = createTicker(_onTick)..start(); _loadDefaultBalls(); }

Future<void> _loadDefaultBalls() async { // Şimdilik boş top listesi ile başlıyoruz for (int i = 0; i < 4; i++) { balls.add(Ball(x: 50.0 * (i + 1), y: 100, vx: _random.nextDouble() * 4 - 2, vy: _random.nextDouble() * 4 - 2)); } }

void _onTick(Duration elapsed) { setState(() { for (var ball in balls) { ball.update(MediaQuery.of(context).size); } _frameCount++; final now = DateTime.now(); if (now.difference(_lastFpsUpdate).inMilliseconds >= 1000) { fps = _frameCount; _frameCount = 0; _lastFpsUpdate = now; } }); }

Future<void> _pickImage(int index) async { final picked = await picker.pickImage(source: ImageSource.gallery); if (picked != null) { final data = await picked.readAsBytes(); final codec = await ui.instantiateImageCodec(data); final frame = await codec.getNextFrame(); setState(() { if (images.length > index) { images[index] = frame.image; } else { images.add(frame.image); } }); } }

@override void dispose() { _ticker.dispose(); super.dispose(); }

@override Widget build(BuildContext context) { return Scaffold( backgroundColor: Colors.black, body: Stack( children: [ GestureDetector( onTapUp: (_) => _pickImage(images.length), child: CustomPaint( painter: GamePainter(balls: balls, images: images), size: Size.infinite, ), ), Positioned( top: 30, right: 20, child: Text('FPS: $fps', style: const TextStyle(color: Colors.white, fontSize: 16)), ), ], ), ); } }

class Ball { double x; double y; double vx; double vy; double radius = 30;

Ball({required this.x, required this.y, required this.vx, required this.vy});

void update(Size size) { x += vx; y += vy;

if (x < radius || x > size.width - radius) vx = -vx;
if (y < radius || y > size.height - radius) vy = -vy;

} }

class GamePainter extends CustomPainter { final List<Ball> balls; final List<ui.Image> images;

GamePainter({required this.balls, required this.images});

@override void paint(Canvas canvas, Size size) { final paint = Paint(); for (int i = 0; i < balls.length; i++) { final ball = balls[i]; if (i < images.length) { canvas.drawImageRect( images[i], Rect.fromLTWH(0, 0, images[i].width.toDouble(), images[i].height.toDouble()), Rect.fromCircle(center: Offset(ball.x, ball.y), radius: ball.radius), paint, ); } else { paint.color = Colors.white; canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, paint); } } }

@override bool shouldRepaint(CustomPainter oldDelegate) => true; }

