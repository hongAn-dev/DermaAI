import 'package:flutter/material.dart';

Color colorWithOpacity(Color color, double opacity) {
  return Color.fromRGBO(color.red, color.green, color.blue, opacity);
}

Color getColorForName(String name) {
  if (name.isEmpty) return Colors.blue;
  final int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
  ];
  return colors[hash % colors.length];
}
