import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/components/tag_component.dart';
import 'package:test_ecs/src/asteroid_game.dart';

/// Removes asteroid entities once they scroll past the bottom of the screen,
/// and awards one point per escaped asteroid.
class BoundsSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
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

    final screenH = game!.size.y;
    final toRemove = <Entity>[];

    for (final entity in _query?.entities ?? <Entity>[]) {
      final tag = entity.get<TagComponent>()?.data;
      if (tag != 'asteroid') continue;

      final pos = entity.get<PositionComponent>()?.position;
      final size = entity.get<SizeComponent>()?.size;

      if (pos == null || size == null) continue;

      if (pos.y - size.y / 2 > screenH) {
        toRemove.add(entity);
      }
    }

    for (final entity in toRemove) {
      world!.entityManager.removeEntity(entity);
      game!.addScore(1);
    }
  }
}
