import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ability.dart';

enum PlayerClass { Warrior, Archer }
enum PlayerStatus { Waiting, Moving }

class PlayerCharacter extends PositionComponent {
  PlayerClass playerClass;
  Ability? currentAbility;
  double abilityChargeLevel = 0.0;
  PlayerStatus status;
  
  // Movement animation properties
  Vector2? targetPosition;
  double moveSpeed = 300.0; // Pixels per second
  double bounceHeight = 10.0; // Bounce height in pixels
  double bounceFrequency = 5.0; // Bounces per second
  double movementTime = 0.0; // Time elapsed during movement
  
  // Visual effects
  double pulseAmount = 0.0;
  double pulseSpeed = 3.0;
  
  PlayerCharacter({
    required this.playerClass,
    this.status = PlayerStatus.Waiting,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);
  
  void chargeAbility(double amount) {
    abilityChargeLevel = (abilityChargeLevel + amount).clamp(0.0, 1.0);
    
    // Add pulse effect when charging
    pulseAmount = 1.0;
  }
  
  bool canUseAbility() {
    return currentAbility != null && abilityChargeLevel >= 1.0;
  }
  
  void useAbility() {
    if (canUseAbility()) {
      // Ability usage logic will be implemented here
      abilityChargeLevel = 0.0;
    }
  }
  
  void move(Vector2 newPosition) {
    if (position == newPosition) return;
    
    status = PlayerStatus.Moving;
    targetPosition = newPosition;
    movementTime = 0.0;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update pulse effect
    if (pulseAmount > 0) {
      pulseAmount = math.max(0, pulseAmount - dt * pulseSpeed);
    }
    
    // Handle movement animation
    if (status == PlayerStatus.Moving && targetPosition != null) {
      movementTime += dt;
      
      // Calculate movement progress
      final distance = targetPosition! - position;
      final totalDistance = distance.length;
      final moveDistance = moveSpeed * dt;
      
      if (moveDistance >= totalDistance) {
        // Reached target position
        position = targetPosition!;
        targetPosition = null;
        status = PlayerStatus.Waiting;
      } else {
        // Move towards target
        final direction = distance.normalized();
        position += direction * moveDistance;
        
        // Add bouncing effect during movement
        // This doesn't affect the actual path, just the visual rendering
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    canvas.save();
    
    // Apply bounce effect if moving
    if (status == PlayerStatus.Moving) {
      final bounceOffset = math.sin(movementTime * bounceFrequency * math.pi * 2) * bounceHeight;
      canvas.translate(0, bounceOffset);
    }
    
    // Apply pulse effect when charging ability
    final scale = 1.0 + pulseAmount * 0.2;
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scale, scale);
    canvas.translate(-size.x / 2, -size.y / 2);
    
    // Draw character shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2 + 2),
      size.x / 2 * 0.9,
      shadowPaint
    );
    
    // Draw player character
    final paint = Paint()
      ..color = playerClass == PlayerClass.Warrior ? Colors.red : Colors.green
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint
    );
    
    // Draw character details
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Draw eyes
    final eyeSize = size.x * 0.15;
    final eyeOffset = size.x * 0.15;
    canvas.drawCircle(
      Offset(size.x / 2 - eyeOffset, size.y / 2 - eyeOffset),
      eyeSize,
      detailPaint
    );
    canvas.drawCircle(
      Offset(size.x / 2 + eyeOffset, size.y / 2 - eyeOffset),
      eyeSize,
      detailPaint
    );
    
    // Draw ability charge indicator
    if (abilityChargeLevel > 0) {
      final chargePaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      final startAngle = -90 * (math.pi / 180); // Start from top
      final sweepAngle = 360 * abilityChargeLevel * (math.pi / 180);
      
      canvas.drawArc(rect, startAngle, sweepAngle, false, chargePaint);
    }
    
    canvas.restore();
  }
}
