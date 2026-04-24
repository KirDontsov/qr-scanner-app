import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScanDetected extends ScannerEvent {
  final String code;
  final String? barcodeType;

  const ScanDetected({required this.code, this.barcodeType});

  @override
  List<Object?> get props => [code, barcodeType];
}

class ScanSubmitted extends ScannerEvent {
  final String code;
  final String? barcodeType;
  final String? comment;

  const ScanSubmitted({
    required this.code,
    this.barcodeType,
    this.comment,
  });

  @override
  List<Object?> get props => [code, barcodeType, comment];
}

class LoadScans extends ScannerEvent {}

class ResetScanner extends ScannerEvent {}