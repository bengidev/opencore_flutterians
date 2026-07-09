# OpenCore Flutterians

**Cross-platform mobile OpenCore — integrate AI models into your phone so getting work done stays in one place.**

OpenCore Flutterians is a Flutter app for Android and iOS. It brings frontier AI into a mobile-first workspace so you can plan, draft, and ship without juggling apps.

[![CI](https://github.com/bengidev/opencore_flutterians/actions/workflows/ci.yml/badge.svg)](https://github.com/bengidev/opencore_flutterians/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)

## Why OpenCore

Mobile work is fragmented. You bounce between notes, chat, browsers, and AI tabs — context slips away with every switch.

OpenCore is built around **perfection fusion**: keep the human in the loop while AI handles reasoning and generation inside a single permissioned workspace on your device.

| Pillar | What it means |
|--------|----------------|
| **Mobile-first** | Native Android and iOS from one Flutter codebase |
| **AI in context** | Talk to models where you already work |
| **Task-oriented** | Help finish real work, not just chat |
| **Local-aware** | Your device, your keys, your rules |

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) stable (3.x / Dart 3.12+)
- Xcode 16+ (for iOS)
- Android Studio / Android SDK (for Android)

### Run

```bash
cd opencore_flutterians
flutter pub get
flutter run
```

Pick a connected device or simulator when prompted.

### Checks

```bash
cd opencore_flutterians
flutter analyze
flutter test
```

### Platform builds

```bash
cd opencore_flutterians
flutter build apk --debug          # Android
flutter build ios --no-codesign    # iOS (no signing)
```

## Project layout

```
opencore_flutterians/             # repository root
├── opencore_flutterians/         # Flutter application
│   ├── lib/                      # Dart source
│   ├── android/                  # Android host
│   ├── ios/                      # iOS host
│   └── test/                     # Widget / unit tests
├── .github/workflows/            # CI (analyze, Android, iOS)
├── LICENSE                       # MIT
└── README.md
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Please follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

OpenCore Flutterians is released under the [MIT License](LICENSE).

Copyright (c) 2026 bengidev
