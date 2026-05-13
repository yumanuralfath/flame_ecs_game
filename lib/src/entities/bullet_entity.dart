import 'dart:ui';
import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import '../components/color_component.dart';
import '../components/tag_component.dart';
import '../components/velocity_component.dart';
import '../components/bullet_component.dart';

class BulletEntity {
  static void create(
    World world, {
    required Vector2 position,
    required Vector2 velocity,
  }) {
    world.createEntity()
      ..add<PositionComponent, Vector2>(position)
      ..add<VelocityComponent, Vector2>(velocity)
      ..add<SizeComponent, Vector2>(Vector2(8, 8))
      ..add<ColorComponent, Paint>(Paint()..color = const Color(0xFFFFFF00))
      ..add<TagComponent, String>('bullet')
      ..add<BulletComponent, void>();
  }
}
