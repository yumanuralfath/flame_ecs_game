import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' hide PositionComponent;
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/services.dart';

import 'components/color_component.dart';
import 'components/tag_component.dart';
import 'components/velocity_component.dart';
import 'entities/player_entity.dart';
import 'systems/bounds_system.dart';
import 'systems/collision_system.dart';
import 'systems/hud_system.dart';
import 'systems/input_system.dart';
import 'systems/move_system.dart';
import 'systems/render_system.dart';
import 'systems/spawn_system.dart';
import 'systems/cleaning_system.dart';

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
  final _stars = <_Star>[];
  final _rng = Random();
  final _starPaint = Paint()..color = const Color(0xFFFFFFFF);

  // ── OxygenGame lifecycle ──────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFF05050F);

  @override
  Future<void> init() async {
    world.registerComponent<PositionComponent, Vector2>(
      () => PositionComponent(),
    );
    world.registerComponent<SizeComponent, Vector2>(() => SizeComponent());
    world.registerComponent<VelocityComponent, Vector2>(
      () => VelocityComponent(),
    );
    world.registerComponent<ColorComponent, Paint>(() => ColorComponent());
    world.registerComponent<TagComponent, String>(() => TagComponent());

    _cleaningSystem = CleaningSystem();
    world.registerSystem(_cleaningSystem);
    world.registerSystem(InputSystem());
    world.registerSystem(MoveSystem());
    world.registerSystem(SpawnSystem());
    world.registerSystem(BoundsSystem());
    world.registerSystem(CollisionSystem());
    world.registerSystem(GameRenderSystem());
    world.registerSystem(HudSystem());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnStars();
    overlays.add('MainMenu');
    paused = true;
  }

  // ── helpers ───────────────────────────────────────────────────────────

  void _spawnStars() {
    _stars.clear();
    for (int i = 0; i < 80; i++) {
      _stars.add(
        _Star(
          x: _rng.nextDouble() * size.x,
          y: _rng.nextDouble() * size.y,
          radius: 0.5 + _rng.nextDouble() * 1.5,
          opacity: 0.3 + _rng.nextDouble() * 0.7,
        ),
      );
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
    pointerTarget = null; // Clear pointer target on pause
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

  @override
  void render(Canvas canvas) {
    for (final star in _stars) {
      _starPaint.color = Color.fromRGBO(255, 255, 255, star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.radius, _starPaint);
    }
    super.render(canvas);
  }
}

class _Star {
  final double x, y, radius, opacity;
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}
