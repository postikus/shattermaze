import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../components/crystal.dart';
import '../components/player_character.dart';
import '../managers/game_state.dart';
import '../managers/level_generator.dart';
import '../managers/pathfinder.dart';

class LevelScene extends Component with HasGameRef {
  late GameState gameState;
  late LevelGenerator levelGenerator;
  late Pathfinder pathfinder;
  late List<List<Crystal>> crystalGrid;
  late PlayerCharacter player;
  
  final Vector2 gridSize;
  final Vector2 cellSize;
  
  LevelScene({
    required this.gridSize,
    required this.cellSize,
  });
  
  @override
  Future<void> onLoad() async {
    gameState = GameState();
    levelGenerator = LevelGenerator(gridSize: gridSize);
    pathfinder = Pathfinder();
    
    // Generate level
    final levelData = levelGenerator.generateLevel();
    crystalGrid = levelData.crystalGrid;
    
    // Add crystals to scene
    for (int y = 0; y < gridSize.y; y++) {
      for (int x = 0; x < gridSize.x; x++) {
        final crystal = crystalGrid[y][x];
        crystal.position = Vector2(x * cellSize.x, y * cellSize.y);
        crystal.size = cellSize;
        add(crystal);
      }
    }
    
    // Create player at path start
    final startPosition = levelData.pathStart;
    player = PlayerCharacter(
      playerClass: PlayerClass.Warrior,
      position: Vector2(
        startPosition.x * cellSize.x,
        startPosition.y * cellSize.y,
      ),
      size: cellSize * 0.8,
    );
    add(player);
  }
  
  void handleTap(Vector2 position) {
    final touchPosition = position;
    final gridX = (touchPosition.x / cellSize.x).floor();
    final gridY = (touchPosition.y / cellSize.y).floor();
    
    // Check if tap is within grid bounds
    if (gridX >= 0 && gridX < gridSize.x && gridY >= 0 && gridY < gridSize.y) {
      handleCrystalTap(gridX, gridY);
    }
  }
  
  void handleCrystalTap(int x, int y) {
    // Check for match-3
    final matches = findMatches(x, y);
    
    if (matches.length >= 3) {
      // Remove matched crystals
      for (final match in matches) {
        final crystal = crystalGrid[match.y.toInt()][match.x.toInt()];
        if (crystal.isPartOfPath) {
          // Move player if path is cleared
          movePlayerAlongPath();
        }
        
        // Charge ability based on crystal color
        player.chargeAbility(0.2);
        
        // Replace crystal
        replaceCrystal(match.x.toInt(), match.y.toInt());
      }
    }
  }
  
  List<Vector2> findMatches(int x, int y) {
    // Simplified match-3 logic
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
  
  void replaceCrystal(int x, int y) {
    // Remove old crystal
    final oldCrystal = crystalGrid[y][x];
    remove(oldCrystal);
    
    // Create new crystal
    final newCrystal = Crystal(
      color: CrystalColor.values[levelGenerator.random.nextInt(CrystalColor.values.length)],
      isPartOfPath: oldCrystal.isPartOfPath,
      position: Vector2(x * cellSize.x, y * cellSize.y),
      size: cellSize,
    );
    
    // Update grid and add to scene
    crystalGrid[y][x] = newCrystal;
    add(newCrystal);
  }
  
  void movePlayerAlongPath() {
    // Find next position on path
    final nextPosition = pathfinder.getNextPosition(
      player.position / cellSize,
      levelGenerator.pathMap,
    );
    
    if (nextPosition != null) {
      player.move(nextPosition * cellSize);
      
      // Check if player reached the end
      if (nextPosition.y == 0) {
        gameState.completeLevel();
      }
    }
  }
}
