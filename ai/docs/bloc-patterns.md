# BLoC Patterns for Flutter

## When to Use BLoC

| Scenario | Solution | Example |
|----------|----------|---------|
| Local UI state only | StatefulWidget | Form field, checkbox |
| Simple toggle/counter | Cubit | Theme toggle, counter |
| Complex async state | BLoC | Scanner, network calls |
| Global app state | BLoC at root | Auth, user preferences |

## Cubit Pattern (Simplest)

```dart
class ScannerCubit extends Cubit<ScannerState> {
  ScannerCubit() : super(ScannerInitial());

  void scanCode(String code) {
    // Synchronous update
    emit(ScannerScanned(code));
  }
}
```

## BLoC Pattern (Complex)

```dart
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc() : super(ScannerInitial()) {
    on<ScanDetected>(_onScanDetected);
  }

  Future<void> _onScanDetected(
    ScanDetected event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerLoading());
    try {
      final result = await _repository.process(event.code);
      emit(ScannerSuccess(result));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }
}
```

## Flutter-Specific Patterns

### 1. BlocProvider Usage
```dart
// Single BLoC
BlocProvider(
  create: (context) => ScannerBloc(),
  child: ScannerPage(),
)

// Multiple
MultiBlocProvider(
  providers: [
    BlocProvider(create: (ctx) => AuthBloc()),
    BlocProvider(create: (ctx) => ScannerCubit()),
  ],
  child: App(),
)
```

### 2. BlocBuilder for UI
```dart
BlocBuilder<ScannerBloc, ScannerState>(
  builder: (context, state) {
    if (state is ScannerLoading) {
      return CircularProgressIndicator();
    }
    return Text(state.code);
  },
)
```

### 3. BlocListener for Side Effects
```dart
BlocListener<ScannerBloc, ScannerState>(
  listener: (context, state) {
    if (state is ScannerSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: ${state.code}')),
      );
    }
  },
  child: ScannerPage(),
)
```

### 4. Repository Integration
```dart
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScannerRepository _repository;

  ScannerBloc({required ScannerRepository repository})
      : _repository = repository,
        super(ScannerInitial()) {
    on<ProcessCode>(_process);
  }

  // Use repository for data operations
}
```

## Testing BLoC

```dart
// Unit test
final bloc = ScannerBloc(repository: mockRepo);
bloc.add(ScanDetected('test-code'));
await Future.delayed(Duration.zero);
expect(bloc.state, ScannerSuccess('test-code'));
```

## Anti-Patterns
1. **Don't** use BLoC where Cubit suffices
2. **Don't** emit multiple states in single event (use single state)
3. **Don't** do heavy computation in emit (use await)
4. **Don't** forget to close bloc in dispose