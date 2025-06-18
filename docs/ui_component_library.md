# UI Component Library

## Overview

Comprehensive UI component library for Project Atlas Flutter mobile application, providing reusable, customizable, and accessible components following Material Design 3 principles.

## Design System Foundation

### Color Palette
```dart
// lib/theme/app_colors.dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryVariant = Color(0xFF1565C0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color onSecondary = Color(0xFF000000);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onSurface = Color(0xFF1C1B1F);
  
  // Status Colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Study-specific Colors
  static const Color studyActive = Color(0xFF4CAF50);
  static const Color studyPaused = Color(0xFFFF9800);
  static const Color studyCompleted = Color(0xFF2196F3);
  
  // Subject Category Colors
  static const List<Color> subjectColors = [
    Color(0xFFE57373), // Red
    Color(0xFF81C784), // Green
    Color(0xFF64B5F6), // Blue
    Color(0xFFFFB74D), // Orange
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DB6AC), // Teal
    Color(0xFFF06292), // Pink
    Color(0xFF90A4AE), // Blue Grey
  ];
}
```

### Typography System
```dart
// lib/theme/app_typography.dart
class AppTypography {
  static const String fontFamily = 'Roboto';
  
  // Heading Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    height: 1.25,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    height: 1.29,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.44,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.2,
  );
  
  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    height: 1.2,
  );
}
```

### Spacing System
```dart
// lib/theme/app_spacing.dart
class AppSpacing {
  // Base unit (4px)
  static const double unit = 4.0;
  
  // Common spacing values
  static const double xs = unit; // 4px
  static const double sm = unit * 2; // 8px
  static const double md = unit * 3; // 12px
  static const double lg = unit * 4; // 16px
  static const double xl = unit * 5; // 20px
  static const double xxl = unit * 6; // 24px
  static const double xxxl = unit * 8; // 32px
  
  // Layout spacing
  static const double pageHorizontal = lg; // 16px
  static const double pageVertical = lg; // 16px
  static const double sectionSpacing = xxl; // 24px
  static const double cardPadding = lg; // 16px
  
  // Component spacing
  static const double buttonPadding = md; // 12px
  static const double inputPadding = md; // 12px
  static const double iconSpacing = sm; // 8px
}
```

## Core Components

### Button Components

#### AuthButton
```dart
/// Primary authentication button with loading states and variants
/// 
/// Features:
/// - Multiple visual variants (primary, secondary, outline)
/// - Loading state with spinner
/// - Icon support
/// - Accessibility compliant
/// - Consistent sizing and spacing
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AuthButtonVariant variant;
  final AuthButtonSize size;
  
  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AuthButtonVariant.primary,
    this.size = AuthButtonSize.large,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();
    final colors = _getVariantColors(context);
    
    return SizedBox(
      width: size == AuthButtonSize.large ? double.infinity : null,
      height: buttonConfig.height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: colors.disabled,
          elevation: variant == AuthButtonVariant.primary ? 2 : 0,
          padding: EdgeInsets.symmetric(
            horizontal: buttonConfig.horizontalPadding,
            vertical: buttonConfig.verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonConfig.borderRadius),
            side: variant == AuthButtonVariant.outline
                ? BorderSide(color: colors.border)
                : BorderSide.none,
          ),
        ),
        child: _buildButtonContent(colors),
      ),
    );
  }
  
  Widget _buildButtonContent(_ButtonColors colors) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(colors.foreground),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getButtonConfig().iconSize),
          SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              fontSize: _getButtonConfig().fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: _getButtonConfig().fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

enum AuthButtonVariant { primary, secondary, outline }
enum AuthButtonSize { small, medium, large }

class _ButtonConfig {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final double iconSize;
  
  const _ButtonConfig({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.fontSize,
    required this.iconSize,
  });
}
```

#### FloatingActionButton (Custom)
```dart
/// Custom floating action button for study actions
class StudyFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  
  const StudyFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor: backgroundColor ?? theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      child: Icon(icon),
    );
  }
}
```

