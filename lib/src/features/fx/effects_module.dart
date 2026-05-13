import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/features/fx/components/explosion_component.dart';
import 'package:test_ecs/src/features/fx/components/star_component.dart';
import 'package:test_ecs/src/features/fx/systems/explosion_system.dart';
import 'package:test_ecs/src/features/fx/systems/background_render_system.dart';
import 'package:test_ecs/src/core/game_feature.dart';

class EffectsModule extends GameFeature {
  @override
  void register(World world) {
    world.registerComponent<ExplosionComponent, double>(() => ExplosionComponent());
    world.registerComponent<StarComponent, double>(() => StarComponent());

    world.registerSystem(ExplosionSystem());
    world.registerSystem(BackgroundRenderSystem());
  }
}
