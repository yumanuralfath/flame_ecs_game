import 'package:flame_oxygen/flame_oxygen.dart';

/// Simple string tag so system can tell entity types apart.
class TagComponent extends Component<String> {
  String? data;

  @override
  void init([String? data]) {
    this.data = data ?? '';
  }

  @override
  void reset() {
    data = null;
  }
}
