import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'my_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shattermaze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: ShattermazeGame(),
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error) => Center(
          child: Text('Error: $error'),
        ),
        overlayBuilderMap: {
          'title': (context, game) {
            return Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Shattermaze',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        },
        initialActiveOverlays: const ['title'],
      ),
    );
  }
}
