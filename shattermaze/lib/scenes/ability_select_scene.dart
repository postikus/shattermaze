import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../components/ability.dart';
import '../components/crystal.dart';
import '../components/player_character.dart';
import '../managers/game_state.dart';

class AbilitySelectScene extends Component with HasGameRef {
  final GameState gameState;
  final PlayerCharacter player;
  final List<Ability> availableAbilities = [];
  
  AbilitySelectScene({
    required this.gameState,
    required this.player,
  });
  
  @override
  Future<void> onLoad() async {
    // Generate random abilities to choose from
    generateAbilities();
    
    // Position abilities on screen
    positionAbilities();
  }
  
  void generateAbilities() {
    // Clear previous abilities
    availableAbilities.clear();
    
    // Create new random abilities
    availableAbilities.add(
      Ability(
        name: 'Fireball',
        requiredCrystals: 5,
        requiredColor: CrystalColor.Red,
        area: AbilityArea.Radius,
        effect: AbilityEffect.Destroy,
        effectRadius: 2.0,
      ),
    );
    
    availableAbilities.add(
      Ability(
        name: 'Ice Beam',
        requiredCrystals: 4,
        requiredColor: CrystalColor.Blue,
        area: AbilityArea.Line,
        effect: AbilityEffect.Stun,
      ),
    );
    
    availableAbilities.add(
      Ability(
        name: 'Nature\'s Touch',
        requiredCrystals: 3,
        requiredColor: CrystalColor.Green,
        area: AbilityArea.Target,
        effect: AbilityEffect.Transform,
      ),
    );
  }
  
  void positionAbilities() {
    final screenSize = gameRef.size;
    final abilityWidth = screenSize.x * 0.8;
    final abilityHeight = screenSize.y * 0.2;
    final spacing = screenSize.y * 0.05;
    
    for (int i = 0; i < availableAbilities.length; i++) {
      final abilityComponent = AbilityCard(
        ability: availableAbilities[i],
        position: Vector2(
          screenSize.x * 0.1,
          screenSize.y * 0.2 + (abilityHeight + spacing) * i,
        ),
        size: Vector2(abilityWidth, abilityHeight),
        onSelected: () => selectAbility(i),
      );
      
      add(abilityComponent);
    }
  }
  
  void selectAbility(int index) {
    if (index >= 0 && index < availableAbilities.length) {
      // Assign ability to player
      player.currentAbility = availableAbilities[index];
      
      // Continue to next level
      gameState.startNextLevel();
    }
  }
}

class AbilityCard extends PositionComponent {
  final Ability ability;
  final Function onSelected;
  
  AbilityCard({
    required this.ability,
    required this.onSelected,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);
  
  @override
  void render(Canvas canvas) {
    // Draw card background
    final bgPaint = Paint()
      ..color = Colors.blueGrey.shade800
      ..style = PaintingStyle.fill;
    
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, Radius.circular(10)),
      bgPaint,
    );
    
    // Draw border
    final borderPaint = Paint()
      ..color = _getColorForCrystalType(ability.requiredColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, Radius.circular(10)),
      borderPaint,
    );
    
    // Draw ability name
    final textSpan = TextSpan(
      text: ability.name,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout(maxWidth: size.x - 20);
    textPainter.paint(
      canvas,
      Offset(10, 10),
    );
    
    // Draw ability description
    final descriptionSpan = TextSpan(
      text: '${ability.requiredCrystals} ${ability.requiredColor} crystals\n'
            '${_getAreaDescription(ability.area)}\n'
            '${_getEffectDescription(ability.effect)}',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
    
    final descriptionPainter = TextPainter(
      text: descriptionSpan,
      textDirection: TextDirection.ltr,
    );
    
    descriptionPainter.layout(maxWidth: size.x - 20);
    descriptionPainter.paint(
      canvas,
      Offset(10, 50),
    );
  }
  
  void handleTap() {
    onSelected();
  }
  
  Color _getColorForCrystalType(CrystalColor color) {
    switch (color) {
      case CrystalColor.Red:
        return Colors.red;
      case CrystalColor.Green:
        return Colors.green;
      case CrystalColor.Blue:
        return Colors.blue;
      case CrystalColor.Yellow:
        return Colors.yellow;
      case CrystalColor.Purple:
        return Colors.purple;
    }
  }
  
  String _getAreaDescription(AbilityArea area) {
    switch (area) {
      case AbilityArea.Radius:
        return 'Area: Radius ${ability.effectRadius.toInt()}';
      case AbilityArea.Line:
        return 'Area: Line';
      case AbilityArea.Target:
        return 'Area: Single Target';
    }
  }
  
  String _getEffectDescription(AbilityEffect effect) {
    switch (effect) {
      case AbilityEffect.Destroy:
        return 'Effect: Destroy crystals';
      case AbilityEffect.Stun:
        return 'Effect: Stun enemies';
      case AbilityEffect.Transform:
        return 'Effect: Transform crystals';
    }
  }
}
