import 'dart:ui';
import 'package:flame/components.dart' hide PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';
import 'package:test_ecs/src/shared/components/tag_component.dart';
import 'package:test_ecs/src/shared/components/velocity_component.dart';
import 'package:test_ecs/src/features/player/entities/bullet_entity.dart';
import 'package:test_ecs/src/features/player/components/powerup_component.dart';
import 'package:test_ecs/src/features/player/components/bullet_component.dart';
import 'package:test_ecs/src/shared/components/color_component.dart';
import 'package:flutter/services.dart';

class InputSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  Query? _query;

  static const double _speed = 420;
  static const double _baseFireInterval = 0.25;
  static const double _rapidFireInterval = 0.08;
  double _fireTimer = 0;

  @override
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<VelocityComponent>(),
      Has<TagComponent>(),
      Has<PlayerStatsComponent>(),
    ]);
  }

  @override
  void update(double dt) {
    if (game!.isGameOver || game!.paused || !game!.isStarted) return;

    final target = game!.pointerTarget;
    final keys = game!.keysPressed;

    for (final entity in _query?.entities ?? <Entity>[]) {
      final tag = entity.get<TagComponent>()?.data;
      if (tag != 'player') continue;

      final pos = entity.get<PositionComponent>()?.position;
      final vel = entity.get<VelocityComponent>()?.data;
      final stats = entity.get<PlayerStatsComponent>()!;

      if (pos == null || vel == null) continue;

      // Handle PowerUp Timer
      if (stats.activePowerUp != null) {
        stats.powerUpTimer -= dt;
        if (stats.powerUpTimer <= 0) {
          stats.activePowerUp = null;
        }
      }

      // Handle automatic shooting
      final interval = stats.activePowerUp == PowerUpType.rapid
          ? _rapidFireInterval
          : _baseFireInterval;
      _fireTimer += dt;
      if (_fireTimer >= interval) {
        _fireTimer = 0;
        _fire(pos, stats.activePowerUp);
      }

      // Movement logic
      vel.setZero();
      final moveDir = Vector2.zero();
      if (keys.contains(LogicalKeyboardKey.keyW) ||
          keys.contains(LogicalKeyboardKey.arrowUp)) {
        moveDir.y -= 1;
      }
      if (keys.contains(LogicalKeyboardKey.keyS) ||
          keys.contains(LogicalKeyboardKey.arrowDown)) {
        moveDir.y += 1;
      }
      if (keys.contains(LogicalKeyboardKey.keyA) ||
          keys.contains(LogicalKeyboardKey.arrowLeft)) {
        moveDir.x -= 1;
      }
      if (keys.contains(LogicalKeyboardKey.keyD) ||
          keys.contains(LogicalKeyboardKey.arrowRight)) {
        moveDir.x += 1;
      }

      if (!moveDir.isZero()) {
        moveDir.normalize();
        vel.setFrom(moveDir * _speed);
      } else if (target != null) {
        final diff = target - pos;
        if (diff.length > 4) {
          diff.normalize();
          vel.setFrom(diff * _speed);
        } else {
          pos.setFrom(target);
        }
      }
    }
  }

  void _fire(Vector2 pos, PowerUpType? type) {
    if (type == PowerUpType.triple) {
      // Triple Shot: Straight, and two angled
      BulletEntity.create(world!, position: pos.clone(), velocity: Vector2(0, -600));
      BulletEntity.create(world!, position: pos.clone(), velocity: Vector2(-150, -580));
      BulletEntity.create(world!, position: pos.clone(), velocity: Vector2(150, -580));
    } else if (type == PowerUpType.plasma) {
      // Plasma: One large, powerful bullet
      world!.createEntity()
        ..add<PositionComponent, Vector2>(pos.clone())
        ..add<VelocityComponent, Vector2>(Vector2(0, -500))
        ..add<SizeComponent, Vector2>(Vector2(20, 20))
        ..add<ColorComponent, Paint>(Paint()..color = const Color(0xFFFF00FF))
        ..add<TagComponent, String>('bullet')
        ..add<BulletComponent, void>();
    } else {
      // Standard or Rapid Fire
      BulletEntity.create(world!, position: pos.clone(), velocity: Vector2(0, -600));
    }
  }
}
