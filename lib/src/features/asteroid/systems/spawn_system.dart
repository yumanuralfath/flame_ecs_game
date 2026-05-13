import 'dart:math';
import 'package:flame/components.dart' hide World, PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';
import 'package:test_ecs/src/features/asteroid/entities/asteroid_entity.dart';

/// Spawns asteroid entities at a rate that increases with the score.
class SpawnSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  final _rng = Random();

  double _timer = 0;
  double _interval = 1.0; 

  @override
  void init() {}

  @override
  void update(double dt) {
    if (game!.isGameOver || !game!.isStarted) {
      _timer = 0;
      _interval = 1.0;
      return;
    }

    _timer += dt;

    // 1. Dynamic Spawn Rate: Interval decreases based on score
    // Starting at 1.0s, reducing down to 0.15s at higher scores
    final scoreIntervalReduction = (game!.score / 500) * 0.5;
    _interval = (1.0 - scoreIntervalReduction).clamp(0.15, 1.0);

    if (_timer >= _interval) {
      _timer = 0;
      _spawnAsteroid();
    }
  }

  void _spawnAsteroid() {
    final screenW = game!.size.x;
    final score = game!.score;

    // ── DIFFICULTY SCALING ───────────────────────────────────────────────
    
    // 2. Dynamic Size: Asteroids get bigger (and more varied) as score increases
    // Base size 32, max bonus +40 at 1000 score.
    final sizeVariation = (score / 25).clamp(0.0, 40.0);
    final baseAsteroidSize = 32.0 + _rng.nextDouble() * sizeVariation;
    
    // 3. Dynamic Speed: Base speed increases with score
    // Base 150, increases by 0.8 per point, plus random variation
    final scoreSpeedBonus = score * 0.8;
    final speedY = 150 + scoreSpeedBonus + _rng.nextDouble() * (200 + score * 0.2);
    
    // More horizontal drift at higher scores
    final speedX = (_rng.nextDouble() - 0.5) * (60 + score * 0.1);

    // ── SPAWNING ─────────────────────────────────────────────────────────

    final x = _rng.nextDouble() * (screenW - baseAsteroidSize) + baseAsteroidSize / 2;

    AsteroidEntity.create(
      world!,
      position: Vector2(x, -baseAsteroidSize),
      size: Vector2(baseAsteroidSize, baseAsteroidSize),
      velocity: Vector2(speedX, speedY),
    );
  }
}
