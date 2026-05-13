import 'package:flame_oxygen/flame_oxygen.dart';

class ExplosionComponent extends Component<double> {
  double life = 1.0;
  double totalLife = 1.0;

  @override
  void init([double? data]) {
    life = data ?? 1.0;
    totalLife = life;
  }

  @override
  void reset() {
    life = 1.0;
    totalLife = 1.0;
  }
}
