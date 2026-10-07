# BT Chat

BT Chat is a Flutter peer-to-peer messaging app. It discovers nearby Bluetooth Low Energy (BLE) devices, connects to a peer, and exchanges text messages without requiring an internet connection. Conversations and message history are stored locally on the device.

## Features

- Scan for nearby BLE devices and connect to a peer.
- Send and receive text messages over a Bluetooth connection.
- View recent conversations and reopen a chat.
- Keep local conversation and message history in SQLite.
- Retry messages that fail to send and delete a conversation's local history.
- Light and dark Material themes.

The image button in the chat composer is currently a placeholder; only text messaging is implemented.

## Requirements

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml` (`^3.10.7`).
- Android or iOS device with Bluetooth Low Energy support. Bluetooth features should be exercised on physical devices; simulator support may be limited.
- Bluetooth enabled and the requested Bluetooth/location permissions granted.

## Run locally

```sh
flutter pub get
flutter run
```

To choose a connected device explicitly:

```sh
flutter devices
flutter run -d <device-id>
```

On launch, grant the permissions requested by the app. From the Messages screen, choose the Bluetooth search or add button to scan, then tap a discovered peer to open a chat. The other device needs to be available and advertising for discovery and connection to work.

## Platform notes

- **Android:** The app declares BLE scan/connect/advertise permissions and legacy Bluetooth/location permissions for older Android versions. Approve the runtime permissions when prompted and enable Bluetooth.
- **iOS:** Bluetooth and location usage descriptions are present in `ios/Runner/Info.plist`. Approve the system prompts and enable Bluetooth.

Permission and Bluetooth behavior can vary by OS version and device. The project currently requests location permission as part of device discovery.

## Architecture

The code is organized by feature and follows a layered structure:

```text
lib/
  core/                 Routing, dependency injection, theme, shared utilities
  features/
    chat/
      data/             Bluetooth and SQLite data sources, models, repository
      domain/           Entities, repository contract, use cases
      presentation/     Controllers, pages, widgets
    devices/
      data/             BLE discovery data source and repository
      domain/           Device entity, repository contract, use cases
      presentation/     Device scanning and permission screens
```

`get_it` wires dependencies, `provider` exposes controllers to the UI, `go_router` handles navigation, `flutter_blue_plus` provides BLE access, and `sqflite` stores chat data locally.

## Useful commands

```sh
flutter analyze
flutter test
flutter build apk
flutter build ios
```

An iOS build requires macOS and Xcode. Tests and builds should be run in an environment with the Flutter toolchain and the required platform tooling installed.
