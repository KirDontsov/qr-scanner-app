# Testing Guidelines for Flutter

## Test Types

| Type | Purpose | Location |
|------|---------|----------|
| Unit | Business logic, Cubit/BLoC | `test/unit/` |
| Widget | Widget rendering | `test/widget/` |
| Integration | Full user flows | `test/integration/` |

## Test Structure

```
test/
├── unit/
│   ├── scanner/
│   │   ├── scanner_bloc_test.dart
│   │   └── scanner_cubit_test.dart
├── widget/
│   ├── scanner_page_test.dart
│   └── result_display_test.dart
└── integration/
    └── scan_flow_test.dart
```

## Unit Tests (BLoC/Cubit)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('ScannerCubit', () {
    late ScannerCubit cubit;

    setUp(() {
      cubit = ScannerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is initial', () {
      expect(cubit.state, ScannerInitial());
    });

    blocTest<ScannerCubit, ScannerState>(
      'emits scanned state when scanCode is called',
      build: () => ScannerCubit(),
      act: (cubit) => cubit.scanCode('test-code'),
      expect: () => [ScannerScanned('test-code')],
    );
  });
}
```

## Widget Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays scanned value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScannerPage(scannedValue: 'test-code'),
      ),
    );

    expect(find.text('test-code'), findsOneWidget);
  });
}
```

## Testing Rules

1. **Test every public Cubit/BLoC method** — no exceptions
2. **Test widget rendering** — verify UI updates on state changes
3. **Use `blocTest`** for BLoC/Cubit testing
4. **Mock repositories** — use mocktail or Mockito

## Dependencies for Testing

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
```

## Run Tests

```bash
flutter test                 # All tests
flutter test test/unit/   # Unit tests only
flutter test --coverage   # With coverage
```

## Coverage Target
- Minimum: 70% for business logic
- BLoC/Cubit: 100%
- Widgets: Key paths tested

## Anti-Patterns to Avoid
1. **Don't** skip testing edge cases
2. **Don't** test implementation details (test behavior)
3. **Don't** forget to call `tearDown.close()`
4. **Don't** use real repositories in tests (mock them)