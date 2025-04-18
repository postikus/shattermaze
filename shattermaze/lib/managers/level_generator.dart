import 'dart:math';
import 'package:flame/components.dart';
import '../components/crystal.dart';

class LevelData {
  final List<List<Crystal>> crystalGrid;
  final List<Vector2> pathMap;
  final Vector2 pathStart;
  final Vector2 pathEnd;
  
  LevelData({
    required this.crystalGrid,
    required this.pathMap,
    required this.pathStart,
    required this.pathEnd,
  });
}

class LevelGenerator {
  final Vector2 gridSize;
  final Random random = Random();
  
  LevelGenerator({
    required this.gridSize,
  });
  
  LevelData generateLevel() {
    // Create empty crystal grid
    final List<List<Crystal>> crystalGrid = List.generate(
      gridSize.y.toInt(),
      (y) => List.generate(
        gridSize.x.toInt(),
        (x) => Crystal(
          color: CrystalColor.values[random.nextInt(CrystalColor.values.length)],
          position: Vector2(x.toDouble(), y.toDouble()),
          size: Vector2(1, 1),
        ),
      ),
    );
    
    // Generate winding path
    final List<Vector2> pathMap = _generatePath();
    
    // Mark crystals on path
    for (final pathPos in pathMap) {
      final x = pathPos.x.toInt();
      final y = pathPos.y.toInt();
      
      if (x >= 0 && x < gridSize.x && y >= 0 && y < gridSize.y) {
        crystalGrid[y][x] = Crystal(
          color: CrystalColor.values[random.nextInt(CrystalColor.values.length)],
          isPartOfPath: true,
          position: Vector2(x.toDouble(), y.toDouble()),
          size: Vector2(1, 1),
        );
      }
    }
    
    return LevelData(
      crystalGrid: crystalGrid,
      pathMap: pathMap,
      pathStart: pathMap.first,
      pathEnd: pathMap.last,
    );
  }
  
  List<Vector2> _generatePath() {
    final List<Vector2> path = [];
    
    // Start from bottom center
    int x = (gridSize.x / 2).floor();
    int y = gridSize.y.toInt() - 1;
    
    path.add(Vector2(x.toDouble(), y.toDouble()));
    
    // Generate winding path to top
    while (y > 0) {
      // Decide direction: 0 = left, 1 = right, 2 = up
      int direction;
      
      if (x <= 1) {
        // Too close to left edge, can only go right or up
        direction = random.nextInt(2) + 1;
      } else if (x >= gridSize.x - 2) {
        // Too close to right edge, can only go left or up
        direction = random.nextInt(2);
        if (direction == 1) direction = 2; // Convert right to up
      } else {
        // Can go in any direction
        direction = random.nextInt(3);
      }
      
      switch (direction) {
        case 0: // Left
          x--;
          break;
        case 1: // Right
          x++;
          break;
        case 2: // Up
          y--;
          break;
      }
      
      path.add(Vector2(x.toDouble(), y.toDouble()));
      
      // Occasionally force an upward movement to ensure progress
      if (random.nextDouble() < 0.3) {
        y--;
        path.add(Vector2(x.toDouble(), y.toDouble()));
      }
    }
    
    return path;
  }
}
