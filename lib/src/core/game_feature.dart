import 'package:flame_oxygen/flame_oxygen.dart';

abstract class GameFeature {
  /// Register components and systems for this feature.
  void register(World world);

  /// Optional: Handle initialization logic for the feature.
  Future<void> onLoad(World world) async {}
}
