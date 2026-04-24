import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/network/api_client.dart';
import '../../../../shared/errors/exceptions.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient _apiClient;
  // ignore: unused_field - используется для future расширения
  final FlutterSecureStorage _secureStorage;

  SettingsRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Future<Settings> getSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.settingsEndpoint);

      if (response.statusCode == 200) {
        return Settings.fromJson(response.data['data'] ?? {});
      }

      throw ServerException(message: 'Failed to get settings', statusCode: response.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Settings> saveSettings(Settings settings) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.settingsEndpoint,
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        return Settings.fromJson(response.data['data'] ?? {});
      }

      throw ServerException(message: 'Failed to save settings', statusCode: response.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> testGoogleSheetsConnection(String sheetsId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sheetsSyncEndpoint,
        data: {'google_sheets_id': sheetsId, 'test': true},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}