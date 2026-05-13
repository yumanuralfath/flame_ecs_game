import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';
import '../components/color_component.dart';
import '../components/tag_component.dart';
import '../components/velocity_component.dart';
import '../components/powerup_component.dart';

class PlayerEntity {
  static Entity create(World world, {required Vector2 position, required Vector2 size}) {
    final entity = world.entityManager.createEntity();
    
    entity.add<PositionComponent, Vector2>(position);
    entity.add<SizeComponent, Vector2>(size);
    entity.add<VelocityComponent, Vector2>(Vector2.zero());
    entity.add<ColorComponent, Paint>(Paint()..color = const Color(0xFF44AAFF));
    entity.add<TagComponent, String>('player');
    entity.add<PlayerStatsComponent, void>();
    
    return entity;
  }
}
