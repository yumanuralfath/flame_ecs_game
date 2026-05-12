import 'package:flame/components.dart' hide PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/asteroid_game.dart';
import 'package:test_ecs/src/components/tag_component.dart';
import 'package:test_ecs/src/components/velocity_component.dart';
import 'package:flutter/services.dart';

/// Moves the player entity toward the current touch/pointer target or via keyboard.
class InputSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  Query? _query;

  static const double _speed = 420;

  @override
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<VelocityComponent>(),
      Has<TagComponent>(),
    ]);
  }

  @override
  void update(double dt) {
    if (game!.isGameOver || game!.paused) return;

    final target = game!.pointerTarget;
    final keys = game!.keysPressed;

    for (final entity in _query?.entities ?? <Entity>[]) {
      final tag = entity.get<TagComponent>()?.data;
      if (tag != 'player') continue;

      final pos = entity.get<PositionComponent>()?.position;
      final vel = entity.get<VelocityComponent>()?.data;

      if (pos == null || vel == null) continue;

      // Reset velocity each frame
      vel.setZero();

      // Keyboard input (takes precedence or combines)
      final moveDir = Vector2.zero();
      if (keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp)) {
        moveDir.y -= 1;
      }
      if (keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown)) {
        moveDir.y += 1;
      }
      if (keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft)) {
        moveDir.x -= 1;
      }
      if (keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight)) {
        moveDir.x += 1;
      }

      if (!moveDir.isZero()) {
        moveDir.normalize();
        vel.setFrom(moveDir * _speed);
        // If keyboard is used, pointer target is ignored to prevent "fighting"
      } else if (target != null) {
        // Pointer (touch/drag) logic
        final diff = target - pos;
        final dist = diff.length;
        if (dist > 4) {
          diff.normalize();
          vel.setFrom(diff * _speed);
        } else {
          vel.setZero();
          pos.setFrom(target);
        }
      }
    }
  }
}
