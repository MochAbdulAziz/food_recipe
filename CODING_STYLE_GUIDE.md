# Coding Style Guide

This document outlines the coding conventions and style guidelines for the Mobile SIFA Flutter project. This guide should be shared with AI assistants or team members to maintain consistency across the codebase.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [State Management - BLoC / Cubit](#state-management---bloc--cubit)
3. [UI Components & Screens](#ui-components--screens)
4. [Routing & Navigation](#routing--navigation)
5. [Colors & Theming](#colors--theming)
6. [Naming Conventions](#naming-conventions)
7. [Code Organization](#code-organization)

---

## Project Structure

```
lib/
├── bloc/                      # State management classes
│   └── feature/              # Feature-specific blocs/cubits
│       ├── feature_cubit.dart
│       └── feature_state.dart
├── screens/                   # UI Screens
│   ├── main_screen.dart      # Main entry screen (e.g., Bottom Navigation)
│   └── feature_screen.dart   # Individual feature screens
├── utils/                     # Utility classes and constants
│   └── colors.dart           # App-wide colors
├── widgets/                   # Reusable widgets
└── main.dart                 # Application entry point
```

**Key Principles:**
- **Feature-first for BLoC:** Group Cubits and States by feature under `lib/bloc/`.
- **screens/**: specific screens/pages of the application.
- **widgets/**: shared reusable UI components.
- **utils/**: constants, helpers, and extensions.

---

## State Management - BLoC / Cubit

This project uses the **flutter_bloc** package for state management. We primarily use **Cubits** for simplicity when handling straightforward state changes.

### Cubit Pattern

**File Naming:**
- Cubit: `{feature}_cubit.dart`
- State: `{feature}_state.dart`

**Example:**

**State (`lib/bloc/home/home_state.dart`):**
```dart
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Data> data;
  const HomeLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
```

**Cubit (`lib/bloc/home/home_cubit.dart`):**
```dart
import 'package:bloc/bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading());

  void loadData() async {
    try {
      emit(HomeLoading());
      // Fetch data...
      emit(HomeLoaded(data: ...));
    } catch (e) {
      emit(HomeError("Failed to load data"));
    }
  }
}
```

### Blocs Provisioning

Provide Blocs/Cubits at the top level or scoped level using `BlocProvider`.

**In `main.dart` or `MainScreen`:**
```dart
BlocProvider(
  create: (context) => HomeCubit()..loadData(),
  child: const MainScreen(),
)
```

For multiple providers:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => HomeCubit()),
    BlocProvider(create: (context) => OtherCubit()),
  ],
  child: const MyApp(),
)
```

### Consuming State

Use `BlocBuilder` to rebuild UI in response to state changes.

```dart
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    if (state is HomeLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is HomeLoaded) {
      return ListView.builder(
        itemCount: state.data.length,
        itemBuilder: (context, index) => Text(state.data[index].title),
      );
    } else if (state is HomeError) {
      return Center(child: Text(state.message));
    }
    return const SizedBox.shrink();
  },
)
```

---

## UI Components & Screens

### Screen Naming
**Pattern:** `{feature}_screen.dart`
**Example:** `home_screen.dart`, `profile_screen.dart`, `main_screen.dart`

### Main Screen (Bottom Navigation)
The `MainScreen` typically handles the bottom navigation logic, switching between different "page" widgets using a list of widgets and an index.

```dart
class MainScreen extends StatefulWidget {
  // ...
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        // Implementation
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
```

---

## Routing & Navigation

We use Flutter's standard **Navigator** or Widget swapping (for tabs/bottom nav).

### Navigation
```dart
// Navigate to a new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DetailScreen()),
);

// Go back
Navigator.pop(context);
```

---

## Colors & Theming

### App Colors
Defined in `lib/utils/colors.dart`.

```dart
class AppColors {
  static const Color primary = Color(0xFF8D7B68);
  static const Color background = Color(0xFFF1F0EC);
  static const Color textDark = Color(0xFF2C2C2C);
  // ...
}
```

### Theme Configuration
Configured in `main.dart` using `ThemeData` and `GoogleFonts`.

```dart
ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  textTheme: GoogleFonts.poppinsTextTheme(
    Theme.of(context).textTheme,
  ),
)
```

---

## Naming Conventions

### Files
| Type | Convention | Example |
|------|------------|---------|
| Screen | `{feature}_screen.dart` | `home_screen.dart` |
| Cubit | `{feature}_cubit.dart` | `home_cubit.dart` |
| State | `{feature}_state.dart` | `home_state.dart` |
| Utils | `{name}.dart` | `colors.dart` |
| Widget | `{name}.dart` or `custom_{name}.dart` | `custom_button.dart` |

### Classes
| Type | Convention | Example |
|------|------------|---------|
| Screen | `{Feature}Screen` | `HomeScreen` |
| Cubit | `{Feature}Cubit` | `HomeCubit` |
| State | `{Feature}State` | `HomeState` |
| Utils | `{Name}` or `{Name}Utils` | `AppColors` |

---

## Code Organization

### Import Order
1. Dart/Flutter SDK
2. Third-party packages
3. Project imports (absolute or relative)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/home/home_cubit.dart';
import '../utils/colors.dart';
```

### Logging
Preferred over `print()`:
```dart
import 'dart:developer';

log('Message');
```
