import 'dart:math';
import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/asteroid_game.dart';
import 'package:test_ecs/src/entities/asteroid_entity.dart';

/// Spawns asteroid entities at a rate that increases with the score.
class SpawnSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  final _rng = Random();

  double _timer = 0;
  double _interval = 1.5; // seconds between spawns (decreases over time)

  static const double _minInterval = 0.35;
  static const double _asteroidSize = 36;

  @override
  void init() {}

  @override
  void update(double dt) {
    if (game!.isGameOver || !game!.isStarted) {
      // Reset difficulty and timers if game is not active
      _timer = 0;
      _interval = 1.5;
      return;
    }

    _timer += dt;

    // Gradually increase difficulty
    _interval = (_interval - dt * 0.008).clamp(_minInterval, 1.5);

    if (_timer >= _interval) {
      _timer = 0;
      _spawnAsteroid();
    }
  }

  void _spawnAsteroid() {
    final screenW = game!.size.x;

    final x = _rng.nextDouble() * (screenW - _asteroidSize) + _asteroidSize / 2;
    final speedY = 150 + _rng.nextDouble() * 180 + game!.score * 0.5;
    final speedX = (_rng.nextDouble() - 0.5) * 60;

    AsteroidEntity.create(
      world!,
      position: Vector2(x, -_asteroidSize),
      size: Vector2(_asteroidSize, _asteroidSize),
      velocity: Vector2(speedX, speedY),
    );
  }
}
