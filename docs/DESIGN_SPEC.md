## Design Decisions - Step 1

- **Theme:** Implemented a dark theme using `ThemeData`. Defined custom colors in `app_colors.dart` and applied them in `app_theme.dart`. This provides a consistent look and feel throughout the application, adhering to the dark theme requirement.
- **Navigation:** Chose `BottomNavigationBar` for primary navigation between the main features (Projects, Sessions, Add, Tasks, Stats). This is a common and intuitive navigation pattern for mobile applications.
- **Directory Structure:** Organized files into a feature-first structure within `lib/src`. This promotes modularity and scalability as the application grows. Core UI elements are in `features/core_ui`, constants in `constants`, and feature-specific screens will reside in their respective `features` subdirectories.
- **Root Widget:** Created `AppRoot` in `src/app.dart` to encapsulate the `MaterialApp` configuration, separating it from `main.dart` for better organization.
- **Placeholder Screens:** Created simple `StatelessWidget` placeholders for each main feature screen. This allows for incremental development of each feature.
- **State Management (MainScreen):** Used a `StatefulWidget` for `MainScreen` to manage the `currentIndex` of the `BottomNavigationBar` locally.

## Design Decisions - Step 2

- **ProjectsScreen UI:** Implemented a full-featured UI for the Projects screen, including an AppBar with icons, a horizontal date scroller, filter chips, and a project list.
- **ProjectListItem Widget:** Created a reusable `ProjectListItem` widget to display project details, progress, and navigation arrow, ensuring consistent styling and separation of concerns.
- **HorizontalDateScroller:** Added a horizontally scrolling date selector with selectable styling, using static data for now. Each date is represented by a `DateScrollerItem` widget.
- **Filter Chips:** Used `ChoiceChip` widgets for "All" and "Due" filters, styled to match the dark theme. These are currently static but ready for future interactivity.
- **Dummy Data:** Populated the project list with static `Project` instances for UI demonstration. No backend or state management yet.
- **Duration Formatting:** Added a utility function to format minutes as "Xh YYm" for display in project progress.

## Design Decisions - Step 3

- **Add Button Modal:** The Add button in the BottomNavigationBar now opens a modal bottom sheet (`AddOptionsModalSheet`) instead of switching the main screen. This provides a modern, discoverable way to create new items.
- **AddOptionsModalSheet Widget:** Created a dedicated widget for the modal, offering options for "Project" and "Task" creation, styled to match the dark theme.
- **Navigation Flow:** Tapping an option in the modal closes the sheet and navigates to a new placeholder form screen for either a project or a task.
- **Placeholder Form Screens:** Added `AddProjectScreen` and `AddTaskScreen` as stateless widgets with basic AppBars and placeholder form content, using `SingleChildScrollView` to prevent overflow on small screens.
- **IndexedStack Management:** The Add button does not change the main screen's `IndexedStack` index, ensuring navigation state is preserved for other tabs.
- **File Cleanup:** The old `AddItemScreen` is now obsolete and can be deleted.

## Design Decisions - Step 4

- **AddProjectScreen Form:** Converted to a StatefulWidget to manage form state and user input.
- **Form Structure:** Used a `Form` widget with a `GlobalKey<FormState>` for validation and structure.
- **Project Name Field:** Implemented with a `TextFormField` and validator for required input.
- **Goal Time Field:** Implemented with a `TextFormField` for flexible input (to be parsed/validated in a future step).
- **Color Picker:** Provided a row of selectable color circles (predefined palette), with a border and check icon to indicate selection.
- **Due Date Picker:** Used a row with a display of the selected date and a button to open a `showDatePicker` dialog, styled for dark mode.
- **Button:** The "Create Project" button validates the form and prints values for now.
- **Styling:** All fields and sections use padding and spacing for a clean, modern look consistent with the dark theme.

## Design Decisions - Step 5

