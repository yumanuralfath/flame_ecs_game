import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/features/fx/components/star_component.dart';

class CleaningSystem extends System {
  @override
  void init() {}

  @override
  void execute(double dt) {}

  void clearAllEntities() {
    // We only want to clear gameplay entities, not the background stars.
    // So we query for entities that DON'T have a StarComponent.
    final query = createQuery([
      Has<PositionComponent>(),
      HasNot<StarComponent>(),
    ]);

    final entities = query.entities.toList();
    for (final entity in entities) {
      world!.entityManager.removeEntity(entity);
    }
  }
}
