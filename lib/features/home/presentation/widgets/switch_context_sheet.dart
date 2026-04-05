import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/subject_category.dart';
import '../providers/home_providers.dart';
import 'category_hero_tag.dart';
import 'create_category_dialog.dart';

class SwitchContextSheet extends ConsumerStatefulWidget {
  const SwitchContextSheet({super.key});

  @override
  ConsumerState<SwitchContextSheet> createState() => _SwitchContextSheetState();
}

class _SwitchContextSheetState extends ConsumerState<SwitchContextSheet> {
  String _query = '';

  Future<void> _handleCreateNew() async {
    final CreateCategoryResult? payload =
        await showDialog<CreateCategoryResult>(
          context: context,
          builder: (_) => const CreateCategoryDialog(),
        );

    if (!mounted || payload == null) {
      return;
    }

    final SubjectCategory? created = await ref
        .read(homeViewNotifierProvider.notifier)
        .createCategory(title: payload.title, accentColor: payload.accentColor);

    if (!mounted || created == null) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<SubjectCategory> categories = ref.watch(categoryListProvider);
    final String currentCategoryId = ref.watch(currentCategoryProvider).id;
    final Map<String, List<SubjectCategory>> grouped = _groupBySection(
      categories,
    );

    return SafeArea(
      top: false,
      child: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            _SearchBar(
              onChanged: (String value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final String section in grouped.keys)
                      _SectionGrid(
                        title: section,
                        categories: _applyFilter(grouped[section] ?? const []),
                        currentCategoryId: currentCategoryId,
                        onSelect: (SubjectCategory category) {
                          unawaited(
                            ref
                                .read(homeViewNotifierProvider.notifier)
                                .switchCategory(category),
                          );
                          Navigator.of(context).pop();
                        },
                        onCreateNew: _handleCreateNew,
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SubjectCategory> _applyFilter(List<SubjectCategory> categories) {
    if (_query.isEmpty) {
      return categories;
    }
    return categories
        .where(
          (SubjectCategory category) =>
              category.title.toLowerCase().contains(_query),
        )
        .toList(growable: false);
  }

  Map<String, List<SubjectCategory>> _groupBySection(
    List<SubjectCategory> categories,
  ) {
    final Map<String, List<SubjectCategory>> map =
        <String, List<SubjectCategory>>{};

    for (final SubjectCategory category in categories) {
      map
          .putIfAbsent(category.section, () => <SubjectCategory>[])
          .add(category);
    }

    return map;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextField(
        onChanged: onChanged,
        style: AppTypography.display(color: AppColors.textMain),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search contexts...',
          hintStyle: AppTypography.display(color: AppColors.textMuted),
          icon: const Icon(Icons.search, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _SectionGrid extends StatelessWidget {
  const _SectionGrid({
    required this.title,
    required this.categories,
    required this.currentCategoryId,
    required this.onSelect,
    required this.onCreateNew,
  });

  final String title;
  final List<SubjectCategory> categories;
  final String currentCategoryId;
  final ValueChanged<SubjectCategory> onSelect;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              title,
              style: AppTypography.display(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final SubjectCategory category in categories)
                GlassCard(
                  category: category,
                  isActive: category.id == currentCategoryId,
                  onTap: () => onSelect(category),
                ),
              _CreateNewCard(onTap: onCreateNew),
            ],
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.category,
    required this.isActive,
    required this.onTap,
  });

  final SubjectCategory category;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        borderColor:
            isActive
                ? category.accentColor.withValues(alpha: 0.55)
                : AppColors.glassBorder,
        backgroundColor:
            isActive
                ? category.accentColor.withValues(alpha: 0.09)
                : AppColors.glassBackground,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: categoryHeroTag(category.id),
              child: Material(
                color: Colors.transparent,
                child: Icon(
                  category.icon,
                  color: category.accentColor,
                  size: 20,
                ),
              ),
            ),
            const Spacer(),
            Text(
              category.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: category.accentColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateNewCard extends StatelessWidget {
  const _CreateNewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorder(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.glassBorder,
        child: Center(
          child: Text(
            'Create New',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.color,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(borderRadius: borderRadius, color: color),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: GlassContainer(
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.borderRadius, required this.color});

  final BorderRadius borderRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = borderRadius.toRRect(Offset.zero & size);
    final Path path = Path()..addRRect(rrect);

    const double dashWidth = 6;
    const double dashSpace = 4;

    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.color != color;
  }
}
