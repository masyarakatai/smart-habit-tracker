import 'package:flutter/material.dart';
import '../core/constants/habit_styles.dart';

/// Data model representing a user's daily habit.
class Habit {
  final String id;
  final String title;
  final String description;
  final int iconCodePoint;
  final int colorValue;
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.iconCodePoint = 0xe57f, // Icons.check_circle_outline
    this.colorValue = 0xFF6366F1, // Indigo accent default
    required this.createdAt,
    this.isArchived = false,
  });

  IconData get iconData => iconDataFor(iconCodePoint);

  Color get color => Color(colorValue);

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    int? iconCodePoint,
    int? colorValue,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      iconCodePoint: (map['iconCodePoint'] as int?) ?? 0xe57f,
      colorValue: (map['colorValue'] as int?) ?? 0xFF6366F1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: (map['isArchived'] as bool?) ?? false,
    );
  }
}
