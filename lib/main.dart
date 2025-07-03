import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: WebViewWithBalls(),
    debugShowCheckedModeBanner: false,
  ));
}

class WebViewWithBalls extends StatefulWidget {
  const WebViewWithBalls({Key? key}) : super(key: key);

  @override
  State<WebViewWithBalls> createState() => _WebViewWithBallsState();
}

class _WebViewWithBallsState extends State<WebViewWithBalls>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Ball> balls;
  final int numBalls = 15;
  late double screenWidth;
  late double screenHeight;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(() {
        updateBalls();
      });

    balls = [];
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
        radius: 12 + rand.nextDouble() * 8,
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
      body: Stack(
        children: [
          WebView(
            initialUrl: 'assets/web/index.html',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _loadHtmlFromAssets();
            },
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: BallPainter(balls: balls),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHtmlFromAssets() async {
    final htmlString = await DefaultAssetBundle.of(context)
        .loadString('assets/web/index.html');
    _webViewController.loadUrl(Uri.dataFromString(
      htmlString,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}

class Ball {
  double x, y, dx, dy, radius;
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
      final paint = Paint()..color = ball.color.withOpacity(0.5);
      canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
