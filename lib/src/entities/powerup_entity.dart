import 'dart:ui';
import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import '../components/color_component.dart';
import '../components/tag_component.dart';
import '../components/velocity_component.dart';
import '../components/powerup_component.dart';

class PowerUpEntity {
  static void create(
    World world, {
    required Vector2 position,
    required PowerUpType type,
  }) {
    Color color;
    switch (type) {
      case PowerUpType.triple:
        color = const Color(0xFF00FF00);
        break;
      case PowerUpType.rapid:
        color = const Color(0xFF00FFFF);
        break;
      case PowerUpType.plasma:
        color = const Color(0xFFFF00FF); // Magenta for Unique/Plasma
        break;
    }
    
    world.createEntity()
      ..add<PositionComponent, Vector2>(position)
      ..add<VelocityComponent, Vector2>(Vector2(0, 100))
      ..add<SizeComponent, Vector2>(Vector2(30, 30))
      ..add<ColorComponent, Paint>(Paint()..color = color)
      ..add<TagComponent, String>('powerup')
      ..add<PowerUpComponent, PowerUpType>(type);
  }
}
