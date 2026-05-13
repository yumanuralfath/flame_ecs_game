import 'dart:ui';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/asteroid_game.dart';

/// Draws the HUD (score and FPS) directly onto the canvas each frame.
class HudSystem extends System with RenderSystem, UpdateSystem, GameRef<AsteroidGame> {
  double _fps = 0;
  double _timer = 0;
  int _frameCount = 0;

  @override
  void init() {}

  @override
  void update(double dt) {
    _timer += dt;
    _frameCount++;

    if (_timer >= 0.5) {
      _fps = _frameCount / _timer;
      _timer = 0;
      _frameCount = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    // Score top-left
    _drawText(canvas, 'Score: ${game!.score}', 16, 12);

    // FPS top-middle
    _drawTextCentered(
      canvas,
      'FPS: ${_fps.toStringAsFixed(1)}',
      game!.size.x / 2,
      12,
      fontSize: 16,
      opacity: 0.8,
    );

    // Tip at bottom centre
    if (!game!.isGameOver) {
      _drawTextCentered(
        canvas,
        'Tap / drag to dodge!',
        game!.size.x / 2,
        game!.size.y - 20,
        fontSize: 14,
        opacity: 0.6,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 22,
    double opacity = 1.0,
  }) {
    final builder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.left))
      ..pushStyle(
        TextStyle(
          color: Color.fromRGBO(255, 255, 255, opacity),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      )
      ..addText(text);
    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: 300));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }

  void _drawTextCentered(
    Canvas canvas,
    String text,
    double cx,
    double y, {
    double fontSize = 18,
    double opacity = 1.0,
  }) {
    final builder =
        ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center))
          ..pushStyle(
            TextStyle(
              color: Color.fromRGBO(255, 255, 255, opacity),
              fontSize: fontSize,
            ),
          )
          ..addText(text);
    final paragraph = builder.build()
      ..layout(ParagraphConstraints(width: cx * 2));
    canvas.drawParagraph(paragraph, Offset(0, y));
  }
}
