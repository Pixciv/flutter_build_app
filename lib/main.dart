import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PhotoPopGame()));

class PhotoPopGame extends StatefulWidget {
  const PhotoPopGame({Key? key}) : super(key: key);

  @override
  State<PhotoPopGame> createState() => _PhotoPopGameState();
}

class _PhotoPopGameState extends State<PhotoPopGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Ball> balls;
  final int numBalls = 20;
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1000),
    )..addListener(() {
        updateBalls();
      });

    balls = [];

    // Context kullanılmadan önce post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) => initBalls());

    _controller.repeat();
  }

  void initBalls() {
    final rand = Random();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    balls = List.generate(numBalls, (i) {
      return Ball(
        x: rand.nextDouble() * screenWidth,
        y: rand.nextDouble() * screenHeight / 2,
        dx: rand.nextDouble() * 4 - 2,
        dy: rand.nextDouble() * 4 - 2,
        radius: 20 + rand.nextDouble() * 10,
        color: Colors.primaries[i % Colors.primaries.length],
      );
    });
  }

  void updateBalls() {
    for (var ball in balls) {
      ball.x += ball.dx;
      ball.y += ball.dy;

      if (ball.x < 0 || ball.x > screenWidth) ball.dx *= -1;
      if (ball.y < 0 || ball.y > screenHeight) ball.dy *= -1;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: BallPainter(balls: balls),
          ),
          const Positioned(
            bottom: 30,
            left: 20,
            child: Text(
              'Score: 0',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}

class Ball {
  double x, y;
  double dx, dy;
  double radius;
  Color color;

  Ball({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
  });
}

class BallPainter extends CustomPainter {
  List<Ball> balls;
  BallPainter({required this.balls});

  @override
  void paint(Canvas canvas, Size size) {
    for (var ball in balls) {
      final paint = Paint()..color = ball.color;
      canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BallPainter oldDelegate) => true;
}
