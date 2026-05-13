import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/asteroid_game.dart';
import 'package:test_ecs/src/components/tag_component.dart';
import 'package:test_ecs/src/components/bullet_component.dart';
import 'package:test_ecs/src/components/explosion_component.dart';
import 'package:test_ecs/src/components/color_component.dart';
import 'package:test_ecs/src/components/velocity_component.dart';
import 'package:test_ecs/src/entities/powerup_entity.dart';
import 'package:test_ecs/src/components/powerup_component.dart';

class BulletCollisionSystem extends System
    with UpdateSystem, GameRef<AsteroidGame> {
  Query? _bulletQuery;
  Query? _asteroidQuery;
  final _rng = Random();

  @override
  void init() {
    _bulletQuery = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<BulletComponent>(),
    ]);
    _asteroidQuery = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<TagComponent>(),
    ]);
  }

  @override
  void update(double dt) {
    if (game!.isGameOver || !game!.isStarted) return;

    final bullets = _bulletQuery?.entities.toList() ?? [];
    final allEntities = _asteroidQuery?.entities.toList() ?? [];

    final asteroids = allEntities
        .where((e) => e.get<TagComponent>()?.data == 'asteroid')
        .toList();

    for (final bullet in bullets) {
      final bPos = bullet.get<PositionComponent>()?.position;
      final bSize = bullet.get<SizeComponent>()?.size;
      if (bPos == null || bSize == null) continue;

      final bRadius = bSize.x / 2;

      for (final asteroid in asteroids) {
        final aPos = asteroid.get<PositionComponent>()?.position;
        final aSize = asteroid.get<SizeComponent>()?.size;
        if (aPos == null || aSize == null) continue;

        final aRadius = aSize.x / 2;

        final dist = (bPos - aPos).length;
        if (dist < bRadius + aRadius) {
          // Collision!
          game!.addScore(10);
          _spawnExplosion(bPos);

          // 15% chance to drop power-up
          if (_rng.nextDouble() < 0.15) {
            PowerUpType type;
            final roll = _rng.nextDouble();
            if (roll < 0.2) {
              type = PowerUpType.plasma; // Rare transformation
            } else if (roll < 0.6) {
              type = PowerUpType.triple;
            } else {
              type = PowerUpType.rapid;
            }
            PowerUpEntity.create(world!, position: aPos.clone(), type: type);
          }

          world!.entityManager.removeEntity(bullet);
          world!.entityManager.removeEntity(asteroid);
          break; // Bullet is gone, move to next bullet
        }
      }
    }
  }

  void _spawnExplosion(Vector2 position) {
    for (int i = 0; i < 12; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 50 + _rng.nextDouble() * 150;
      final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      world!.createEntity()
        ..add<PositionComponent, Vector2>(position.clone())
        ..add<VelocityComponent, Vector2>(velocity)
        ..add<SizeComponent, Vector2>(Vector2(2 + _rng.nextDouble() * 3, 0))
        ..add<ColorComponent, Paint>(Paint()..color = const Color(0xFFFFCC00))
        ..add<TagComponent, String>('particle')
        ..add<ExplosionComponent, double>(0.3 + _rng.nextDouble() * 0.4);
    }
  }
}
