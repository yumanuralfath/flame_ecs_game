import 'package:flutter/material.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';

class MainMenu extends StatelessWidget {
  final AsteroidGame game;
  final VoidCallback onStart;
  const MainMenu({super.key, required this.game, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ASTEROID DODGER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Use WASD / Arrows to Move\nor Drag to Dodge',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'START GAME',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
