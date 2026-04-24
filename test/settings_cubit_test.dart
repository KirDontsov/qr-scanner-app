import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner_flutter/features/settings/domain/entities/settings.dart';
import 'package:qr_scanner_flutter/features/settings/domain/repositories/settings_repository.dart';
import 'package:qr_scanner_flutter/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:qr_scanner_flutter/features/settings/presentation/bloc/settings_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsCubit settingsCubit;

  const testSettings = Settings(
    googleSheetsId: 'test-sheets-id',
    accessToken: 'test-token',
  );

  setUpAll(() {
    registerFallbackValue(testSettings);
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    settingsCubit = SettingsCubit(mockRepository);
  });

  tearDown(() {
    settingsCubit.close();
  });

  group('SettingsCubit', () {
    test('initial state is SettingsInitial', () {
      expect(settingsCubit.state, isA<SettingsInitial>());
    });

    group('loadSettings', () {
      blocTest<SettingsCubit, SettingsState>(
        'emits [SettingsLoading, SettingsLoaded] on successful load',
        build: () {
          when(() => mockRepository.getSettings())
              .thenAnswer((_) async => testSettings);
          return settingsCubit;
        },
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          isA<SettingsLoading>(),
          isA<SettingsLoaded>()
              .having((s) => s.settings.googleSheetsId, 'googleSheetsId', 'test-sheets-id'),
        ],
        verify: (_) {
          verify(() => mockRepository.getSettings()).called(1);
        },
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [SettingsLoading, SettingsLoaded] with default on error',
        build: () {
          when(() => mockRepository.getSettings())
              .thenThrow(Exception('Network error'));
          return settingsCubit;
        },
        act: (cubit) => cubit.loadSettings(),
        expect: () => [
          isA<SettingsLoading>(),
          isA<SettingsLoaded>()
              .having((s) => s.settings, 'settings', const Settings()),
        ],
      );
    });

    group('saveSettings', () {
      blocTest<SettingsCubit, SettingsState>(
        'emits [SettingsSaving, SettingsSaved] on successful save',
        build: () {
          when(() => mockRepository.saveSettings(any()))
              .thenAnswer((_) async => testSettings);
          return settingsCubit;
        },
        act: (cubit) => cubit.saveSettings(
          googleSheetsId: 'test-sheets-id',
          accessToken: 'test-token',
        ),
        expect: () => [
          isA<SettingsSaving>(),
          isA<SettingsSaved>(),
        ],
        verify: (_) {
          verify(() => mockRepository.saveSettings(any())).called(1);
        },
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [SettingsSaving, SettingsError] on failed save',
        build: () {
          when(() => mockRepository.saveSettings(any()))
              .thenThrow(Exception('Save failed'));
          return settingsCubit;
        },
        act: (cubit) => cubit.saveSettings(
          googleSheetsId: 'test-sheets-id',
        ),
        expect: () => [
          isA<SettingsSaving>(),
          isA<SettingsError>(),
        ],
      );
    });

    group('testSheetsConnection', () {
      blocTest<SettingsCubit, SettingsState>(
        'emits [SheetsConnectionTesting, SheetsConnectionSuccess] on success',
        build: () {
          when(() => mockRepository.testGoogleSheetsConnection(any()))
              .thenAnswer((_) async => true);
          return settingsCubit;
        },
        act: (cubit) => cubit.testSheetsConnection('test-sheets-id'),
        expect: () => [
          isA<SheetsConnectionTesting>(),
          isA<SheetsConnectionSuccess>(),
        ],
        verify: (_) {
          verify(() => mockRepository.testGoogleSheetsConnection('test-sheets-id')).called(1);
        },
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [SheetsConnectionTesting, SheetsConnectionFailed] on failure',
        build: () {
          when(() => mockRepository.testGoogleSheetsConnection(any()))
              .thenAnswer((_) async => false);
          return settingsCubit;
        },
        act: (cubit) => cubit.testSheetsConnection('invalid-id'),
        expect: () => [
          isA<SheetsConnectionTesting>(),
          isA<SheetsConnectionFailed>(),
        ],
      );

      blocTest<SettingsCubit, SettingsState>(
        'emits [SheetsConnectionTesting, SheetsConnectionFailed] on exception',
        build: () {
          when(() => mockRepository.testGoogleSheetsConnection(any()))
              .thenThrow(Exception('Connection error'));
          return settingsCubit;
        },
        act: (cubit) => cubit.testSheetsConnection('test-id'),
        expect: () => [
          isA<SheetsConnectionTesting>(),
          isA<SheetsConnectionFailed>(),
        ],
      );
    });
  });
}