import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:shared_preferences/shared_preferences.dart';
// If you want to play audio, add audioplayers to your pubspec.yaml
// import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []); // Hide status and navigation bars
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Prefer portrait for this game
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Shooter',
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme for the game
        fontFamily: 'Tomorrow', // Ensure you add this font to your assets and pubspec.yaml
      ),
      home: const ImageSelectionScreen(), // Start with image selection
    );
  }
}

// --- Image Selection Screen (Equivalent to your first HTML) ---
class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final List<String?> _selectedImagePaths = List.filled(4, null); // Store paths or base64
  final int _requiredImageCount = 4;
  String _errorMessage = '';

  // In a real app, you'd use image_picker package for selecting images from gallery/camera.
  // For this example, we'll simulate it or use pre-defined assets.
  // For simplicity, let's just use placeholder colors instead of actual images for now.
  // You would replace this with actual image picking logic.
  Future<void> _pickImage(int index) async {
    // This is a placeholder. In a real app, use image_picker.
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _selectedImagePaths[index] = image.path; // Store path or convert to base64 if needed
    //   });
    // }
    setState(() {
      // Simulate selecting an image by assigning a placeholder color or asset path
      _selectedImagePaths[index] = 'color_${index % 4}'; // Placeholder for demonstration
      _checkAllImagesLoaded();
    });
  }

  void _checkAllImagesLoaded() {
    final loadedCount = _selectedImagePaths.where((path) => path != null).length;
    if (loadedCount == _requiredImageCount) {
      setState(() {
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = 'Please upload ${_requiredImageCount - loadedCount} more photos.';
      });
    }
  }

  Future<void> _startGame() async {
    if (_selectedImagePaths.where((path) => path != null).length == _requiredImageCount) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('gameImages', _selectedImagePaths.cast<String>());
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GameScreen()),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = "An error occurred: ${e.toString()}";
        });
        debugPrint("LocalStorage error: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAllImagesLoaded(); // Check on init if any images are pre-selected/loaded
  }

  @override
  Widget build(BuildContext context) {
    final bool allImagesLoaded = _selectedImagePaths.where((path) => path != null).length == _requiredImageCount;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(
                'SELECT PHOTO OF YOUR BALLS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 1.8 * 16, // Convert em to pixels
                  color: Colors.white,
                  fontFamily: 'Tomorrow',
                ),
              ),
            ),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: List.generate(_requiredImageCount, (index) {
                return GestureDetector(
                  onTap: () => _pickImage(index),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedImagePaths[index] != null ? Colors.blueAccent : Colors.grey,
                        width: 2,
                        style: BorderStyle.dashed,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: _selectedImagePaths[index] != null
                        ? Center(
                          child: Icon(Icons.check_circle, color: Colors.green, size: 50),
                          // In a real app: Image.file(File(_selectedImagePaths[index]!)),
                          // Or a small thumbnail of the picked image.
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey),
                              Text(
                                '${index + 1}st Photo',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 0.75 * 16),
                              ),
                            ],
                          ),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: ElevatedButton(
                onPressed: allImagesLoaded ? _startGame : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allImagesLoaded ? const Color(0xFF029DFF) : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  textStyle: TextStyle(fontSize: 1.3 * 16, fontFamily: 'Tomorrow'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('START GAME'),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 0.95 * 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Game Screen (Equivalent to your second HTML + JS game logic) ---

// Define the colors for the balls (replace with actual image data later)
const List<Color> kBallColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
];

final List<Color> kFrameColors = [
  Colors.yellow, // Yellow
  Colors.cyan,   // Cyan
  Colors.magenta, // Magenta
  Colors.green,  // Green
];

Color getFrameColor(int imageIndex) {
  return kFrameColors[imageIndex % kFrameColors.length];
}

class Ball {
  double x, y;
  double radius;
  int type; // mq in JS, represents image/color type
  bool isBooming;
  double nextY; // For smooth sliding/falling
  bool isIsolated;
  double fallSpeed;
  Color borderColor;

  Ball({
    required this.x,
    required this.y,
    required this.radius,
    required this.type,
    this.isBooming = false,
    double? nextY,
    this.isIsolated = false,
    this.fallSpeed = 0.7,
  })  : nextY = nextY ?? y,
        borderColor = getFrameColor(type);

  void fall() {
    if (isIsolated) {
      y += fallSpeed;
    } else if (y < nextY) {
      y = min(nextY, y + GameConstants.slideIncrementPerFrame);
    } else if (y > nextY) {
      y = max(nextY, y - GameConstants.slideIncrementPerFrame);
    }
  }
}

class PlayerBall extends Ball {
  double angle;
  bool isMoving;
  List<Offset> trail;

  PlayerBall({
    required super.x,
    required super.y,
    required super.radius,
    required super.type,
    this.angle = 0,
    this.isMoving = false,
  }) : trail = [];
}

class BoomParticle {
  double x, y;
  double radius;
  double angle;
  Color color;

  BoomParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.angle,
    required this.color,
  });
}

