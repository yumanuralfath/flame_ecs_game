import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/asteroid_game.dart';
import 'package:test_ecs/src/components/tag_component.dart';
import 'package:test_ecs/src/components/velocity_component.dart';

/// Updates entity positions based on their velocity each frame.
/// Also handles boundary clamping for the player.
class MoveSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  Query? _query;

  @override
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<VelocityComponent>(),
    ]);
  }

  @override
  void update(double delta) {
    if (game!.isGameOver) return;

    final screenSize = game!.size;

    for (final entity in _query?.entities ?? <Entity>[]) {
      final pos = entity.get<PositionComponent>()!.position;
      final vel = entity.get<VelocityComponent>()!.data!;
      final tag = entity.get<TagComponent>()?.data;
      final size = entity.get<SizeComponent>()?.size;

      pos.x += vel.x * delta;
      pos.y += vel.y * delta;

      // Clamp player to screen bounds
      if (tag == 'player' && size != null) {
        final halfWidth = size.x / 2;
        final halfHeight = size.y / 2;

        pos.x = pos.x.clamp(halfWidth, screenSize.x - halfWidth);
        pos.y = pos.y.clamp(halfHeight, screenSize.y - halfHeight);
      }
    }
  }
}
