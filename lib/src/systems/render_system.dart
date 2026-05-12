import 'dart:math';
import 'dart:ui';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/components/color_component.dart';
import 'package:test_ecs/src/components/tag_component.dart';
import 'package:test_ecs/src/asteroid_game.dart';

/// Renders all entities that have a PositionComponent, SizeComponent and
/// ColorComponent.  Asteroids are drawn as irregular polygons; the player
/// as a triangle rocket.
class GameRenderSystem extends System with RenderSystem, GameRef<AsteroidGame> {
  Query? _query;

  @override
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<ColorComponent>(),
    ]);
  }

  @override
  void render(Canvas canvas) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      final pos = entity.get<PositionComponent>()!.position;
      final size = entity.get<SizeComponent>()!.size;
      final paint = entity.get<ColorComponent>()!.data!;
      final tag = entity.get<TagComponent>()?.data ?? '';

      if (tag == 'player') {
        _drawPlayer(canvas, pos, size, paint);
      } else if (tag == 'asteroid') {
        _drawAsteroid(canvas, pos, size, paint, entity.id.hashCode);
      }
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  void _drawPlayer(Canvas canvas, pos, size, Paint paint) {
    final cx = pos.x;
    final cy = pos.y;
    final hw = size.x / 2;
    final hh = size.y / 2;

    // Triangle pointing up
    final path = Path()
      ..moveTo(cx, cy - hh)
      ..lineTo(cx - hw, cy + hh)
      ..lineTo(cx + hw, cy + hh)
      ..close();

    canvas.drawPath(path, paint);

    // Engine glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFF6600).withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + hh + 6),
        width: hw * 0.8,
        height: 10,
      ),
      glowPaint,
    );
  }

  void _drawAsteroid(Canvas canvas, pos, size, Paint paint, int seed) {
    final rng = Random(seed);
    final cx = pos.x;
    final cy = pos.y;
    final r = size.x / 2;
    const sides = 8;

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (2 * pi * i / sides);
      final jitter = 0.6 + rng.nextDouble() * 0.4;
      final x = cx + cos(angle) * r * jitter;
      final y = cy + sin(angle) * r * jitter;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, outlinePaint);
  }
}
