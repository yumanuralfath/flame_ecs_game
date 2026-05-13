import 'package:flutter/material.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';

class GameOverMenu extends StatelessWidget {
  final AsteroidGame game;
  final VoidCallback onRestart;
  const GameOverMenu({super.key, required this.game, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 56,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: ${game.score}',
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