class GameConstants {
  static double ballRadius = 0; // Will be calculated based on screen width
  static double ballDiameter = 0;
  static double lineEndY = 0; // Game over line
  static const double slideAmountPerRow = 0; // Will be calculated
  static const double slideIncrementPerFrame = 2.0;
  static const int noBoomThreshold = 2; // How many shots without a boom before balls slide down
  static const int explosionThreshold = 5; // Minimum balls to pop
  static const double playerSpeed = 10.0;
  static const double collisionDetectionFactor = 0.95; // For ball-to-ball collision
  static const double hexConnectionThreshold = 1.05; // For checking connected balls
  static const double hexOccupiedThreshold = 0.9; // For checking if hex position is occupied

}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  List<Ball> _dots = [];
  PlayerBall? _player;
  List<BoomParticle> _booms = [];
  bool _gamePlay = true;
  int _score = 0;
  int _highScore = 0;
  bool _isAiming = false;
  Offset? _aimTarget; // Where the user is aiming
  bool _checkBoxAudio = true; // Audio toggle
  int _noBoomStreak = 0;
  bool _slidingInProgress = false;
  int? _lastPoppedImageMq;
  int _consecutivePops = 0;
  bool _bigBoomEffect = false;
  double _bigBoomProgress = 0;
  int _frameCount = 0;
  double _lastTime = 0;
  double _fps = 0;

  late AnimationController _animationController;
  // late AudioPlayer _audioPlayer; // For audio

  @override
  void initState() {
    super.initState();
    // _audioPlayer = AudioPlayer(); // Initialize audio player
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1), // Long duration for continuous animation
    )..addListener(() {
        _updateGame();
        setState(() {}); // Rebuild to paint the new state
        _calcFPS();
      });

    _loadGameImagesAndStart();
    _loadHighScore();
  }

  Future<void> _loadGameImagesAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? gameImagePaths = prefs.getStringList('gameImages');

    if (gameImagePaths == null || gameImagePaths.length != 4) {
      if (mounted) {
        // Redirect to image selection if images are not set up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ImageSelectionScreen()),
        );
      }
      return;
    }

    // In a real app, you'd load actual images here.
    // For this example, we'll just use the placeholder colors/types.
    // List<ui.Image> loadedImages = [];
    // for (String path in gameImagePaths) {
    //   final ByteData data = await rootBundle.load(path); // Or from file
    //   final Uint8List bytes = data.buffer.asUint8List();
    //   final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    //   final ui.FrameInfo fi = await codec.getNextFrame();
    //   loadedImages.add(fi.image);
    // }
    // GameConstants.gameImages = loadedImages; // Store loaded images globally or pass down

    _newGame();
    _animationController.forward(from: 0.0); // Start the animation
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('bubbleHighScore') ?? 0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _audioPlayer.dispose();
    super.dispose();
  }

  void _calcFPS() {
    _frameCount++;
    final now = _animationController.lastElapsedDuration?.inMicroseconds.toDouble() ?? 0;
    if (_lastTime == 0) {
      _lastTime = now;
    }
    final dt = (now - _lastTime) / 1000000.0; // convert microseconds to seconds
    if (dt >= 1.0) { // Update FPS every second
      setState(() {
        _fps = _frameCount / dt;
      });
      _lastTime = now;
      _frameCount = 0;
    }
  }

  void _updateGame() {
    if (!_gamePlay) return;

    // Update player ball position
    if (_player != null && _player!.isMoving) {
      _player!.x += GameConstants.playerSpeed * cos(_player!.angle);
      _player!.y += GameConstants.playerSpeed * sin(_player!.angle);

      // Add to trail
      _player!.trail.add(Offset(_player!.x, _player!.y));
      if (_player!.trail.length > 20) {
        _player!.trail.removeAt(0);
      }

      // Wall collision
      if (_player!.x - _player!.radius < 0) {
        _player!.x = _player!.radius;
        _player!.angle = pi - _player!.angle;
      } else if (_player!.x + _player!.radius > MediaQuery.of(context).size.width) {
        _player!.x = MediaQuery.of(context).size.width - _player!.radius;
        _player!.angle = pi - _player!.angle;
      }

      // Check for collisions with other balls or ceiling
      _checkPlayerCollision();
    }

    // Update and remove boom particles
    _booms.removeWhere((boom) {
      boom.x += 2 * cos(boom.angle);
      boom.y += 2 * sin(boom.angle);
      boom.radius -= 0.5;
      return boom.radius <= 0.6;
    });

    // Update fall animation for balls
    for (var ball in _dots) {
      ball.fall();
    }

    // Check for end game conditions
    _checkEndGame();
  }

  void _checkPlayerCollision() {
    if (_player == null) return;

    bool hitOccurred = false;

    // Ceiling collision
    if (_player!.y <= _player!.radius) {
      hitOccurred = true;
      _stopPlayerBall(_player!.x, _player!.radius);
    }

    if (!hitOccurred) {
      for (int i = 0; i < _dots.length; i++) {
        final dot = _dots[i];
        if (dot.isBooming) continue; // Skip balls already marked for boom

        final distance = sqrt(pow(_player!.x - dot.x, 2) + pow(_player!.y - dot.y, 2));
        final collisionThreshold = (_player!.radius + dot.radius) * GameConstants.collisionDetectionFactor;

        if (distance < collisionThreshold) {
          hitOccurred = true;
          // Find the best hexagonal position around the hit dot
          Offset bestPosition = _getNearestHexPosition(_player!.x, _player!.y);

          _stopPlayerBall(bestPosition.dx, bestPosition.dy);
          break; // Collision detected, stop checking
        }
      }
    }
  }

  void _stopPlayerBall(double finalX, double finalY) {
    if (_player == null) return;
    _player!.isMoving = false;
    _player!.x = finalX;
    _player!.y = finalY;

    // Add player ball to dots list
    final newDot = Ball(
      x: _player!.x,
      y: _player!.y,
      radius: _player!.radius,
      type: _player!.type,
    );
    _dots.add(newDot);

    // Perform color check (same as checkColor in JS)
    _checkConnectedBalls(newDot);
  }

  Offset _getNearestHexPosition(double x, double y) {
    final double rowHeight = GameConstants.ballDiameter * sqrt(3) / 2;
    final double colWidth = GameConstants.ballDiameter;

    // Calculate approximate row and column
    int targetRow = ((y - GameConstants.ballRadius) / rowHeight).round();

    // Determine row offset for staggered columns
    double rowOffset = (targetRow % 2 == 0) ? 0 : GameConstants.ballRadius;

    int targetCol = ((x - GameConstants.ballRadius - rowOffset) / colWidth).round();

    // Calculate precise x and y for the center of the hexagonal cell
    double nearestX = GameConstants.ballRadius + targetCol * colWidth + rowOffset;
    double nearestY = GameConstants.ballRadius + targetRow * rowHeight;

    // Further refinement: Find the closest unoccupied hex position if the calculated one is taken
    // This is more complex and might involve checking neighbors if the initial spot is blocked.
    // For simplicity, we assume the initial nearest spot is sufficient for now.
    // You might need an iterative search for the closest *empty* hex.
    // For now, let's ensure it's within bounds
    nearestX = nearestX.clamp(GameConstants.ballRadius, MediaQuery.of(context).size.width - GameConstants.ballRadius);
    nearestY = nearestY.clamp(GameConstants.ballRadius, MediaQuery.of(context).size.height - GameConstants.ballRadius);

    return Offset(nearestX, nearestY);
  }

  void _checkConnectedBalls(Ball newDot) {
    List<Ball> connectedGroup = [];
    Set<Ball> visited = {};
    Queue<Ball> queue = Queue();

    queue.add(newDot);
    visited.add(newDot);
    connectedGroup.add(newDot);

    while (queue.isNotEmpty) {
      final currentDot = queue.removeFirst();

      for (var neighborDot in _dots) {
        if (currentDot != neighborDot &&
            currentDot.type == neighborDot.type &&
            !visited.contains(neighborDot)) {
          final distance = sqrt(pow(currentDot.x - neighborDot.x, 2) + pow(currentDot.y - neighborDot.y, 2));
          if (distance < (currentDot.radius + neighborDot.radius) * GameConstants.hexConnectionThreshold) {
            queue.add(neighborDot);
            visited.add(neighborDot);
            connectedGroup.add(neighborDot);
          }
        }
      }
    }

    if (connectedGroup.length >= GameConstants.explosionThreshold) {
      _handleBoomEffect(connectedGroup, newDot.type);
      _noBoomStreak = 0;
    } else {
      // No boom, reset boom status for these balls
      for (var ball in connectedGroup) {
        ball.isBooming = false;
      }
      _playAudio('soundball');
      _lastPoppedImageMq = null;
      _consecutivePops = 0;
      _noBoomStreak++;
      if (!_slidingInProgress) {
        _handleNoBoomEffect();
      }
    }

    _prepareNextPlayer();
  }

  void _handleBoomEffect(List<Ball> poppedBalls, int poppedMq) {
    if (_lastPoppedImageMq == null || _lastPoppedImageMq != poppedMq) {
      _lastPoppedImageMq = poppedMq;
      _consecutivePops = 1;
    } else if (_lastPoppedImageMq == poppedMq) {
      _consecutivePops++;
    }

    for (var ballToBoom in poppedBalls) {
      // Create boom particles
      for (int n = 0; n < 10; n++) {
        _booms.add(BoomParticle(
          x: ballToBoom.x,
          y: ballToBoom.y,
          radius: ballToBoom.radius / 2,
          angle: Random().nextDouble() * 2 * pi,
          color: kBallColors[ballToBoom.type], // Use the ball's color
        ));
      }
      _dots.remove(ballToBoom); // Remove the popped ball
      _score++;
    }

    _checkIsolatedBalls(); // Check for isolated balls after a pop

    if (poppedBalls.length > 6) { // Big boom for large pops
      _bigBoomEffect = true;
      _score += 10; // Bonus points
      _playAudio('soundbigboom');
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _bigBoomEffect = false;
          _bigBoomProgress = 0;
        });
      });
    } else {
      _playAudio('soundboom');
    }
  }

  void _handleNoBoomEffect() {
    if (_noBoomStreak >= GameConstants.noBoomThreshold && !_slidingInProgress) {
      _slidingInProgress = true;
      final slideAmount = GameConstants.ballDiameter * sqrt(3) / 2; // Slide by one full row height

      for (var dot in _dots) {
        dot.nextY += slideAmount;
      }

      _noBoomStreak = 0;

      Future.delayed(Duration(milliseconds: (slideAmount / GameConstants.slideIncrementPerFrame * 16.666).round()), () {
        _slidingInProgress = false;
      });
    }
  }

  void _prepareNextPlayer() {
    _newPlayer();
    double maxDotY = 0;
    if (_dots.isNotEmpty) {
      maxDotY = _dots.map((dot) => dot.y + dot.radius).reduce(max);
    }

    if (maxDotY >= GameConstants.lineEndY - GameConstants.ballDiameter * 1.5) {
      // Shift all existing dots down by one row height
      for (var dot in _dots) {
        dot.nextY += GameConstants.ballDiameter * sqrt(3) / 2;
      }
      // Add new row after a short delay for smooth transition
      Future.delayed(const Duration(milliseconds: 15), () {
        _addNewRow();
      });
    }
  }

  void _addNewRow() {
    double currentYForNewRow = GameConstants.ballRadius;
    if (_dots.isNotEmpty) {
      currentYForNewRow = _dots.map((dot) => dot.y).reduce(min) - GameConstants.ballDiameter * sqrt(3) / 2;
    }

    final int estimatedRowNumber = ((currentYForNewRow - GameConstants.ballRadius) / (GameConstants.ballDiameter * sqrt(3) / 2)).round();
    final double nextRowOffset = (estimatedRowNumber % 2 == 0) ? 0 : GameConstants.ballRadius;

    double startX = GameConstants.ballRadius + nextRowOffset;

    for (double x = startX; x < MediaQuery.of(context).size.width - GameConstants.ballRadius; x += GameConstants.ballDiameter) {
      _dots.add(Ball(x: x, y: currentYForNewRow, radius: GameConstants.ballRadius, type: Random().nextInt(kBallColors.length)));
    }
  }

  void _checkIsolatedBalls() {
    for (var dot in _dots) {
      dot.isIsolated = false;
    }

    Set<Ball> connectedToTop = {};
    Queue<Ball> q = Queue();

    for (var dot in _dots) {
      if (!dot.isBooming && dot.y <= GameConstants.ballRadius * 1.1) {
        q.add(dot);
        connectedToTop.add(dot);
      }
    }

    while (q.isNotEmpty) {
      final current = q.removeFirst();

      for (var neighbor in _dots) {
        if (current != neighbor && !connectedToTop.contains(neighbor) && !neighbor.isBooming) {
          final distance = sqrt(pow(current.x - neighbor.x, 2) + pow(current.y - neighbor.y, 2));
          if (distance < GameConstants.ballDiameter * GameConstants.hexConnectionThreshold) {
            q.add(neighbor);
            connectedToTop.add(neighbor);
          }
        }
      }
    }

    int fallCount = 0;
    for (var dot in _dots) {
      if (!connectedToTop.contains(dot) && !dot.isBooming) {
        dot.isIsolated = true;
        dot.nextY = MediaQuery.of(context).size.height + dot.radius; // Target to fall off screen
        dot.fallSpeed = 7; // Faster fall speed
        fallCount++;
      }
    }
    _score += fallCount; // Add points for falling balls
  }

  void _checkEndGame() {
    _dots.removeWhere((dot) => dot.y > MediaQuery.of(context).size.height + dot.radius && dot.isIsolated);

    for (var dot in _dots) {
      if (dot.y + dot.radius >= GameConstants.lineEndY && !dot.isIsolated) {
        _gamePlay = false;
        _endGame();
        break;
      }
    }
  }

  void _endGame() async {
    _playAudio('soundend');
    _animationController.stop(); // Stop the game loop

    final prefs = await SharedPreferences.getInstance();
    if (_score > _highScore) {
      _highScore = _score;
      await prefs.setInt('bubbleHighScore', _highScore);
    }

    // Show End Game UI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: const Text('GAME OVER!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: $_score', style: const TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 10),
              Text(
                _score > _highScore ? 'New High Score: $_highScore' : 'High Score: $_highScore',
                style: TextStyle(color: _score > _highScore ? Colors.yellow : Colors.white, fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newGame();
                _animationController.forward(from: 0.0); // Restart animation
              },
              child: const Text('PLAY AGAIN', style: TextStyle(color: Colors.blueAccent, fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  void _newGame() {
    setState(() {
      _dots = [];
      _booms = [];
      _score = 0;
      _gamePlay = true;
      _noBoomStreak = 0;
      _slidingInProgress = false;
      _lastPoppedImageMq = null;
      _consecutivePops = 0;
      _bigBoomEffect = false;
      _bigBoomProgress = 0;
    });

    _initGameDimensions(); // Re-calculate dimensions
    _createInitialBalls();
    _newPlayer();
  }

  void _initGameDimensions() {
    final Size size = MediaQuery.of(context).size;
    GameConstants.ballRadius = size.width / 16 - 0.01;
    GameConstants.ballDiameter = GameConstants.ballRadius * 2;
    GameConstants.lineEndY = size.height - 1.7 * GameConstants.ballDiameter;
    // Recalculate slide amount based on new diameter
    // GameConstants.slideAmountPerRow = GameConstants.ballDiameter * sqrt(3) / 2;
  }

  void _createInitialBalls() {
    double currentY = GameConstants.ballRadius;
    for (int r = 0; r < 6; r++) {
      double rowXOffset = (r % 2 == 0) ? 0 : GameConstants.ballRadius;
      for (double x = GameConstants.ballRadius + rowXOffset; x < MediaQuery.of(context).size.width - GameConstants.ballRadius; x += GameConstants.ballDiameter) {
        _dots.add(Ball(
          x: x,
          y: currentY,
          radius: GameConstants.ballRadius,
          type: Random().nextInt(kBallColors.length), // Random ball type (color)
        ));
      }
      currentY += GameConstants.ballDiameter * sqrt(3) / 2;
    }
  }

  void _newPlayer() {
    int playerMq = Random().nextInt(kBallColors.length);
    if (_consecutivePops >= 2 && _lastPoppedImageMq != null) {
      playerMq = _lastPoppedImageMq!;
      _consecutivePops = 0;
      _lastPoppedImageMq = null;
    }
    setState(() {
      _player = PlayerBall(
        x: MediaQuery.of(context).size.width / 2,
        y: MediaQuery.of(context).size.height - GameConstants.ballRadius * 2,
        radius: GameConstants.ballRadius,
        type: playerMq,
      );
    });
  }

  void _playAudio(String soundName) {
    if (_checkBoxAudio) {
      // In a real Flutter app, use audioplayers package:
      // You would have pre-loaded AudioCache or AudioPlayer instances.
      // E.g., AudioCache().play('audio/$soundName.mp3');
      debugPrint('Playing sound: $soundName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      body: GestureDetector(
        onPanDown: (details) {
          if (!_player!.isMoving && _gamePlay) {
            setState(() {
              _isAiming = true;
              _aimTarget = details.localPosition;
            });
          }
        },
        onPanUpdate: (details) {
          if (_isAiming && !_player!.isMoving && _gamePlay) {
            setState(() {
              _aimTarget = details.localPosition;
            });
          }
        },
        onPanEnd: (details) {
          if (_isAiming && !_player!.isMoving && _gamePlay) {
            if (_aimTarget != null && _player != null) {
              final dx = _player!.x - _aimTarget!.dx;
              final dy = _player!.y - _aimTarget!.dy;
              _player!.angle = atan2(-dy, -dx);
              _player!.isMoving = true;
              _player!.trail.clear(); // Clear trail on new shot
              _playAudio('soundselect'); // Play sound on shoot
            }
            setState(() {
              _isAiming = false;
              _aimTarget = null;
            });
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: GamePainter(
                dots: _dots,
                player: _player,
                booms: _booms,
                isAiming: _isAiming,
                aimTarget: _aimTarget,
                lineEndY: GameConstants.lineEndY,
                bigBoomEffect: _bigBoomEffect,
                bigBoomProgress: _bigBoomProgress,
              ),
              size: Size.infinite,
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Score: $_score',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Tomorrow'),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                'High Score: $_highScore',
                style: const TextStyle(color: Colors.yellow, fontSize: 18, fontFamily: 'Tomorrow'),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                children: [
                  Text(
                    'FPS: ${_fps.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  IconButton(
                    icon: Icon(
                      _checkBoxAudio ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _checkBoxAudio = !_checkBoxAudio;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Ball> dots;
  final PlayerBall? player;
  final List<BoomParticle> booms;
  final bool isAiming;
  final Offset? aimTarget;
  final double lineEndY;
  final bool bigBoomEffect;
  final double bigBoomProgress;

  GamePainter({
    required this.dots,
    required this.player,
    required this.booms,
    required this.isAiming,
    required this.aimTarget,
    required this.lineEndY,
    required this.bigBoomEffect,
    required this.bigBoomProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw game over line
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, lineEndY), Offset(size.width, lineEndY), linePaint);

    // Draw existing balls
    for (var dot in dots) {
      final Paint ballPaint = Paint()..color = kBallColors[dot.type];
      canvas.drawCircle(Offset(dot.x, dot.y), dot.radius, ballPaint);

      // Draw border
      final Paint borderPaint = Paint()
        ..color = dot.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(dot.x, dot.y), dot.radius, borderPaint);

      // Placeholder for image drawing (if you load actual images)
      // If you have `ui.Image` objects loaded:
      // final Rect srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      // final Rect destRect = Rect.fromCircle(center: Offset(dot.x, dot.y), radius: dot.radius);
      // canvas.drawImageRect(image, srcRect, destRect, Paint());
    }

    // Draw player ball
    if (player != null) {
      // Draw trail
      for (int i = 0; i < player!.trail.length; i++) {
        final trailDot = player!.trail[i];
        final ratio = i / player!.trail.length;
        final alpha = ratio * 0.7;
        final sizeReduction = (1 - ratio) * 0.7;

        final Paint trailPaint = Paint()..color = Colors.white.withOpacity(alpha);
        canvas.drawCircle(trailDot, player!.radius * (1 - sizeReduction), trailPaint);
      }

      final Paint playerPaint = Paint()..color = kBallColors[player!.type];
      canvas.drawCircle(Offset(player!.x, player!.y), player!.radius, playerPaint);

      // Draw border for player ball
      final Paint playerBorderPaint = Paint()
        ..color = player!.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(player!.x, player!.y), player!.radius, playerBorderPaint);

      // Draw aiming line
      if (isAiming && aimTarget != null) {
        final Paint aimLinePaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..strokeWidth = 1;
        canvas.drawLine(Offset(player!.x, player!.y), aimTarget!, aimLinePaint);
      }
    }

    // Draw boom particles
    for (var boom in booms) {
      final Paint boomPaint = Paint()..color = boom.color;
      canvas.drawCircle(Offset(boom.x, boom.y), boom.radius, boomPaint);
    }

    // Draw big boom effect
    if (bigBoomEffect) {
      _drawBlastRings(canvas, size.width / 2, size.height / 2, bigBoomProgress, 10, Colors.white);
      _drawBlastRings(canvas, size.width / 2, size.height / 2, bigBoomProgress - 30, 15, Colors.yellow);
      _drawBlastRings(canvas, size.width / 2, size.height / 2, bigBoomProgress - 50, 20, Colors.orange);
      _drawBlastRings(canvas, size.width / 2, size.height / 2, bigBoomProgress - 100, 30, Colors.red);
      // Particle effect in Flutter could be done with a list of animated circles/emojis
      // For simplicity, omitting individual particles for now in this example
    }
  }

  void _drawBlastRings(Canvas canvas, double x, double y, double radius, double strokeWidth, Color color) {
    if (radius < 0) radius = 0;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(x, y), radius + 30, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if game state changes
    return true; // Simple approach, can be optimized by checking specific state variables
  }
}

// Basic Queue implementation for BFS
class Queue<T> {
  final List<T> _elements = [];

  void add(T element) {
    _elements.add(element);
  }

  T removeFirst() {
    if (_elements.isEmpty) {
      throw StateError('Cannot remove from an empty queue');
    }
    return _elements.removeAt(0);
  }

  bool get isEmpty => _elements.isEmpty;
  bool get isNotEmpty => _elements.isNotEmpty;
  int get length => _elements.length;
}
