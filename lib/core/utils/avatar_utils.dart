import 'package:flutter/material.dart';

class AvatarUtils {
  static const List<List<Color>> _gradients = [
    [Color(0xFF6C63FF), Color(0xFF9B93FF)],
    [Color(0xFFFF6B6B), Color(0xFFFF9E9E)],
    [Color(0xFF4ECDC4), Color(0xFF7EDDD7)],
    [Color(0xFFFFB347), Color(0xFFFFCD82)],
    [Color(0xFF45B7D1), Color(0xFF7DD3E8)],
    [Color(0xFFFF6F91), Color(0xFFFFA3B8)],
    [Color(0xFF2ECC71), Color(0xFF6FE09A)],
    [Color(0xFFAE8CF0), Color(0xFFC9B4F7)],
    [Color(0xFFE17055), Color(0xFFEA9A83)],
    [Color(0xFF00CEC9), Color(0xFF55E3E0)],
  ];

  static List<Color> gradientForName(String name) {
    if (name.isEmpty) return _gradients[0];
    final index = name.codeUnitAt(0) % _gradients.length;
    return _gradients[index];
  }

  static String initialFor(String name) {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }
}
