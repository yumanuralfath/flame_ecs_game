import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';
import 'package:test_ecs/src/shared/components/tag_component.dart';
import 'package:test_ecs/src/features/player/components/powerup_component.dart';

class PowerUpSystem extends System with UpdateSystem, GameRef<AsteroidGame> {
  Query? _powerUpQuery;
  Query? _playerQuery;

  @override
  void init() {
    _powerUpQuery = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<PowerUpComponent>(),
    ]);
    _playerQuery = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      Has<TagComponent>(),
      Has<PlayerStatsComponent>(),
    ]);
  }

  @override
  void update(double dt) {
    if (game!.isGameOver || !game!.isStarted) return;

    final powerUps = _powerUpQuery?.entities.toList() ?? [];
    final player = _playerQuery?.entities.firstWhere(
      (e) => e.get<TagComponent>()?.data == 'player',
      orElse: () => null as dynamic,
    );

    if (player == null) return;

    final pPos = player.get<PositionComponent>()!.position;
    final pSize = player.get<SizeComponent>()!.size;
    final pStats = player.get<PlayerStatsComponent>()!;

    for (final powerUp in powerUps) {
      final puPos = powerUp.get<PositionComponent>()!.position;
      final puSize = powerUp.get<SizeComponent>()!.size;
      final puType = powerUp.get<PowerUpComponent>()!.type;

      // Simple box collision
      final dist = (pPos - puPos).length;
      if (dist < (pSize.x / 2 + puSize.x / 2)) {
        // Collected!
        pStats.activePowerUp = puType;
        pStats.powerUpTimer = 8.0; // Power-up lasts 8 seconds
        world!.entityManager.removeEntity(powerUp);
      }
    }
  }
}
