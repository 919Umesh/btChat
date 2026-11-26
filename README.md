# BT Chat

A peer-to-peer messaging app built with Flutter and Bluetooth Low Energy (BLE). Discover nearby devices, connect, and exchange text messages — no internet required. All conversations are stored locally on-device.

## Features

- **BLE Discovery & Connection** — Scan for nearby devices and connect directly over Bluetooth Low Energy.
- **Real-time Messaging** — Send and receive text messages with delivery status indicators (sending, sent, failed).
- **Offline Persistence** — Conversations and messages stored locally in SQLite with automatic retry for failed messages.
- **Smart Device Recognition** — Name-based conversation IDs handle BLE address rotation (iOS), so reconnecting to the same device resumes the existing conversation.
- **App Lifecycle Awareness** — BLE advertising starts/stops automatically when the app enters foreground/background.
- **Swipe to Delete** — Remove conversations with a swipe gesture and confirmation dialog.
- **Dark Mode** — Premium dark theme with indigo-violet accent palette.

## Screenshots

The app features a modern design system with:
- Gradient avatars with online status indicators
- iMessage-style chat bubbles (75% max width, asymmetric border radius)
- Animated scanning state with pulse radar effect
- Signal strength indicators on discovered devices
- Onboarding-style permissions page

## Requirements

- Flutter SDK (`^3.10.7`)
- Android or iOS physical device with BLE support (simulators have limited Bluetooth functionality)
- Bluetooth enabled and required permissions granted

## Getting Started

```sh
# Install dependencies
flutter pub get

# Run on a connected device
flutter run

# Or target a specific device
flutter devices
flutter run -d <device-id>
```

On launch, grant the requested permissions. From the **Messages** screen, tap **New Chat** to scan for nearby devices, then tap a discovered peer to open a chat. The other device must have BT Chat open and advertising for discovery to work.

## Platform Notes

### Android
- Declares BLE scan/connect/advertise permissions and legacy Bluetooth/location permissions for older Android versions.
- Adaptive launcher icon with indigo-violet background.

### iOS
- Bluetooth and location usage descriptions in `ios/Runner/Info.plist`.
- App icon with alpha channel removed for App Store compliance.

Permission behavior varies by OS version. Location permission is required for BLE device scanning on both platforms.

## Architecture

Clean architecture with feature-based organization:

```
lib/
├── core/
│   ├── constants/        App-wide constants (DB version, table names)
│   ├── di/               Dependency injection (GetIt)
│   ├── router/           Navigation (GoRouter)
│   ├── theme/            Material 3 theme with indigo-violet palette
│   └── utils/            Avatar colors, date formatting
├── features/
│   ├── chat/
│   │   ├── data/         BLE datasource, peripheral datasource, SQLite, repository impl
│   │   ├── domain/       Entities (Message, Conversation), repository contract, use cases
│   │   └── presentation/ Controllers, chat page, conversations page, message bubble
│   └── devices/
│       ├── data/         BLE discovery datasource, repository impl
│       ├── domain/       Device entity, repository contract, use cases
│       └── presentation/ Device scan page, permissions page
└── main.dart             App entry with lifecycle management
```

### Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_blue_plus` | BLE GATT client connections |
| `sqflite` | Local message & conversation storage |
| `provider` | State management (ChangeNotifier) |
| `get_it` | Service locator / dependency injection |
| `go_router` | Declarative routing |
| `fpdart` | Functional error handling (Either) |
| `permission_handler` | Runtime permission requests |
| `phosphor_flutter` | Icon set |

### BLE Communication

The app uses two BLE roles simultaneously:
- **Central (Client)** — via `flutter_blue_plus` to discover and connect to peers.
- **Peripheral (Server)** — via native `MethodChannel` (`com.example.chat_l/peripheral`) to advertise and accept incoming connections.

Messages are chunked for BLE MTU limits, reassembled on receive, and include the sender's device name in the payload for proper attribution.

## Build

```sh
# Static analysis
flutter analyze

# Run tests
flutter test

# Build APK
flutter build apk

# Build iOS (requires macOS + Xcode)
flutter build ios

# Regenerate app icons
dart run flutter_launcher_icons
```
