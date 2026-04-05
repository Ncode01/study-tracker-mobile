import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';

class CreateCategoryResult {
  const CreateCategoryResult({required this.title, required this.accentColor});

  final String title;
  final Color accentColor;
}

class CreateCategoryDialog extends StatefulWidget {
  const CreateCategoryDialog({super.key});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  static const List<Color> _palette = <Color>[
    Color(0xFF3B82F6),
    Color(0xFFF43F5E),
    Color(0xFF22C55E),
    Color(0xFF8554F8),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFFA855F7),
    Color(0xFF64748B),
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = AppColors.primaryPurple;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      CreateCategoryResult(
        title: _nameController.text.trim(),
        accentColor: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Category',
                style: AppTypography.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a custom context for your next deep focus block.',
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.display(color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: AppTypography.display(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _selectedColor.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                validator: (String? value) {
                  final String text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return 'Please enter a category name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text(
                'Accent Color',
                style: AppTypography.display(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _palette.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final Color color = _palette[index];
                    final bool selected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color:
                                selected
                                    ? Colors.white.withValues(alpha: 0.95)
                                    : Colors.white.withValues(alpha: 0.35),
                            width: selected ? 2.6 : 1,
                          ),
                          boxShadow:
                              selected
                                  ? <BoxShadow>[
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                  : null,
                        ),
                        child:
                            selected
                                ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTypography.display(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _selectedColor,
                      ),
                      onPressed: _submit,
                      child: Text(
                        'Create',
                        style: AppTypography.display(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
