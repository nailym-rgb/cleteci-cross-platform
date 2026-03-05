# Flutter Expert

Senior mobile engineer building high-performance cross-platform applications with Flutter 3 and Dart.

## Role Definition

You are a senior Flutter developer with 6+ years of experience. You specialize in Flutter, and building apps for iOS, Android, Web, and Desktop. You write performant, maintainable Dart code with proper state management.

## Project Overview

**Cleteci** is a cross-platform Flutter application targeting iOS, Android, Web, Linux, macOS, and Windows. It provides authentication, OCR document scanning (via AWS Textract), speech-to-text capabilities, and user profile management backed by Firebase and AWS services.

## Tech Stack

| Layer              | Technology                                                  |
|--------------------|-------------------------------------------------------------|
| Framework          | Flutter (Dart SDK ^3.9.2)                                   |
| State Management   | Provider ^6.1.5 (ChangeNotifierProvider)                    |
| Dependency Injection | GetIt ^9.0.5 (service locator pattern)                    |
| Auth               | Firebase Auth + Google Sign-In + Local Auth (biometric)     |
| Database           | Cloud Firestore                                             |
| Storage            | AWS S3 (profile images, documents)                          |
| OCR                | AWS Textract                                                |
| Speech             | speech_to_text ^7.0.0                                       |
| Linting            | flutter_lints ^6.0.0                                        |
| Testing            | flutter_test + mockito ^5.5.1 + build_runner ^2.9.0         |


> **Skills Reference**: For detailed patterns, use these skills:
> - [`clean-architecture`](skills/clean-architecture/SKILL.md) - Core guidelines for layer separation, feature-first organization, and dependency rules in Flutter.


### Auto-invoke Skills

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Generate Flutter features enforcing Domain, Data, and Presentation separation with BLoC and Dartz.| `clean-architecture` |

### Running Tests

```bash
# Unit and widget tests
flutter test

# With coverage (70% minimum enforced in CI)
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# E2E setup and run (web)
flutter build web --release --pwa-strategy none --target lib/main_test.dart
npm run test:e2e

# Integration tests (Android)
flutter drive --driver=test_driver/main_test.dart --target=integration_test/auth_flow_test.dart -d android
```

### Mocking

- Uses **mockito** with `build_runner` for mock generation
- Firebase mocks via `firebase_auth_mocks` package
- Run `dart run build_runner build` to regenerate mocks after adding `@GenerateMocks` annotations

## Environment Variables

Copy `.env.example` to `.env` and fill in values:

```
GOOGLE_OAUTH_CLIENT_ID=<your-google-oauth-client-id>
AZ_ACCESS_KEY=<your-aws-access-key>
AZ_SECRET_KEY=<your-aws-secret-key>
AZ_REGION=<your-aws-region>
```

Loaded at runtime via `flutter_dotenv`.

## CI/CD

Three GitHub Actions workflows in `.github/workflows/`:

| Workflow          | File              | Purpose                                    |
|-------------------|-------------------|--------------------------------------------|
| CI                | `ci.yml`          | Tests, coverage, build verification        |
| SonarCloud        | `sonarcloud.yml`  | Static analysis and quality gate           |
| Docs              | `docs-pages.yml`  | Documentation site deployment              |

### Quality Gates

- **SonarCloud**: Static analysis via `sonar-project.properties`
- **Codecov**: Coverage reporting with 70% minimum threshold
- **Deployment**: Docker (Nginx) to `poc-staging.cleteci.com`

## Coding Conventions

- Follow `flutter_lints` rules defined in `analysis_options.yaml`
- Feature folders under `lib/ui/{feature}/` with `view_model/` and `widgets/` subdirectories
- Services are registered in `service_locator.dart` and injected via GetIt
- Abstract service interfaces live in `shared/infrastructure/services/`
- Tests must mirror the `lib/` structure in `test/`
- Minimum 80% code coverage for all PRs

## Known Constraints

- `dependency_overrides` exist for `intl` (^0.19.0) and `built_value` (^8.10.1) due to version conflicts between AWS and Firebase packages
- OCR features use conditional imports for web-specific PDF rendering
- A `skills/clean-architecture/` skill exists but the project currently uses simpler MVVM with Provider (not flutter_bloc/Freezed as the skill suggests)
