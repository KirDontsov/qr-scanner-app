import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner_flutter/features/scanner/domain/entities/scan.dart';
import 'package:qr_scanner_flutter/features/scanner/domain/repositories/scan_repository.dart';
import 'package:qr_scanner_flutter/features/scanner/presentation/bloc/scanner_bloc.dart';
import 'package:qr_scanner_flutter/features/scanner/presentation/bloc/scanner_event.dart';
import 'package:qr_scanner_flutter/features/scanner/presentation/bloc/scanner_state.dart';

class MockScanRepository extends Mock implements ScanRepository {}

void main() {
  late MockScanRepository mockRepository;
  late ScannerBloc scannerBloc;

  final testScan = Scan(
    id: 'test-scan-id',
    userId: 'test-user-id',
    qrText: 'http://example.com',
    barcodeType: 'qrCode',
    comment: 'Test comment',
    scannedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(testScan);
  });

  setUp(() {
    mockRepository = MockScanRepository();
    scannerBloc = ScannerBloc(mockRepository);
  });

  tearDown(() {
    scannerBloc.close();
  });

  group('ScannerBloc', () {
    test('initial state is ScannerInitial', () {
      expect(scannerBloc.state, isA<ScannerInitial>());
    });

    group('ScanDetected', () {
      blocTest<ScannerBloc, ScannerState>(
        'emits ScannerDetected when code is detected',
        build: () => scannerBloc,
        act: (bloc) => bloc.add(ScanDetected(code: 'test-code', barcodeType: 'qrCode')),
        expect: () => [
          isA<ScannerDetected>()
              .having((s) => s.code, 'code', 'test-code')
              .having((s) => s.barcodeType, 'barcodeType', 'qrCode'),
        ],
      );

      blocTest<ScannerBloc, ScannerState>(
        'emits ScannerDetected with null barcodeType when not provided',
        build: () => scannerBloc,
        act: (bloc) => bloc.add(ScanDetected(code: 'test-code')),
        expect: () => [
          isA<ScannerDetected>()
              .having((s) => s.code, 'code', 'test-code')
              .having((s) => s.barcodeType, 'barcodeType', null),
        ],
      );
    });

    group('ScanSubmitted', () {
      blocTest<ScannerBloc, ScannerState>(
        'emits [ScannerSubmitting, ScannerSuccess] on successful submit',
        build: () {
          when(() => mockRepository.createScan(any()))
              .thenAnswer((_) async => testScan);
          return scannerBloc;
        },
        act: (bloc) => bloc.add(const ScanSubmitted(
          code: 'test-code',
          barcodeType: 'qrCode',
          comment: 'Test comment',
        )),
        expect: () => [
          isA<ScannerSubmitting>(),
          isA<ScannerSuccess>().having((s) => s.scan.id, 'scan.id', 'test-scan-id'),
        ],
        verify: (_) {
          verify(() => mockRepository.createScan(any())).called(1);
        },
      );

      blocTest<ScannerBloc, ScannerState>(
        'emits [ScannerSubmitting, ScannerError] on failed submit',
        build: () {
          when(() => mockRepository.createScan(any()))
              .thenThrow(Exception('Network error'));
          return scannerBloc;
        },
        act: (bloc) => bloc.add(const ScanSubmitted(
          code: 'test-code',
          barcodeType: 'qrCode',
        )),
        expect: () => [
          isA<ScannerSubmitting>(),
          isA<ScannerError>(),
        ],
      );
    });

    group('LoadScans', () {
      blocTest<ScannerBloc, ScannerState>(
        'emits [ScannerLoading, ScansLoaded] on successful load',
        build: () {
          when(() => mockRepository.getScans())
              .thenAnswer((_) async => [testScan]);
          return scannerBloc;
        },
        act: (bloc) => bloc.add(LoadScans()),
        expect: () => [
          isA<ScannerLoading>(),
          isA<ScansLoaded>().having((s) => s.scans.length, 'length', 1),
        ],
        verify: (_) {
          verify(() => mockRepository.getScans()).called(1);
        },
      );

      blocTest<ScannerBloc, ScannerState>(
        'emits [ScannerLoading, ScannerError] on failed load',
        build: () {
          when(() => mockRepository.getScans())
              .thenThrow(Exception('Network error'));
          return scannerBloc;
        },
        act: (bloc) => bloc.add(LoadScans()),
        expect: () => [
          isA<ScannerLoading>(),
          isA<ScannerError>(),
        ],
      );

      blocTest<ScannerBloc, ScannerState>(
        'emits [ScannerLoading, ScansLoaded] with empty list when no scans',
        build: () {
          when(() => mockRepository.getScans()).thenAnswer((_) async => []);
          return scannerBloc;
        },
        act: (bloc) => bloc.add(LoadScans()),
        expect: () => [
          isA<ScannerLoading>(),
          isA<ScansLoaded>().having((s) => s.scans.isEmpty, 'isEmpty', true),
        ],
      );
    });

    group('ResetScanner', () {
      blocTest<ScannerBloc, ScannerState>(
        'emits ScannerReady when reset',
        build: () => scannerBloc,
        act: (bloc) => bloc.add(ResetScanner()),
        expect: () => [isA<ScannerReady>()],
      );
    });
  });
}