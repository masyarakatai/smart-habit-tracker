import '../theme/app_colors.dart';

/// Named habit icons (Material icon code points). Shared by the add/edit
/// dialog and the AI coach, so both offer the same choices.
const Map<String, int> habitIconOptions = {
  'check': 0xe57f, // check_circle_outline
  'water': 0xe625, // local_drink
  'fitness': 0xe2bd, // fitness_center
  'book': 0xe3e8, // menu_book
  'meditation': 0xe51c, // self_improvement
  'run': 0xe0b0, // directions_run
  'sleep': 0xe68c, // bed
  'code': 0xe1b1, // code
  'art': 0xe40a, // brush
  'music': 0xe425, // music_note
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
  return null;
}

String? colorNameFor(int colorValue) {
  for (final e in habitColorOptions.entries) {
    if (e.value == colorValue) return e.key;
  }
  return null;
}
