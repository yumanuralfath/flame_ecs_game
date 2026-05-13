import 'package:flame_oxygen/flame_oxygen.dart';

enum PowerUpType { triple, rapid, plasma }

class PowerUpComponent extends Component<PowerUpType> {
  PowerUpType type = PowerUpType.triple;

  @override
  void init([PowerUpType? data]) {
    type = data ?? PowerUpType.triple;
  }

  @override
  void reset() {
    type = PowerUpType.triple;
  }
}

class PlayerStatsComponent extends Component<void> {
  PowerUpType? activePowerUp;
  double powerUpTimer = 0;

  @override
  void init([void data]) {
    activePowerUp = null;
    powerUpTimer = 0;
  }

  @override
  void reset() {
    activePowerUp = null;
    powerUpTimer = 0;
  }
}
