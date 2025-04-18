import 'dart:math' as math;
import 'package:flame/components.dart';

class Pathfinder {
  // Get the next position on the path
  Vector2? getNextPosition(Vector2 currentPosition, List<Vector2> pathMap) {
    // Find current position in path
    int currentIndex = -1;
    
    for (int i = 0; i < pathMap.length; i++) {
      if (pathMap[i].x == currentPosition.x && pathMap[i].y == currentPosition.y) {
        currentIndex = i;
        break;
      }
    }
    
    // If current position is on path, return next position
    if (currentIndex >= 0 && currentIndex < pathMap.length - 1) {
      return pathMap[currentIndex + 1];
    }
    
    // If not on path, find closest path position
    if (currentIndex == -1) {
      double minDistance = double.infinity;
      int closestIndex = -1;
      
      for (int i = 0; i < pathMap.length; i++) {
        final distance = (pathMap[i] - currentPosition).length;
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }
      
      // Return next position if found
      if (closestIndex >= 0 && closestIndex < pathMap.length - 1) {
        return pathMap[closestIndex + 1];
      }
    }
    
    // No valid next position
    return null;
  }
  
  // Find a path between two positions
  List<Vector2> findPath(Vector2 start, Vector2 end, List<Vector2> pathMap) {
    // Find start and end positions in path
    int startIndex = -1;
    int endIndex = -1;
    
    for (int i = 0; i < pathMap.length; i++) {
      if (pathMap[i].x == start.x && pathMap[i].y == start.y) {
        startIndex = i;
      }
      if (pathMap[i].x == end.x && pathMap[i].y == end.y) {
        endIndex = i;
      }
    }
    
    // If both positions are on path, return subpath
    if (startIndex >= 0 && endIndex >= 0) {
      if (startIndex <= endIndex) {
        return pathMap.sublist(startIndex, endIndex + 1);
      } else {
        // Path goes backwards
        final reversePath = pathMap.sublist(endIndex, startIndex + 1).reversed.toList();
        return reversePath;
      }
    }
    
    // If not both on path, return empty list
    return [];
  }
  
  // Generate a smooth path between points for animation
  List<Vector2> generateSmoothPath(List<Vector2> pathPoints, int subdivisions) {
    if (pathPoints.length < 2) return pathPoints;
    
    final smoothPath = <Vector2>[];
    
    for (int i = 0; i < pathPoints.length - 1; i++) {
      final start = pathPoints[i];
      final end = pathPoints[i + 1];
      
      // Add start point
      smoothPath.add(start);
      
      // Add intermediate points
      for (int j = 1; j < subdivisions; j++) {
        final t = j / subdivisions;
        final intermediate = start + (end - start) * t;
        smoothPath.add(intermediate);
      }
    }
    
    // Add final point
    smoothPath.add(pathPoints.last);
    
    return smoothPath;
  }
  
  // Check if a position is on the path
  bool isOnPath(Vector2 position, List<Vector2> pathMap, {double tolerance = 0.1}) {
    for (final pathPoint in pathMap) {
      if ((pathPoint - position).length <= tolerance) {
        return true;
      }
    }
    return false;
  }
  
  // Find the nearest path point
  Vector2? findNearestPathPoint(Vector2 position, List<Vector2> pathMap) {
    if (pathMap.isEmpty) return null;
    
    Vector2 nearest = pathMap.first;
    double minDistance = (nearest - position).length;
    
    for (final point in pathMap) {
      final distance = (point - position).length;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }
    
    return nearest;
  }
  
  // Calculate path length
  double calculatePathLength(List<Vector2> pathMap) {
    double length = 0;
    
    for (int i = 0; i < pathMap.length - 1; i++) {
      length += (pathMap[i + 1] - pathMap[i]).length;
    }
    
    return length;
  }
}
