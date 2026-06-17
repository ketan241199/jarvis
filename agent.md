# Jarvis — Smart TODO & Reminder App

## Project Overview
Jarvis is a Flutter-based smart TODO and reminder application targeting Android, iOS, and Web.
It helps users manage daily tasks with reminders, overdue tracking, voice commands, tagging,
and custom work schedule integration. Data is persisted in Firebase Firestore with push
notifications via FCM.

## Architecture

### Clean Architecture + BLoC Pattern
The project follows **Clean Architecture** with three distinct layers:

```
Presentation → Domain → Data
```

- **Presentation Layer** (`lib/presentation/`): Screens, widgets, and BLoC/Cubit classes.
  Depends on Domain layer only.
- **Domain Layer** (`lib/domain/`): Entities, repository interfaces (abstract classes),
  and use cases. Has ZERO external dependencies — pure Dart.
- **Data Layer** (`lib/data/`): Firestore models, data sources, and repository
  implementations. Depends on Domain layer for interfaces.
- **Core Layer** (`lib/core/`): Shared utilities, theme, constants, enums, DI setup.
  Used across all layers.
- **Services Layer** (`lib/services/`): Cross-cutting concerns like notifications,
  speech-to-text, and Firebase initialization.

### Design Principles

#### SOLID
- **S** (Single Responsibility): One class = one purpose. Cubits manage state.
  DataSources handle I/O. Use Cases contain business logic.
- **O** (Open/Closed): Repository interfaces allow new implementations without
  modifying existing code.
- **L** (Liskov Substitution): Any `TaskRepository` implementation (Firestore, local,
  mock) can be swapped without breaking the app.
- **I** (Interface Segregation): Separate interfaces: `TaskRepository`, `TagRepository`,
  `ScheduleRepository`. No god-interfaces.
- **D** (Dependency Inversion): Use Cases and Cubits depend on abstractions
  (repository interfaces), never on Firestore directly.

#### DRY
- Shared `BaseEntity` pattern with `id`, `createdAt`, `updatedAt`.
- Reusable widgets: `TaskCard`, `TagChip`, `ScheduleBadge`, `VoiceInputButton`.
- Centralized date/time utilities in `core/utils/`.
- Firestore paths in `core/constants/firestore_paths.dart`.

#### OOP
- Inheritance: Models extend Entities for serialization.
- Encapsulation: Private state in Cubits, exposed via immutable state classes.
- Polymorphism: Repository interface implementations.
- Abstraction: Use case classes abstract business operations.

## State Management — BLoC/Cubit
- Use `Cubit` (not full `Bloc`) for simpler state management.
- States extend `Equatable` for proper equality comparison.
- Each feature gets its own Cubit: `TaskCubit`, `TagCubit`, `ScheduleCubit`, `SpeechCubit`.
- Cubits are provided at the router level via `BlocProvider`.

## Dependency Injection
- Uses `GetIt` for service location.
- All registrations happen in `core/di/injection.dart`.
- Registration order: Services → DataSources → Repositories → UseCases → Cubits.

## Firebase
- **Firestore** for data persistence (tasks, tags, schedules, settings).
- **FCM** for push notifications on overdue tasks.
- Collections: `tasks`, `tags`, `schedules`, `settings`.
- Device ID is used as the user identifier (no auth required).

## Coding Conventions

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (Dart convention)
- Enums: `PascalCase` type, `camelCase` values
- Private members: prefix with `_`

### File Organization
- One public class per file (matching filename).
- Group related files in feature directories.
- Barrel exports (`index.dart`) are NOT used — use explicit imports.

### Imports
- Dart SDK imports first, then packages, then relative project imports.
- Use relative imports for within-package references.
- Never use `package:jarvis/` for internal imports — use relative paths.

### Testing
- Unit tests for use cases and cubits.
- Widget tests for custom widgets.
- Test files mirror `lib/` structure under `test/`.

### Error Handling
- Use `try/catch` in data sources, propagate typed exceptions.
- Cubits emit error states with user-friendly messages.
- Never silently swallow errors.

## Adding a New Feature (Checklist)
1. Define entity in `domain/entities/`
2. Define repository interface in `domain/repositories/`
3. Create use case(s) in `domain/usecases/`
4. Create Firestore model in `data/models/` (with `toFirestore`/`fromFirestore`)
5. Create data source in `data/datasources/`
6. Implement repository in `data/repositories/`
7. Create Cubit + State in `presentation/blocs/`
8. Build screen in `presentation/screens/`
9. Extract reusable widgets to `presentation/widgets/`
10. Register everything in `core/di/injection.dart`
11. Add route in `app.dart`

## Voice Commands
The speech service parses natural language into task actions:
- "Add task [title]" → Create task
- "Add work task [title]" → Create work-tagged task
- "Remove task [title]" → Delete task
- "Complete task [title]" → Mark done
- "Show overdue" → Navigate to overdue tab

## Key Dependencies
| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Data persistence |
| `firebase_messaging` | Push notifications (FCM) |
| `flutter_bloc` | State management (Cubit) |
| `get_it` | Dependency injection |
| `speech_to_text` | Voice input |
| `flutter_local_notifications` | Local reminders |
| `go_router` | Navigation/routing |
| `equatable` | Value equality for states/entities |
| `intl` | Date/time formatting |
| `uuid` | Unique ID generation |
