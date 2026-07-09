# Contributing

Thanks for your interest in OpenCore Flutterians.

## Development setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) stable.
2. Clone the repo and enter the app package:

   ```bash
   git clone https://github.com/bengidev/opencore_flutterians.git
   cd opencore_flutterians/opencore_flutterians
   flutter pub get
   ```

3. Run on a device or simulator:

   ```bash
   flutter run
   ```

## Before you open a PR

From `opencore_flutterians/`:

```bash
flutter analyze
flutter test
```

For platform changes, also verify a debug build:

```bash
flutter build apk --debug
flutter build ios --no-codesign
```

## Pull requests

- Keep changes focused and easy to review.
- Describe *why* the change exists, not only what files moved.
- Follow the existing Dart / Flutter style in the tree.
- Be kind — this project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting issues

Use [GitHub Issues](https://github.com/bengidev/opencore_flutterians/issues). Include Flutter version (`flutter --version`), target platform, and steps to reproduce when reporting bugs.
