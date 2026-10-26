# Contributing

Thank you for your interest in contributing to this project. Please follow the guidelines below.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Run `flutter pub get` to install dependencies
4. Run `bash scripts/setup-hooks.sh` to install git hooks
5. Create a feature branch from `main`

## Development Setup

### Prerequisites
- Flutter SDK 3.24+
- Dart 3.5+
- Android SDK with API 24+ (for Android builds)
- Linux desktop build dependencies (for Linux builds)

### Running Locally
```bash
flutter pub get
flutter run -d linux    # Linux desktop
flutter run             # Android device
```

### Running Tests
```bash
flutter test
flutter analyze --no-fatal-infos
dart format --output=none --set-exit-if-changed .
```

## Code Guidelines

### Dart Style
- Use `dart format` before committing (enforced by pre-commit hook)
- Follow lint rules in `analysis_options.yaml`
- Use single quotes for strings
- Keep files under 150 lines — split into services/widgets if larger

### Architecture
- Services created in `main()` and passed via constructors
- Screens are StatefulWidgets, widgets are StatelessWidgets where possible
- Use `AppTheme` constants for colors and styles — no inline values
- Use `S.get(key, lang)` for all user-visible strings — no hardcoded text

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add prayer times screen
fix: Resolve audio playback overlap
docs: Update README with new features
style: Format dart files
refactor: Extract audio service from main
test: Add model unit tests
chore: Update dependencies
```

### Localization
When adding user-visible text:
1. Add the key to both `'en'` and `'ur'` maps in `lib/localization/app_strings.dart`
2. Use `S.get('key', lang)` in your widget
3. Never hardcode English or Urdu strings directly in widgets

## Pull Request Process

1. Ensure all tests pass and code is formatted
2. Update `app_strings.dart` if you added new UI text
3. Fill out the PR template completely
4. PRs require at least one approval before merging
5. CI must pass (analyze, test, build) before merge

## Issue Reporting

- Use the **Bug Report** template for bugs
- Use the **Feature Request** template for new features
- Check existing issues before creating duplicates

## Branch Naming

```
feat/short-description
fix/short-description
chore/short-description
docs/short-description
```
