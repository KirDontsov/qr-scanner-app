import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scan.dart';
import '../../domain/repositories/scan_repository.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScanRepository _repository;

  ScannerBloc(this._repository) : super(ScannerInitial()) {
    on<ScanDetected>(_onScanDetected);
    on<ScanSubmitted>(_onScanSubmitted);
    on<LoadScans>(_onLoadScans);
    on<ResetScanner>(_onReset);
  }

  void _onScanDetected(ScanDetected event, Emitter<ScannerState> emit) {
    emit(ScannerDetected(code: event.code, barcodeType: event.barcodeType));
  }

  Future<void> _onScanSubmitted(
    ScanSubmitted event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerSubmitting(
      code: event.code,
      barcodeType: event.barcodeType,
      comment: event.comment,
    ));

    try {
      final scan = Scan(
        userId: '',
        qrText: event.code,
        barcodeType: event.barcodeType,
        comment: event.comment,
        scannedAt: DateTime.now(),
      );

      final createdScan = await _repository.createScan(scan);
      emit(ScannerSuccess(createdScan));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  Future<void> _onLoadScans(LoadScans event, Emitter<ScannerState> emit) async {
    emit(ScannerLoading());
    try {
      final scans = await _repository.getScans();
      emit(ScansLoaded(scans));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  void _onReset(ResetScanner event, Emitter<ScannerState> emit) {
    emit(ScannerReady());
  }
}