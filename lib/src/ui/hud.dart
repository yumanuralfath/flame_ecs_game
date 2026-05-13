import 'package:flutter/material.dart';
import 'package:test_ecs/src/core/asteroid_game.dart';

class HUD extends StatelessWidget {
  final AsteroidGame game;
  const HUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: IconButton(
          icon: const Icon(Icons.pause, color: Colors.white70, size: 32),
          onPressed: () {
            game.pause();
          },
        ),
      ),
    );
  }
}
