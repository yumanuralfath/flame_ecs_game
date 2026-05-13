import 'dart:ui';
import 'package:flame_oxygen/flame_oxygen.dart';
import '../components/star_component.dart';

class BackgroundRenderSystem extends System with RenderSystem {
  Query? _starQuery;
  final _paint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  void init() {
    _starQuery = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<StarComponent>(),
    ]);
  }

  @override
  void render(Canvas canvas) {
    for (final entity in _starQuery?.entities ?? <Entity>[]) {
      final pos = entity.get<PositionComponent>()!.position;
      final size = entity.get<SizeComponent>()!.size;
      final opacity = entity.get<StarComponent>()!.opacity;

      _paint.color = Color.fromRGBO(255, 255, 255, opacity);
      canvas.drawCircle(Offset(pos.x, pos.y), size.x, _paint);
    }
  }
}
