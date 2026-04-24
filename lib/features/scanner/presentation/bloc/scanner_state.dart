import 'package:equatable/equatable.dart';
import '../../domain/entities/scan.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerReady extends ScannerState {}

class ScannerScanning extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScannerDetected extends ScannerState {
  final String code;
  final String? barcodeType;

  const ScannerDetected({required this.code, this.barcodeType});

  @override
  List<Object?> get props => [code, barcodeType];
}

class ScannerSubmitting extends ScannerState {
  final String code;
  final String? barcodeType;
  final String? comment;

  const ScannerSubmitting({
    required this.code,
    this.barcodeType,
    this.comment,
  });

  @override
  List<Object?> get props => [code, barcodeType, comment];
}

class ScannerSuccess extends ScannerState {
  final Scan scan;

  const ScannerSuccess(this.scan);

  @override
  List<Object?> get props => [scan];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScansLoaded extends ScannerState {
  final List<Scan> scans;

  const ScansLoaded(this.scans);

  @override
  List<Object?> get props => [scans];
}