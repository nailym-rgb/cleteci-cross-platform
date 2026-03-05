---
name: clean-architecture
description: Guidelines for implementing Clean Architecture patterns in Flutter applications, with emphasis on separation of concerns, dependency rules, and testability.
---

# Clean Architecture

You are an expert in Clean Architecture patterns for application development.

## Core Principles

Clean Architecture enforces separation of concerns through distinct layers with dependencies pointing inward:

1. **Domain Layer** (innermost) - Business logic and entities
2. **Application Layer** - Use cases and application-specific logic
3. **Infrastructure Layer** - External concerns (databases, APIs, frameworks)
4. **Presentation Layer** (outermost) - UI and user interaction

The fundamental rule: inner layers must never depend on outer layers.

## Flutter + Clean Architecture

### Architecture Layers
- **Presentation**: Widgets, BLoCs, and UI components
- **Domain**: Entities, use cases, and repository interfaces
- **Data**: Repository implementations, data sources, and models

### Feature-first Organization
```
feature/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/
    pages/
    widgets/
```

### Data vs. Domain Distinction
- Entities (Domain): Pure Dart classes. No serialization logic (fromJson/toJson) or external annotations.
- Models (Data): Extend or implement Entities. Contain serialization logic and infrastructure-specific annotations.
- Mappers: The Data layer is responsible for transforming Models into Entities before passing data inward to the Domain layer.

### Dependency Injection
- Always prefer constructor injection for classes.
- Register dependencies using a service locator (get_it) strictly in an initialization file (e.g., injection_container.dart).
- Never use the service locator directly inside UI widgets. Instead, provide BLoCs via BlocProvider in the presentation layer.

### State Management with flutter_bloc
- Use flutter_bloc for state management
- Implement immutable states via Freezed
- Handle events and states with proper patterns
- Keep BLoCs focused on single responsibilities

### Error Handling
- Implement Either<Failure, Success> pattern from Dartz
- Use functional error handling without exceptions
- Define clear Failure types for different error scenarios

### Key Libraries
- `flutter_bloc` - State management
- `freezed` - Immutable classes and unions
- `get_it` - Service locator for DI
- `dartz` - Functional programming utilities


### Testing Strategy
- Write table-driven unit tests with mocks (using mockito or mocktail)
- Separate fast unit tests from integration tests
- Use interfaces to inject test doubles
- Achieve high test coverage on the Domain layer (Use Cases and Entities).