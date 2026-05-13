import 'package:flame/components.dart' hide PositionComponent, World;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';
import 'package:test_ecs/src/shared/components/color_component.dart';
import 'package:test_ecs/src/shared/components/game_state_component.dart';
import 'package:test_ecs/src/shared/components/tag_component.dart';
import 'package:test_ecs/src/shared/components/velocity_component.dart';
import 'package:test_ecs/src/shared/systems/bounds_system.dart';
import 'package:test_ecs/src/shared/systems/move_system.dart';
import 'package:test_ecs/src/core/game_feature.dart';

class CoreModule extends GameFeature {
  @override
  void register(World world) {
    // Basic Components
    world.registerComponent<PositionComponent, Vector2>(() => PositionComponent());
    world.registerComponent<SizeComponent, Vector2>(() => SizeComponent());
    world.registerComponent<VelocityComponent, Vector2>(() => VelocityComponent());
    world.registerComponent<ColorComponent, Paint>(() => ColorComponent());
    world.registerComponent<TagComponent, String>(() => TagComponent());
    world.registerComponent<GameStateComponent, GameState>(() => GameStateComponent());

    // Basic Systems
    world.registerSystem(MoveSystem());
    world.registerSystem(BoundsSystem());
  }
}