### Input Components

#### CustomTextField
```dart
/// Customizable text field with validation and accessibility
/// 
/// Features:
/// - Built-in validation with error display
/// - Password visibility toggle
/// - Icon support (prefix/suffix)
/// - Multiple input types
/// - Accessibility labels
/// - Focus management
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });
  
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _focusNode.hasFocus
                        ? theme.primaryColor
                        : theme.colorScheme.onSurfaceVariant,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(theme),
            border: _buildBorder(theme.colorScheme.outline),
            enabledBorder: _buildBorder(theme.colorScheme.outline),
            focusedBorder: _buildBorder(theme.primaryColor, width: 2),
            errorBorder: _buildBorder(theme.colorScheme.error),
            focusedErrorBorder: _buildBorder(theme.colorScheme.error, width: 2),
            filled: true,
            fillColor: widget.enabled 
                ? theme.colorScheme.surface 
                : theme.colorScheme.surfaceVariant,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          style: AppTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }
  
  Widget? _buildSuffixIcon(ThemeData theme) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }
    
    return widget.suffixIcon;
  }
  
  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
```

#### SearchField
```dart
/// Search input field with suggestions and filtering
class SearchField extends StatefulWidget {
  final String? hint;
  final List<String> suggestions;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final void Function(String)? onSuggestionSelected;
  final TextEditingController? controller;
  
  const SearchField({
    super.key,
    this.hint = 'Search...',
    this.suggestions = const [],
    required this.onChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.controller,
  });
  
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _filteredSuggestions = widget.suggestions;
    
    _focusNode.addListener(_onFocusChange);
  }
  
  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }
  
  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = widget.suggestions;
      } else {
        _filteredSuggestions = widget.suggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showSuggestions = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      _filterSuggestions('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: (value) {
            widget.onChanged(value);
            _filterSuggestions(value);
          },
          onSubmitted: widget.onSubmitted,
        ),
        if (_showSuggestions) ...[
          SizedBox(height: AppSpacing.xs),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      _controller.text = suggestion;
                      widget.onSuggestionSelected?.call(suggestion);
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

### Card Components

#### StudySessionCard
```dart
/// Card component for displaying study session information
class StudySessionCard extends StatelessWidget {
  final StudySessionModel session;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  
  const StudySessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = session.duration ?? Duration.zero;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSubjectIcon(theme),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.subject,
                          style: AppTypography.h6.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _formatSessionType(session.type),
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showActions) _buildActionsMenu(theme),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.schedule,
                    label: _formatDuration(duration),
                    theme: theme,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(session.startTime),
                    theme: theme,
                  ),
                ],
              ),
              if (session.tags.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: session.tags
                      .map((tag) => _buildTagChip(tag, theme))
                      .toList(),
                ),
              ],
              if (session.notes?.isNotEmpty == true) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  session.notes!,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSubjectIcon(ThemeData theme) {
    final color = _getSubjectColor(session.subject);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getSubjectIcon(session.subject),
        color: color,
        size: 20,
      ),
    );
  }
  
  Widget _buildActionsMenu(ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
              SizedBox(width: AppSpacing.sm),
              Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTagChip(String tag, ThemeData theme) {
    return Chip(
      label: Text(
        tag,
        style: AppTypography.labelSmall,
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
  
  Color _getSubjectColor(String subject) {
    final hash = subject.hashCode;
    return AppColors.subjectColors[hash.abs() % AppColors.subjectColors.length];
  }
  
  IconData _getSubjectIcon(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('math')) return Icons.calculate;
    if (subjectLower.contains('science')) return Icons.science;
    if (subjectLower.contains('history')) return Icons.history_edu;
    if (subjectLower.contains('language')) return Icons.translate;
    if (subjectLower.contains('art')) return Icons.palette;
    return Icons.book;
  }
  
  String _formatSessionType(StudyType type) {
    switch (type) {
      case StudyType.reading:
        return 'Reading Session';
      case StudyType.practice:
        return 'Practice Session';
      case StudyType.review:
        return 'Review Session';
      case StudyType.exam:
        return 'Exam Preparation';
      case StudyType.general:
        return 'General Study';
    }
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
```

#### StatisticsCard
```dart
/// Card component for displaying study statistics
class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final Widget? chart;
  final VoidCallback? onTap;
  
  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.chart,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.labelMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          value,
                          style: AppTypography.h4.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (chart != null) ...[
                SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 100,
                  child: chart!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Navigation Components

#### AppBottomNavigationBar
```dart
/// Custom bottom navigation bar for main app navigation
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
```

#### AppDrawer
```dart
/// Custom navigation drawer for secondary navigation
class AppDrawer extends StatelessWidget {
  final UserModel? currentUser;
  final VoidCallback? onSignOut;
  
  const AppDrawer({
    super.key,
    this.currentUser,
    this.onSignOut,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            accountName: Text(
              currentUser?.displayName ?? 'User',
              style: AppTypography.h6.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              currentUser?.email ?? '',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (currentUser?.displayName?.isNotEmpty == true)
                    ? currentUser!.displayName![0].toUpperCase()
                    : 'U',
                style: AppTypography.h5.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => _navigateToSettings(context),
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _navigateToHelp(context),
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () => _navigateToAbout(context),
                ),
                Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () {
                    Navigator.pop(context);
                    onSignOut?.call();
                  },
                  textColor: theme.colorScheme.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: textColor),
      ),
      onTap: onTap,
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    // Navigate to settings
  }
  
  void _navigateToHelp(BuildContext context) {
    Navigator.pop(context);
    // Navigate to help
  }
  
  void _navigateToAbout(BuildContext context) {
    Navigator.pop(context);
    // Navigate to about
  }
}
```

### Loading and Feedback Components

#### LoadingOverlay
```dart
/// Loading overlay component for blocking interactions during async operations
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: Card(
                margin: EdgeInsets.all(AppSpacing.xl),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      if (message != null) ...[
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          message!,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

#### EmptyStateWidget
```dart
/// Widget for displaying empty states with call-to-action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? illustration;
  
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.illustration,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null)
              illustration!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.h5.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl),
              AuthButton(
                text: actionText!,
                onPressed: onAction,
                variant: AuthButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### ErrorWidget
```dart
/// Widget for displaying error states with retry options
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final IconData icon;
  
  const AppErrorWidget({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.icon = Icons.error_outline,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.h5.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.xl),
              AuthButton(
                text: 'Try Again',
                onPressed: onRetry,
                variant: AuthButtonVariant.outline,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## Component Usage Guidelines

### Accessibility Standards
All components must follow accessibility best practices:

```dart
// Example of accessible component implementation
class AccessibleComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Descriptive label for screen readers',
      hint: 'Action hint for users',
      enabled: true,
      child: GestureDetector(
        onTap: () => _handleTap(),
        child: Container(
          // Component implementation
        ),
      ),
    );
  }
}
```

### Responsive Design Guidelines
Components should adapt to different screen sizes:

```dart
// Example of responsive component
class ResponsiveComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? AppSpacing.xl : AppSpacing.lg),
      child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
    );
  }
}
```

### Performance Optimization
Components should be optimized for performance:

```dart
// Use const constructors where possible
class OptimizedComponent extends StatelessWidget {
  const OptimizedComponent({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Use const widgets to prevent unnecessary rebuilds
        Text('Static content'),
        SizedBox(height: 16),
      ],
    );
  }
}
```

### Testing Components
Each component should have comprehensive tests:

```dart
// Example component test
void main() {
  group('AuthButton', () {
    testWidgets('displays text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthButton(
            text: 'Test Button',
            onPressed: () {},
          ),
        ),
      );
      
      expect(find.text('Test Button'), findsOneWidget);
    });
    
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthButton(
            text: 'Test Button',
            isLoading: true,
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

This UI Component Library provides a comprehensive set of reusable, accessible, and well-documented components for the Project Atlas mobile application, ensuring consistency and maintainability across the entire application.
