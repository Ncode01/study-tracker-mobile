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
