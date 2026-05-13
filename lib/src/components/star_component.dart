import 'package:flame_oxygen/flame_oxygen.dart';

class StarComponent extends Component<double> {
  double opacity = 1.0;

  @override
  void init([double? data]) {
    opacity = data ?? 1.0;
  }

  @override
  void reset() {
    opacity = 1.0;
  }
}
