import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/features/player/components/bullet_component.dart';
import 'package:test_ecs/src/features/player/components/powerup_component.dart';
import 'package:test_ecs/src/features/player/systems/input_system.dart';
import 'package:test_ecs/src/features/player/systems/bullet_collision_system.dart';
import 'package:test_ecs/src/features/player/systems/powerup_system.dart';
import 'package:test_ecs/src/core/game_feature.dart';

class PlayerModule extends GameFeature {
  @override
  void register(World world) {
    world.registerComponent<BulletComponent, void>(() => BulletComponent());
    world.registerComponent<PowerUpComponent, PowerUpType>(() => PowerUpComponent());
    world.registerComponent<PlayerStatsComponent, void>(() => PlayerStatsComponent());

    world.registerSystem(InputSystem());
    world.registerSystem(BulletCollisionSystem());
    world.registerSystem(PowerUpSystem());
  }
}
