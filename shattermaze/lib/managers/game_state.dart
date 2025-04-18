import 'package:flutter/material.dart';

enum GameScene { Level, AbilitySelect }

class GameState extends ChangeNotifier {
  int currentLevel = 1;
  int score = 0;
  GameScene currentScene = GameScene.Level;
  bool isLevelCompleted = false;
  
  void completeLevel() {
    isLevelCompleted = true;
    score += 100 * currentLevel;
    currentScene = GameScene.AbilitySelect;
    notifyListeners();
  }
  
  void startNextLevel() {
    currentLevel++;
    isLevelCompleted = false;
    currentScene = GameScene.Level;
    notifyListeners();
  }
  
  void resetGame() {
    currentLevel = 1;
    score = 0;
    isLevelCompleted = false;
    currentScene = GameScene.Level;
    notifyListeners();
  }
}
