import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/features/render/systems/render_system.dart';
import 'package:test_ecs/src/features/render/systems/hud_system.dart';
import 'package:test_ecs/src/core/game_feature.dart';

class RenderModule extends GameFeature {
  @override
  void register(World world) {
    world.registerSystem(GameRenderSystem());
    world.registerSystem(HudSystem());
  }
}
