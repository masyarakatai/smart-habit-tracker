import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Named habit icons. Using const icons keeps them in the Material icon font
/// and allows Flutter to tree-shake the icons that are not used.
const Map<String, IconData> habitIconDataOptions = {
  'check': Icons.check_circle_outline,
  'water': Icons.local_drink,
  'fitness': Icons.fitness_center,
  'book': Icons.menu_book,
  'meditation': Icons.self_improvement,
  'run': Icons.directions_run,
  'sleep': Icons.bed,
  'code': Icons.code,
  'art': Icons.brush,
  'music': Icons.music_note,
};

/// Code points used by newly created habits and by the coach tool.
const Map<String, int> habitIconOptions = {
  for (final entry in habitIconDataOptions.entries) entry.key: entry.value.codePoint,
};

/// Code points written by older app versions. Keep these IDs readable so
/// existing saved habits resolve to the same named icon after an upgrade.
const Map<int, String> _legacyIconNames = {
  0xe57f: 'check',
  0xe625: 'water',
  0xe2bd: 'fitness',
  0xe3e8: 'book',
  0xe51c: 'meditation',
  0xe0b0: 'run',
  0xe68c: 'sleep',
  0xe1b1: 'code',
  0xe40a: 'art',
  0xe425: 'music',
};

/// Named habit accent colors, in the same order as [AppColors.habitPalette].
final Map<String, int> habitColorOptions = {
  for (var i = 0; i < _colorNames.length; i++)
    _colorNames[i]: AppColors.habitPalette[i].toARGB32(),
};

const List<String> _colorNames = [
  'indigo',
  'sky',
  'emerald',
  'pink',
  'purple',
  'orange',
  'teal',
  'yellow',
];

String? iconNameFor(int codePoint) {
  for (final e in habitIconOptions.entries) {
    if (e.value == codePoint) return e.key;
  }
  return _legacyIconNames[codePoint];
}

IconData iconDataFor(int codePoint) {
  final name = iconNameFor(codePoint) ?? 'check';
  return habitIconDataOptions[name]!;
}

String? colorNameFor(int colorValue) {
  for (final e in habitColorOptions.entries) {
    if (e.value == colorValue) return e.key;
  }
  return null;
}
