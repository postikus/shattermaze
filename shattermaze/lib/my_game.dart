import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/crystal.dart';
import 'components/player_character.dart';
import 'managers/pathfinder.dart';

class ShattermazeGame extends FlameGame with TapCallbacks {
  final Vector2 gridSize = Vector2(8, 12);
  late PlayerCharacter player;
  late List<List<Crystal>> crystalGrid;
  late Vector2 cellSize;
  late Pathfinder pathfinder;
  
  // Path information
  List<Vector2> pathPoints = [];
  int playerPathIndex = 0;
  
  @override
  Future<void> onLoad() async {
    // Initialize cell size
    cellSize = Vector2(size.x / gridSize.x, size.y / gridSize.y);
    
    // Initialize pathfinder
    pathfinder = Pathfinder();
    
    // Create crystal grid
    crystalGrid = List.generate(
      gridSize.y.toInt(),
      (y) => List.generate(
        gridSize.x.toInt(),
        (x) => Crystal(
          color: CrystalColor.values[(x + y) % CrystalColor.values.length],
          isPartOfPath: false, // Will be set later
          position: Vector2(x * cellSize.x, y * cellSize.y),
          size: cellSize,
        ),
      ),
    );
    
    // Generate path
    _generatePath();
    
    // Add crystals to game
    for (int y = 0; y < gridSize.y; y++) {
      for (int x = 0; x < gridSize.x; x++) {
        add(crystalGrid[y][x]);
      }
    }
    
    // Create player at path start
    final pathPos = pathPoints[playerPathIndex];
    player = PlayerCharacter(
      playerClass: PlayerClass.Warrior,
      position: Vector2(pathPos.x * cellSize.x, pathPos.y * cellSize.y),
      size: cellSize * 0.8,
    );
    
    add(player);
  }
  
  void _generatePath() {
    // Clear existing path
    pathPoints.clear();
    
    // Start at bottom center
    int x = (gridSize.x / 2).floor();
    int y = gridSize.y.toInt() - 1;
    
    // Add starting point
    pathPoints.add(Vector2(x.toDouble(), y.toDouble()));
    crystalGrid[y][x].isPartOfPath = true;
    
    // Generate winding path to top
    while (y > 0) {
      // Decide direction: 0 = left, 1 = right, 2 = up
      int direction;
      
      // Force upward movement occasionally to ensure progress
      if (y > gridSize.y * 0.7 && pathPoints.length % 5 == 0) {
        direction = 2; // Go up
      } else {
        direction = (x <= 1) ? 1 : (x >= gridSize.x - 2) ? 0 : (pathPoints.length % 3);
      }
      
      // Move in the chosen direction
      switch (direction) {
        case 0: // Left
          x = (x - 1).clamp(0, gridSize.x.toInt() - 1);
          break;
        case 1: // Right
          x = (x + 1).clamp(0, gridSize.x.toInt() - 1);
          break;
        case 2: // Up
          y = (y - 1).clamp(0, gridSize.y.toInt() - 1);
          break;
      }
      
      // Add point to path
      final newPoint = Vector2(x.toDouble(), y.toDouble());
      
      // Check if this point is already in the path (avoid loops)
      if (!pathPoints.any((point) => point.x == newPoint.x && point.y == newPoint.y)) {
        pathPoints.add(newPoint);
        crystalGrid[y][x].isPartOfPath = true;
      }
    }
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    // Convert tap position to grid coordinates
    final touchPosition = event.canvasPosition;
    final gridX = (touchPosition.x / cellSize.x).floor();
    final gridY = (touchPosition.y / cellSize.y).floor();
    
    // Check if tap is within grid bounds
    if (gridX >= 0 && gridX < gridSize.x && gridY >= 0 && gridY < gridSize.y) {
      _handleCrystalTap(gridX, gridY);
    }
  }
  
  void _handleCrystalTap(int x, int y) {
    // Find matches
    final matches = _findMatches(x, y);
    
    if (matches.length >= 3) {
      // Process matches
      bool pathCleared = false;
      
      for (final match in matches) {
        final matchX = match.x.toInt();
        final matchY = match.y.toInt();
        
        // Check if matched crystal is part of path
        if (crystalGrid[matchY][matchX].isPartOfPath) {
          pathCleared = true;
        }
        
        // Charge player ability
        player.chargeAbility(0.2);
        
        // Replace crystal
        _replaceCrystal(matchX, matchY);
      }
      
      // Move player if path was cleared
      if (pathCleared) {
        _movePlayerAlongPath();
      }
    }
  }
  
  List<Vector2> _findMatches(int x, int y) {
    final List<Vector2> matches = [];
    final targetColor = crystalGrid[y][x].color;
    
    // Check horizontal matches
    List<Vector2> horizontalMatches = [];
    for (int i = x; i >= 0 && crystalGrid[y][i].color == targetColor; i--) {
      horizontalMatches.add(Vector2(i.toDouble(), y.toDouble()));
    }
    for (int i = x + 1; i < gridSize.x && crystalGrid[y][i].color == targetColor; i++) {
      horizontalMatches.add(Vector2(i.toDouble(), y.toDouble()));
    }
    
    // Check vertical matches
    List<Vector2> verticalMatches = [];
    for (int j = y; j >= 0 && crystalGrid[j][x].color == targetColor; j--) {
      verticalMatches.add(Vector2(x.toDouble(), j.toDouble()));
    }
    for (int j = y + 1; j < gridSize.y && crystalGrid[j][x].color == targetColor; j++) {
      verticalMatches.add(Vector2(x.toDouble(), j.toDouble()));
    }
    
    // Add matches if they form a group of 3 or more
    if (horizontalMatches.length >= 3) matches.addAll(horizontalMatches);
    if (verticalMatches.length >= 3) matches.addAll(verticalMatches);
    
    return matches;
  }
  
  void _replaceCrystal(int x, int y) {
    // Remove old crystal
    final oldCrystal = crystalGrid[y][x];
    final isPath = oldCrystal.isPartOfPath;
    remove(oldCrystal);
    
    // Create new crystal with random color
    final newCrystal = Crystal(
      color: CrystalColor.values[x % CrystalColor.values.length],
      isPartOfPath: isPath,
      position: Vector2(x * cellSize.x, y * cellSize.y),
      size: cellSize,
    );
    
    // Update grid and add to scene
    crystalGrid[y][x] = newCrystal;
    add(newCrystal);
  }
  
  void _movePlayerAlongPath() {
    // Move to next position on path if not at end
    if (playerPathIndex < pathPoints.length - 1) {
      playerPathIndex++;
      final pathPos = pathPoints[playerPathIndex];
      player.move(Vector2(pathPos.x * cellSize.x, pathPos.y * cellSize.y));
      
      // Check if player reached the end of the path
      if (playerPathIndex == pathPoints.length - 1) {
        print('Level completed!');
        // In a full implementation, we would transition to the ability select screen
        _showLevelCompletedEffect();
      }
    }
  }
  
  void _showLevelCompletedEffect() {
    // Visual effect for level completion
    // In a full implementation, this would trigger the transition to the ability select screen
    // For now, we'll just add a visual effect
    
    // Create a flash effect
    final flashEffect = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = Colors.white.withOpacity(0.7),
    );
    
    add(flashEffect);
    
    // Remove the flash effect after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (flashEffect.isMounted) {
        remove(flashEffect);
      }
    });
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update player character
    player.update(dt);
  }
}
