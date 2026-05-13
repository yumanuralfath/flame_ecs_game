import 'dart:math';
import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';
import 'package:test_ecs/src/shared/components/color_component.dart';
import 'package:test_ecs/src/shared/components/tag_component.dart';
import 'package:test_ecs/src/shared/components/velocity_component.dart';

class AsteroidEntity {
  static final _rng = Random();

  static Entity create(World world, {
    required Vector2 position,
    required Vector2 size,
    required Vector2 velocity,
  }) {
    // Random grey-ish rock colour
    final grey = 120 + _rng.nextInt(80);
    final paint = Paint()
      ..color = Color.fromARGB(255, grey, grey - 20, grey - 40);

    final entity = world.entityManager.createEntity();
    
    entity.add<PositionComponent, Vector2>(position);
    entity.add<SizeComponent, Vector2>(size);
    entity.add<VelocityComponent, Vector2>(velocity);
    entity.add<ColorComponent, Paint>(paint);
    entity.add<TagComponent, String>('asteroid');
    
    return entity;
  }
}
