import 'package:flutter/material.dart';

class MaterialCategoryIconResolver {
  const MaterialCategoryIconResolver._();

  static const String _materialIconFontFamily = 'MaterialIcons';

  static final Map<String, IconData> _iconsByCategoryId = <String, IconData>{
    'maths': Icons.calculate_outlined,
    'physics': Icons.bolt_outlined,
    'chemistry': Icons.science_outlined,
    'break': Icons.free_breakfast_outlined,
    'idle': Icons.hourglass_empty_rounded,
  };

  static final Map<int, IconData> _iconsByCodePoint = <int, IconData>{
    Icons.calculate_outlined.codePoint: Icons.calculate_outlined,
    Icons.bolt_outlined.codePoint: Icons.bolt_outlined,
    Icons.science_outlined.codePoint: Icons.science_outlined,
    Icons.free_breakfast_outlined.codePoint: Icons.free_breakfast_outlined,
    Icons.hourglass_empty_rounded.codePoint: Icons.hourglass_empty_rounded,
    Icons.auto_awesome_rounded.codePoint: Icons.auto_awesome_rounded,
    Icons.circle.codePoint: Icons.circle,
  };

  static IconData resolve({
    required String? categoryId,
    required int? iconCodePoint,
    required String? iconFontFamily,
    required IconData fallback,
  }) {
    final String normalizedId = (categoryId ?? '').trim().toLowerCase();
    final IconData? byCategoryId = _iconsByCategoryId[normalizedId];
    if (byCategoryId != null) {
      return byCategoryId;
    }

    final bool canUseMaterialCodePoint =
        iconFontFamily == null ||
        iconFontFamily.isEmpty ||
        iconFontFamily == _materialIconFontFamily;
    if (canUseMaterialCodePoint && iconCodePoint != null) {
      final IconData? byCodePoint = _iconsByCodePoint[iconCodePoint];
      if (byCodePoint != null) {
        return byCodePoint;
      }
    }

    return fallback;
  }
}
