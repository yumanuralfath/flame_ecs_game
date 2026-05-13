import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/core/asteroid_game.dart';
import 'src/ui/hud.dart';
import 'src/ui/main_menu.dart';
import 'src/ui/pause_menu.dart';
import 'src/ui/game_over_menu.dart';

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
