import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum CrystalColor { Red, Green, Blue, Yellow, Purple }
enum CrystalType { Normal, Special }

class Crystal extends PositionComponent {
  final CrystalColor color;
  final CrystalType type;
  bool isPartOfPath; // Changed from final to mutable
  
  Crystal({
    required this.color,
    this.type = CrystalType.Normal,
    this.isPartOfPath = false,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);
  
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _getColorFromEnum(color)
      ..style = PaintingStyle.fill;
    
    // Draw crystal shape
    canvas.drawRect(size.toRect(), paint);
    
    // Add border for path crystals
    if (isPartOfPath) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(size.toRect(), borderPaint);
    }
    
    // Add special effect for special crystals
    if (type == CrystalType.Special) {
      final specialPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      final specialRect = Rect.fromCenter(
        center: size.toRect().center,
        width: size.x * 0.5,
        height: size.y * 0.5,
      );
      canvas.drawRect(specialRect, specialPaint);
    }
  }
  
  Color _getColorFromEnum(CrystalColor crystalColor) {
    switch (crystalColor) {
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
}
