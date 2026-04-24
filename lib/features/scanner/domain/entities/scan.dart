import 'package:equatable/equatable.dart';

class Scan extends Equatable {
  final String? id;
  final String userId;
  final String qrText;
  final String? barcodeType;
  final String? comment;
  final DateTime scannedAt;

  const Scan({
    this.id,
    required this.userId,
    required this.qrText,
    this.barcodeType,
    this.comment,
    required this.scannedAt,
  });

  factory Scan.fromJson(Map<String, dynamic> json) {
    return Scan(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      qrText: json['qr_text'] as String,
      barcodeType: json['barcode_type'] as String?,
      comment: json['comment'] as String?,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'qr_text': qrText,
      'barcode_type': barcodeType,
      'comment': comment,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  Scan copyWith({
    String? id,
    String? userId,
    String? qrText,
    String? barcodeType,
    String? comment,
    DateTime? scannedAt,
  }) {
    return Scan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qrText: qrText ?? this.qrText,
      barcodeType: barcodeType ?? this.barcodeType,
      comment: comment ?? this.comment,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, qrText, barcodeType, comment, scannedAt];
}