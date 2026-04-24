import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  final String? googleSheetsId;
  final String? accessToken;

  const Settings({
    this.googleSheetsId,
    this.accessToken,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      googleSheetsId: json['google_sheets_id'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'google_sheets_id': googleSheetsId,
      'access_token': accessToken,
    };
  }

  Settings copyWith({
    String? googleSheetsId,
    String? accessToken,
  }) {
    return Settings(
      googleSheetsId: googleSheetsId ?? this.googleSheetsId,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  List<Object?> get props => [googleSheetsId, accessToken];
}