- **AddTaskScreen Form:** Converted to a StatefulWidget to manage form state and user input.
- **Form Structure:** Used a `Form` widget with a `GlobalKey<FormState>` for validation and structure.
- **Task Name Field:** Implemented with a `TextFormField` and validator for required input.
- **Assign to Project Field:** Used a `DropdownButtonFormField<String>` with dummy project names for now, styled for the dark theme.
- **Due Date Picker:** Used a row with a display of the selected date and a button to open a `showDatePicker` dialog, styled for dark mode.
- **Button:** The "Create Task" button validates the form and prints values for now.
- **Styling:** All fields and sections use padding and spacing for a clean, modern look consistent with the dark theme.

## Design Decisions - Step 6

- **State Management:** Adopted the `provider` package for app-wide state management. `ProjectProvider` extends `ChangeNotifier` and manages the list of projects, fetching from and saving to the SQLite database.
- **Database:** Used `sqflite` for local SQLite storage. The `projects` table schema includes: `id` (TEXT PRIMARY KEY), `name`, `color` (as int), `goalMinutes`, `loggedMinutes`, and `dueDate` (as ISO8601 string).
- **Database Helper:** Created a singleton `DatabaseHelper` service to encapsulate all SQLite operations for projects.
- **Project Model:** Added `toMap` and `fromMap` methods to serialize/deserialize projects for the database. Used `uuid` for unique project IDs.
- **Provider Integration:** Wrapped the app in a `MultiProvider` in `main.dart` and provided `ProjectProvider` globally. `ProjectsScreen` and `AddProjectScreen` now interact with the provider for all project data.
- **UI Updates:** `ProjectsScreen` uses a `Consumer<ProjectProvider>` to display the current list of projects from the database. `AddProjectScreen` creates and saves new projects via the provider.

## Design Decisions - Step 7

- **Task Model:** Created `Task` model in `task_model.dart` with `toMap`/`fromMap` for SQLite serialization. Includes fields for id, projectId, title, description, dueDate, and isCompleted.
- **Database Schema:** Updated `DatabaseHelper` to create a `tasks` table with a foreign key to `projects`. Added CRUD methods: `insertTask`, `updateTask`, `getAllTasks`.
- **TaskProvider:** Implemented `TaskProvider` using `ChangeNotifier` for task state, fetching, adding, and toggling completion. Exposes open and completed task lists.
- **Provider Integration:** Registered `TaskProvider` in `main.dart`'s `MultiProvider` for global access.
- **AddTaskScreen:** Updated to save tasks via `TaskProvider`, use real project list for dropdown, and added a description field.
- **TasksScreen UI:** Built a tabbed UI with `TabBar` for open/completed tasks, using `Consumer<TaskProvider>` and a new `TaskListItem` widget for display and toggling.
- **Bugfixes:** Removed unused imports in `task_model.dart` and `database_helper.dart`.
- **Documentation:** Updated `PROGRESS_LOG.md` and this file to reflect all changes in Step 7.

## Design Decisions - Step 8

- **Session Model:** Created `Session` model in `session_model.dart` with toMap/fromMap for SQLite. Includes id, projectId, projectName, startTime, endTime, durationMinutes.
- **Database Schema:** Updated `DatabaseHelper` to create a `sessions` table. Added CRUD for sessions, and updateProject for loggedMinutes.
- **TimerServiceProvider:** Manages timer state, start/stop logic, session creation, and project loggedMinutes update. Cancels previous timer if a new one is started. Notifies listeners for UI updates.
- **ProjectProvider:** Added `updateProjectLoggedTime` to update loggedMinutes and DB, then notify listeners.
- **Provider Integration:** Registered `TimerServiceProvider` and `SessionProvider` in `main.dart`'s `MultiProvider`.
- **ProjectListItem:** Play/stop button now starts/stops timer for a project. Shows elapsed time if active. UI updates dynamically.
- **SessionsScreen:** Displays all sessions using `SessionProvider` and `SessionListItem`.
- **SessionListItem:** Shows project name, duration, and formatted start/end times using `intl`.
- **Dependency:** Added `intl` for date formatting.
- **Documentation:** Updated `PROGRESS_LOG.md` and this file for all changes in Step 8.
