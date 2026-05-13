import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/features/fx/components/explosion_component.dart';

class ExplosionSystem extends System with UpdateSystem {
  Query? _query;

  @override
  void init() {
    _query = createQuery([
      Has<ExplosionComponent>(),
    ]);
  }

  @override
  void update(double dt) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      final particle = entity.get<ExplosionComponent>()!;
      particle.life -= dt;

      if (particle.life <= 0) {
        world!.entityManager.removeEntity(entity);
      }
    }
  }
}
