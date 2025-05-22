## Step 1: Project Setup, Theme, and Bottom Navigation
- Created: `lib/src/app.dart` (Purpose: Root `MaterialApp` widget.)
- Created: `lib/src/constants/app_colors.dart` (Purpose: Defines the application's color palette.)
- Created: `lib/src/constants/app_theme.dart` (Purpose: Defines the application's dark theme.)
- Created: `lib/src/features/core_ui/screens/main_screen.dart` (Purpose: Provides the main screen with bottom navigation.)
- Created: `lib/src/features/projects/screens/projects_screen.dart` (Purpose: Placeholder screen for projects.)
- Created: `lib/src/features/sessions/screens/sessions_screen.dart` (Purpose: Placeholder screen for sessions.)
- Created: `lib/src/features/tasks/screens/tasks_screen.dart` (Purpose: Placeholder screen for tasks.)
- Created: `lib/src/features/stats/screens/stats_screen.dart` (Purpose: Placeholder screen for stats.)
- Modified: `lib/main.dart` (Reason: Updated to use the new `AppRoot` widget and removed old default code.)

## Step 2: Projects Screen UI
- Created: `lib/src/models/project_model.dart` (Purpose: Defines the Project data model.)
- Created: `lib/src/features/projects/widgets/project_list_item.dart` (Purpose: Reusable widget for displaying a project in the list.)
- Created: `lib/src/features/projects/widgets/date_scroller.dart` (Purpose: Horizontal date scroller widget for the Projects screen.)
- Created: `lib/src/utils/formatters.dart` (Purpose: Utility for formatting durations in minutes to 'Xh YYm'.)
- Modified: `lib/src/features/projects/screens/projects_screen.dart` (Reason: Implemented full ProjectsScreen UI with AppBar, date scroller, filter chips, and project list.)

## Step 3: Add Button Modal & Navigation
- Created: `lib/src/features/add_item/widgets/add_options_modal_sheet.dart` (Purpose: Modal bottom sheet for add options.)
- Created: `lib/src/features/projects/screens/add_project_screen.dart` (Purpose: Placeholder form screen for creating a new project.)
- Created: `lib/src/features/tasks/screens/add_task_screen.dart` (Purpose: Placeholder form screen for creating a new task.)
- Modified: `lib/src/features/core_ui/screens/main_screen.dart` (Reason: Refactored Add button to open modal, removed AddItemScreen from navigation logic.)

## Step 4: Add Project Form UI
- Modified: `lib/src/features/projects/screens/add_project_screen.dart` (Reason: Implemented full Add Project form UI with TextFormFields, color picker, date picker, and local state management.)
