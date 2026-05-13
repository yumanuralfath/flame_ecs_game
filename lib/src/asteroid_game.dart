import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' hide PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/services.dart';

import 'components/color_component.dart';
import 'components/tag_component.dart';
import 'components/velocity_component.dart';
import 'components/star_component.dart';
import 'components/bullet_component.dart';
import 'components/explosion_component.dart';
import 'components/powerup_component.dart';
import 'entities/player_entity.dart';
import 'systems/bounds_system.dart';
import 'systems/collision_system.dart';
import 'systems/bullet_collision_system.dart';
import 'systems/hud_system.dart';
import 'systems/input_system.dart';
import 'systems/move_system.dart';
import 'systems/render_system.dart';
import 'systems/background_render_system.dart';
import 'systems/spawn_system.dart';
import 'systems/cleaning_system.dart';
import 'systems/explosion_system.dart';
import 'systems/powerup_system.dart';

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

  // ── OxygenGame lifecycle ──────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFF05050F);

  @override
  Future<void> init() async {
    // Register Components
    world.registerComponent<PositionComponent, Vector2>(
      () => PositionComponent(),
    );
    world.registerComponent<SizeComponent, Vector2>(() => SizeComponent());
    world.registerComponent<VelocityComponent, Vector2>(
      () => VelocityComponent(),
    );
    world.registerComponent<ColorComponent, Paint>(() => ColorComponent());
    world.registerComponent<TagComponent, String>(() => TagComponent());
    world.registerComponent<StarComponent, double>(() => StarComponent());
    world.registerComponent<BulletComponent, void>(() => BulletComponent());
    world.registerComponent<ExplosionComponent, double>(() => ExplosionComponent());
    world.registerComponent<PowerUpComponent, PowerUpType>(() => PowerUpComponent());
    world.registerComponent<PlayerStatsComponent, void>(() => PlayerStatsComponent());

    // Register Systems
    _cleaningSystem = CleaningSystem();
    world.registerSystem(_cleaningSystem);
    world.registerSystem(InputSystem());
    world.registerSystem(MoveSystem());
    world.registerSystem(SpawnSystem());
    world.registerSystem(BoundsSystem());
    world.registerSystem(CollisionSystem());
    world.registerSystem(BulletCollisionSystem());
    world.registerSystem(ExplosionSystem());
    world.registerSystem(PowerUpSystem());
    world.registerSystem(BackgroundRenderSystem()); // Render stars first
    world.registerSystem(GameRenderSystem()); // Then game entities
    world.registerSystem(HudSystem()); // Then UI
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
