import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../study/domain/models/subject_model.dart';
import '../../../study/providers/study_providers.dart';

/// Full subject creation screen with form validation and continent theme
class SubjectCreateScreen extends ConsumerStatefulWidget {
  const SubjectCreateScreen({super.key});

  @override
  ConsumerState<SubjectCreateScreen> createState() =>
      _SubjectCreateScreenState();
}

class _SubjectCreateScreenState extends ConsumerState<SubjectCreateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _selectedColor;

  // Available continent themes
  final List<Map<String, dynamic>> _continentThemes = [
    {'name': 'Europe', 'color': AppColors.skyBlue, 'icon': Icons.castle},
    {
      'name': 'Asia',
      'color': AppColors.primaryGold,
      'icon': Icons.temple_buddhist,
    },
    {
      'name': 'Africa',
      'color': AppColors.warningOrange,
      'icon': Icons.landscape,
    },
    {
      'name': 'Americas',
      'color': AppColors.treasureGreen,
      'icon': Icons.forest,
    },
    {'name': 'Oceania', 'color': AppColors.infoBlue, 'icon': Icons.waves},
    {'name': 'Arctic', 'color': AppColors.lightGray, 'icon': Icons.ac_unit},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Discover New Continent'),
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: AppColors.parchmentWhite,
        elevation: 2,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildForm(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with adventurer's diary styling
            _buildHeader(),
            const SizedBox(height: 32),

            // Subject name field
            _buildNameField(),
            const SizedBox(height: 24),

            // Description field
            _buildDescriptionField(),
            const SizedBox(height: 32),

            // Continent theme selector
            _buildThemeSelector(),
            const SizedBox(height: 40),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.explore,
                color: AppColors.primaryGold,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Learning Adventure',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chart your course to a new continent of knowledge',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.fadeGray),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continent Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g., Mathematics, History, Science...',
            prefixIcon: const Icon(Icons.book, color: AppColors.primaryGold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
            ),
            filled: true,
            fillColor: AppColors.parchmentWhite,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a continent name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'Describe your learning goals and what you hope to achieve...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description, color: AppColors.primaryGold),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
            ),
            filled: true,
            fillColor: AppColors.parchmentWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Continent Theme',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select a theme that represents your learning journey',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.fadeGray),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _continentThemes.length,
          itemBuilder: (context, index) {
            final theme = _continentThemes[index];
            final isSelected = _selectedColor == theme['name'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = theme['name'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme['color'].withValues(alpha: 0.2)
                          : AppColors.parchmentWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme['color'] : AppColors.lightGray,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: theme['color'].withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(theme['icon'], color: theme['color'], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      theme['name'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? theme['color'] : AppColors.fadeGray,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createSubject,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.parchmentWhite,
                        ),
                      ),
                    )
                    : const Icon(Icons.add),
            label: Text(_isLoading ? 'Creating...' : 'Begin Your Journey'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.treasureGreen,
              foregroundColor: AppColors.parchmentWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _isLoading ? null : () => context.go('/dashboard'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Return to Dashboard'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.fadeGray,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createSubject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the subject
      final subject = Subject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
      );

      await ref.read(subjectRepositoryProvider).addSubject(subject);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${subject.name} continent discovered!'),
            backgroundColor: AppColors.treasureGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navigate back to dashboard
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create subject: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
