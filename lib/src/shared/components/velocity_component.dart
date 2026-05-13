import "package:flame/game.dart";
import "package:flame_oxygen/flame_oxygen.dart";

/// Store the velocity (units / second) of an entity.
class VelocityComponent extends Component<Vector2> {
  Vector2? data;

  @override
  void init([Vector2? data]) {
    this.data = data ?? Vector2.zero();
  }

  @override
  void reset() {
    data = null;
  }
}
