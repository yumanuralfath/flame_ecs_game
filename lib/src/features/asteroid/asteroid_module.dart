import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/features/asteroid/systems/spawn_system.dart';
import 'package:test_ecs/src/features/asteroid/systems/collision_system.dart';
import 'package:test_ecs/src/core/game_feature.dart';

class AsteroidModule extends GameFeature {
  @override
  void register(World world) {
    world.registerSystem(SpawnSystem());
    world.registerSystem(CollisionSystem());
  }
}
