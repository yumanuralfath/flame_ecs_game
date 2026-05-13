import 'dart:math';
import 'package:flame/components.dart' hide PositionComponent, World;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/services.dart';

import 'package:test_ecs/src/features/player/entities/player_entity.dart';
import 'package:test_ecs/src/features/fx/components/star_component.dart';
import 'package:test_ecs/src/shared/systems/cleaning_system.dart';
import 'package:test_ecs/src/core/game_feature.dart';
import 'package:test_ecs/src/shared/core_module.dart';
import 'package:test_ecs/src/features/asteroid/asteroid_module.dart';
import 'package:test_ecs/src/features/player/player_module.dart';
import 'package:test_ecs/src/features/fx/effects_module.dart';
import 'package:test_ecs/src/features/render/render_module.dart';

class AsteroidGame extends OxygenGame {
  // ── public state ──────────────────────────────────────────────────────
  int score = 0;
  bool isGameOver = false;
  bool isStarted = false;

  late CleaningSystem _cleaningSystem;

  /// Current pointer/touch target the player ship moves toward.
  Vector2? pointerTarget;

  /// Keyboard input state
  final Set<LogicalKeyboardKey> keysPressed = {};

  // ── private ───────────────────────────────────────────────────────────
  final _rng = Random();

  /// List of modular features that define the game's components and systems.
  final List<GameFeature> _features = [
    CoreModule(),
    AsteroidModule(),
    PlayerModule(),
    EffectsModule(),
    RenderModule(),
  ];

  // ── OxygenGame lifecycle ──────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFF05050F);

  @override
  Future<void> init() async {
    _cleaningSystem = CleaningSystem();

    // Initialize all modular features
    for (final feature in _features) {
      feature.register(world);
    }

    // Register cleaning system manually to keep a reference
    world.registerSystem(_cleaningSystem);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnStarEntities();
    overlays.add('MainMenu');
    paused = true;
  }

  // ── helpers ───────────────────────────────────────────────────────────

  void _spawnStarEntities() {
    for (int i = 0; i < 80; i++) {
      world.createEntity()
        ..add<PositionComponent, Vector2>(
          Vector2(_rng.nextDouble() * size.x, _rng.nextDouble() * size.y),
        )
        ..add<SizeComponent, Vector2>(Vector2(0.5 + _rng.nextDouble() * 1.5, 0))
        ..add<StarComponent, double>(0.3 + _rng.nextDouble() * 0.7);
    }
  }

  void spawnPlayer() {
    PlayerEntity.create(
      world,
      position: Vector2(size.x / 2, size.y * 0.75),
      size: Vector2(40, 48),
    );
  }

  // ── public API ────────────────────────────────────────────────────────

  void start() {
    overlays.remove('MainMenu');
    overlays.add('HUD');
    isStarted = true;
    isGameOver = false;
    score = 0;
    paused = false;
    spawnPlayer();
  }

  void pause() {
    if (!isStarted || isGameOver) return;
    paused = true;
    pointerTarget = null;
    overlays.remove('HUD');
    overlays.add('PauseMenu');
  }

  void resume() {
    paused = false;
    overlays.remove('PauseMenu');
    overlays.add('HUD');
  }

  void addScore(int points) => score += points;

  void triggerGameOver() {
    if (isGameOver) return;
    isGameOver = true;
    pointerTarget = null;
    keysPressed.clear();
    overlays.remove('HUD');
    overlays.add('GameOver');
  }

  void restart() {
    overlays.remove('GameOver');
    overlays.remove('PauseMenu');
    overlays.add('HUD');
    isGameOver = false;
    score = 0;
    pointerTarget = null;
    keysPressed.clear();
    paused = false;

    _cleaningSystem.clearAllEntities();
    spawnPlayer();
  }
}
