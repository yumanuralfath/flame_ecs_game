import 'package:flame_oxygen/flame_oxygen.dart';

class CleaningSystem extends System {
  @override
  void init() {}

  @override
  void execute(double dt) {}

  void clearAllEntities() {
    // Oxygen does not allow empty filters in createQuery.
    // We use Has<PositionComponent>() as a catch-all since all our entities have it.
    final query = createQuery([Has<PositionComponent>()]);
    final entities = query.entities.toList();
    for (final entity in entities) {
      world!.entityManager.removeEntity(entity);
    }
  }
}
