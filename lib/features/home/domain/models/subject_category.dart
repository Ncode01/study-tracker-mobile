import 'package:flutter/material.dart';

import '../../../../core/theme/material_category_icon_resolver.dart';

class SubjectCategory {
  const SubjectCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.section,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final String section;

  SubjectCategory copyWith({
    String? id,
    String? title,
    IconData? icon,
    Color? accentColor,
    String? section,
  }) {
    return SubjectCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      section: section ?? this.section,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'accentColorValue': accentColor.toARGB32(),
      'section': section,
    };
  }

  factory SubjectCategory.fromMap(Map<String, Object?> map) {
    return SubjectCategory(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      icon: MaterialCategoryIconResolver.resolve(
        categoryId: map['id'] as String?,
        iconCodePoint: map['iconCodePoint'] as int?,
        iconFontFamily: map['iconFontFamily'] as String?,
        fallback: Icons.circle,
      ),
      accentColor: Color(map['accentColorValue'] as int? ?? 0xFFFFFFFF),
      section: map['section'] as String? ?? 'A/LEVELS',
    );
  }
}
