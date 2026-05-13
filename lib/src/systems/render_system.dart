import 'dart:math';
import 'dart:ui';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/components/color_component.dart';
import 'package:test_ecs/src/components/tag_component.dart';
import 'package:test_ecs/src/asteroid_game.dart';
import 'package:test_ecs/src/components/explosion_component.dart';
import 'package:test_ecs/src/components/powerup_component.dart';

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
        final stats = entity.get<PlayerStatsComponent>();
        _drawPlayer(canvas, pos, size, paint, stats);
      } else if (tag == 'asteroid') {
        _drawAsteroid(canvas, pos, size, paint, entity.id.hashCode);
      } else if (tag == 'bullet') {
        _drawBullet(canvas, pos, size, paint);
      } else if (tag == 'particle') {
        _drawParticle(canvas, entity, pos, size, paint);
      } else if (tag == 'powerup') {
        _drawPowerUp(canvas, pos, size, paint);
      }
    }
  }

  void _drawPowerUp(Canvas canvas, pos, size, Paint paint) {
    final rect = Rect.fromCenter(
      center: Offset(pos.x, pos.y),
      width: size.x,
      height: size.y,
    );
    canvas.drawRect(rect, paint);
    
    // Simple outline
    final outline = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, outline);
  }

  void _drawParticle(Canvas canvas, Entity entity, pos, size, Paint paint) {
    final explosion = entity.get<ExplosionComponent>();
    if (explosion != null) {
      final opacity = (explosion.life / explosion.totalLife).clamp(0.0, 1.0);
      final p = Paint()
        ..color = paint.color.withValues(alpha: opacity)
        ..style = paint.style;
      canvas.drawCircle(Offset(pos.x, pos.y), size.x / 2, p);
    }
  }

  void _drawBullet(Canvas canvas, pos, size, Paint paint) {
    // If it's a large plasma bullet (size.x > 10), draw with glow
    if (size.x > 10) {
      final glowPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(pos.x, pos.y), size.x * 0.8, glowPaint);
    }
    canvas.drawCircle(Offset(pos.x, pos.y), size.x / 2, paint);
  }

  void _drawPlayer(Canvas canvas, pos, size, Paint paint, PlayerStatsComponent? stats) {
    final cx = pos.x;
    final cy = pos.y;
    final hw = size.x / 2;
    final hh = size.y / 2;

    var shipColor = paint.color;
    if (stats?.activePowerUp == PowerUpType.triple) {
      shipColor = const Color(0xFF00FF00);
    } else if (stats?.activePowerUp == PowerUpType.rapid) {
      shipColor = const Color(0xFF00FFFF);
    } else if (stats?.activePowerUp == PowerUpType.plasma) {
      shipColor = const Color(0xFFFF00FF);
    }

    final shipPaint = Paint()..color = shipColor;

    if (stats?.activePowerUp == PowerUpType.plasma) {
      // UNIQUE TRANSFORMATION: Double Hull Fighter
      final path = Path()
        // Left hull
        ..moveTo(cx - hw, cy + hh)
        ..lineTo(cx - hw * 0.3, cy - hh * 0.5)
        ..lineTo(cx - hw * 0.1, cy + hh)
        ..close()
        // Right hull
        ..moveTo(cx + hw, cy + hh)
        ..lineTo(cx + hw * 0.3, cy - hh * 0.5)
        ..lineTo(cx + hw * 0.1, cy + hh)
        ..close()
        // Center connector/cockpit
        ..addRect(Rect.fromCenter(center: Offset(cx, cy + hh * 0.2), width: hw * 0.4, height: hh));

      canvas.drawPath(path, shipPaint);
    } else {
      // Standard ship shape
      final path = Path()
        ..moveTo(cx, cy - hh)
        ..lineTo(cx - hw, cy + hh)
        ..lineTo(cx + hw, cy + hh)
        ..close();
      canvas.drawPath(path, shipPaint);
    }

    // Engine glow
    final glowColor = stats?.activePowerUp != null
        ? shipColor.withValues(alpha: 0.6)
        : const Color(0xFFFF6600).withValues(alpha: 0.8);
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    if (stats?.activePowerUp == PowerUpType.plasma) {
      // Double engine glow
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - hw * 0.5, cy + hh + 4), width: hw * 0.6, height: 12), glowPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + hw * 0.5, cy + hh + 4), width: hw * 0.6, height: 12), glowPaint);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + hh + 6), width: hw * 0.8, height: 10), glowPaint);
    }
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

    final outlinePaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, outlinePaint);
  }
}
