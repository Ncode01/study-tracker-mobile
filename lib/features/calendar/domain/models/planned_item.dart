import 'package:flutter/material.dart';

enum PlannedItemSource { manual, hubLiveClass, hubRecording }

class PlannedItem {
  const PlannedItem({
    required this.id,
    required this.categoryId,
    required this.categoryTitle,
    required this.accentColor,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.source = PlannedItemSource.manual,
    this.isEditable = true,
  });

  final int id;
  final String categoryId;
  final String categoryTitle;
  final Color accentColor;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PlannedItemSource source;
  final bool isEditable;

  PlannedItem copyWith({
    int? id,
    String? categoryId,
    String? categoryTitle,
    Color? accentColor,
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    PlannedItemSource? source,
    bool? isEditable,
  }) {
    return PlannedItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      accentColor: accentColor ?? this.accentColor,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isEditable: isEditable ?? this.isEditable,
    );
  }
}

class PlannedItemDraft {
  const PlannedItemDraft({
    required this.categoryId,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.notes,
  });

  final String categoryId;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String? notes;
}

class CalendarCategoryOption {
  const CalendarCategoryOption({
    required this.id,
    required this.title,
    required this.accentColor,
  });

  final String id;
  final String title;
  final Color accentColor;
}

class CalendarActualSession {
  const CalendarActualSession({
    required this.categoryId,
    required this.categoryTitle,
    required this.accentColor,
    required this.startedAt,
    required this.endedAt,
    this.isLive = false,
  });

  final String categoryId;
  final String categoryTitle;
  final Color accentColor;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isLive;
}
