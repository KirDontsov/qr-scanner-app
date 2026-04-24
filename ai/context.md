# QR Scanner Flutter App

## Project Overview
- **Name:** QR Scanner
- **Type:** Flutter Mobile Application
- **Core functionality:** Scan QR codes using device camera and display results

## Tech Stack
- **Framework:** Flutter 3.x
- **Language:** Dart
- **Key dependencies:**
  - `mobile_scanner` - QR code scanning
  - `flutter_test` - Testing

## Architecture
- **Pattern:** Simple MVC/StatefulWidget (current)
- **Recommended:** Clean Architecture with BLoC for complex features

## Project Structure
```
lib/
  main.dart           # Entry point, App widget, ScannerPage

test/
  widget_test.dart  # Widget tests
```

## Current State
- Single-file app in `lib/main.dart`
- No state management beyond local StatefulWidget
- No tests beyond default widget_test.dart
- No separate pages, widgets, or features directories

## Dependencies
See `pubspec.yaml`

## Build Commands
- `flutter build ios` - Build iOS
- `flutter build apk` - Build Android
- `flutter test` - Run tests
- `flutter analyze` - Run static analysis