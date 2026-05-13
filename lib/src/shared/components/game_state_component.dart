import 'package:flame_oxygen/flame_oxygen.dart';

class GameState {
  int score = 0;
  bool isGameOver = false;
  bool isStarted = false;
}

class GameStateComponent extends Component<GameState> {
  late GameState state;

  @override
  void init([GameState? data]) {
    state = data ?? GameState();
  }

  @override
  void reset() {
    state = GameState();
  }
}
