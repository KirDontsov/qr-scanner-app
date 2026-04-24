# Flutter Architecture Rules

## Overview
Rules for structuring Flutter applications. Based on Clean Architecture and provider pattern.

## Layer Order (Outer to Inner)
```
lib/
├── main.dart              # Entry point
├── app/                   # App configuration, theme
├── features/              # Feature modules (grouped by domain)
│   └── scanner/
│       ├── data/           # Data layer (repositories, data sources)
│       ├── domain/        # Domain layer (entities, use cases)
│       └── presentation/    # Presentation layer (pages, widgets, BLoC)
├── shared/                # Shared utilities, constants, themes
└── widgets/               # Reusable widgets
```

## Key Rules

### 1. Feature-First Organization
Group code by feature, not by file type. Each feature is self-contained.

### 2. State Management
- **Simple:** Use StatefulWidget for local UI state
- **Medium:** Use Cubit for simple state (no events)
- **Complex:** Use BLoC for complex state with events/side effects

### 3. Dependency Injection
Use `flutter_bloc` provider or `get_it` for service location.

### 4. Repository Pattern
Abstract data sources behind repository interfaces.

### 5. Avoid
- Global state (except BLoC providers at app root)
- Passing BuildContext deep in widget tree (use Provider)
- Business logic in widgets (move to Cubit/BLoC)

## File Naming
- `*_bloc.dart` - BLoC class
- `*_event.dart` - BLoC events
- `*_state.dart` - BLoC state
- `*_page.dart` - Page widget
- `*_widget.dart` - Reusable widget
- `*_repository.dart` - Repository
- `*_entity.dart` - Domain entity
- `*_test.dart` - Tests

## Anti-Patterns to Avoid
1. Business logic in `initState()` — use Cubit/BLoC
2. Direct API calls in widgets — use repository
3. Multiple providers at different levels — consolidate
4. Large widgets (>100 lines) — extract widgets