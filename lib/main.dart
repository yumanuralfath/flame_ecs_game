import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/asteroid_game.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final AsteroidGame _game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _game = AsteroidGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _game.keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _game.keysPressed.remove(event.logicalKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Stack(
            children: [
              // Use GestureDetector only for the game area,
              // but handle hits correctly
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    if (!_game.isStarted || _game.isGameOver || _game.paused) {
                      return;
                    }
                    _game.pointerTarget = details.localPosition.toVector2();
                  },
                  onPanEnd: (_) => _game.pointerTarget = null,
                  onTapDown: (details) {
                    _focusNode.requestFocus();
                    if (!_game.isStarted || _game.isGameOver || _game.paused) {
                      return;
                    }
                    _game.pointerTarget = details.localPosition.toVector2();
                  },
                  onTapUp: (_) => _game.pointerTarget = null,
                  child: GameWidget<AsteroidGame>(
                    game: _game,
                    overlayBuilderMap: {
                      'HUD': (context, game) => HUD(game: game),
                      'MainMenu': (context, game) => MainMenu(
                        game: game,
                        onStart: () {
                          game.start();
                          _focusNode.requestFocus();
                        },
                      ),
                      'PauseMenu': (context, game) => PauseMenu(
                        game: game,
                        onResume: () {
                          game.resume();
                          _focusNode.requestFocus();
                        },
                        onRestart: () {
                          game.restart();
                          _focusNode.requestFocus();
                        },
                      ),
                      'GameOver': (context, game) => GameOverMenu(
                        game: game,
                        onRestart: () {
                          game.restart();
                          _focusNode.requestFocus();
                        },
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension OffsetToVector2 on Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}

class HUD extends StatelessWidget {
  final AsteroidGame game;
  const HUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: IconButton(
          icon: const Icon(Icons.pause, color: Colors.white70, size: 32),
          onPressed: () {
            game.pause();
          },
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  final AsteroidGame game;
  final VoidCallback onStart;
  const MainMenu({super.key, required this.game, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ASTEROID DODGER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Use WASD / Arrows to Move\nor Drag to Dodge',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'START GAME',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PauseMenu extends StatelessWidget {
  final AsteroidGame game;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  const PauseMenu({
    super.key,
    required this.game,
    required this.onResume,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'RESUME',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'RESTART',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverMenu extends StatelessWidget {
  final AsteroidGame game;
  final VoidCallback onRestart;
  const GameOverMenu({super.key, required this.game, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 56,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: ${game.score}',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
