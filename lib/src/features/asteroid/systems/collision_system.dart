import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/shared/components/tag_component.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';

/// Simple circle-circle collision detection between the player and asteroids.
class CollisionSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  Query? _query;

  @override
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<TagComponent>(),
    ]);
  }

  @override
  void update(double dt) {
    if (game!.isGameOver) return;

    final entities = _query?.entities.toList() ?? [];

    Entity? player;
    final asteroids = <Entity>[];

    for (final e in entities) {
      final tag = e.get<TagComponent>()?.data;
      if (tag == 'player') player = e;
      if (tag == 'asteroid') asteroids.add(e);
    }

    if (player == null) return;

    final playerPos = player.get<PositionComponent>()?.position;
    final playerSize = player.get<SizeComponent>()?.size;

    if (playerPos == null || playerSize == null) return;

    final playerRadius = playerSize.x / 2 * 0.75;

    for (final asteroid in asteroids) {
      final aPos = asteroid.get<PositionComponent>()?.position;
      final aSize = asteroid.get<SizeComponent>()?.size;

      if (aPos == null || aSize == null) continue;

      final aRadius = aSize.x / 2 * 0.75;

      final dist = (playerPos - aPos).length;
      if (dist < playerRadius + aRadius) {
        game!.triggerGameOver();
        return;
      }
    }
  }
}
