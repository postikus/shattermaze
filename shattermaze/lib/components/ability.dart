import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'crystal.dart';

enum AbilityArea { Radius, Line, Target }
enum AbilityEffect { Destroy, Stun, Transform }

class Ability extends Component {
  final String name;
  final int requiredCrystals;
  final CrystalColor requiredColor;
  final AbilityArea area;
  final AbilityEffect effect;
  final double effectRadius;
  
  Ability({
    required this.name,
    required this.requiredCrystals,
    required this.requiredColor,
    required this.area,
    required this.effect,
    this.effectRadius = 1.0,
  });
  
  bool canActivate(int collectedCrystals, CrystalColor color) {
    return collectedCrystals >= requiredCrystals && color == requiredColor;
  }
  
  List<Vector2> getAffectedPositions(Vector2 targetPosition, Vector2 fieldSize) {
    final List<Vector2> positions = [];
    
    switch (area) {
      case AbilityArea.Radius:
        // Get all positions within radius
        for (int x = -effectRadius.toInt(); x <= effectRadius.toInt(); x++) {
          for (int y = -effectRadius.toInt(); y <= effectRadius.toInt(); y++) {
            if (x*x + y*y <= effectRadius*effectRadius) {
              final pos = Vector2(
                targetPosition.x + x,
                targetPosition.y + y,
              );
              
              // Check if position is within field bounds
              if (pos.x >= 0 && pos.x < fieldSize.x && 
                  pos.y >= 0 && pos.y < fieldSize.y) {
                positions.add(pos);
              }
            }
          }
        }
        break;
        
      case AbilityArea.Line:
        // Get all positions in a line (horizontal and vertical)
        for (int x = 0; x < fieldSize.x; x++) {
          positions.add(Vector2(x.toDouble(), targetPosition.y));
        }
        for (int y = 0; y < fieldSize.y; y++) {
          positions.add(Vector2(targetPosition.x, y.toDouble()));
        }
        break;
        
      case AbilityArea.Target:
        // Just the target position
        positions.add(targetPosition);
        break;
    }
    
    return positions;
  }
}
