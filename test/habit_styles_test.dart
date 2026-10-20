import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_track/core/constants/habit_styles.dart';

void main() {
  test('uses const Material icons for the picker options', () {
    expect(habitIconDataOptions['water'], Icons.local_drink);
    expect(habitIconOptions['water'], Icons.local_drink.codePoint);
  });

  test('resolves legacy code points to the matching current icon', () {
    expect(iconNameFor(0xe625), 'water');
    expect(iconDataFor(0xe625), Icons.local_drink);
  });

  test('falls back to the check icon for unknown code points', () {
    expect(iconDataFor(0xffff), Icons.check_circle_outline);
  });
}
