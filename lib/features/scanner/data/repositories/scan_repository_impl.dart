import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/network/api_client.dart';
import '../../../../shared/errors/exceptions.dart';
import '../../domain/entities/scan.dart';
import '../../domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  ScanRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Future<Scan> createScan(Scan scan) async {
    try {
      final userId = await _secureStorage.read(key: StorageKeys.userId);
      if (userId == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final scanWithUser = scan.copyWith(userId: userId);

      final response = await _apiClient.post(
        ApiConstants.scansEndpoint,
        data: scanWithUser.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Scan.fromJson(response.data['data']);
      }

      throw ServerException(message: 'Failed to create scan', statusCode: response.statusCode);
    } catch (e) {
      if (e is ServerException || e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Scan>> getScans() async {
    try {
      final response = await _apiClient.get(ApiConstants.scansEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Scan.fromJson(json)).toList();
      }

      throw ServerException(message: 'Failed to get scans', statusCode: response.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteScan(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.scansEndpoint}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete scan', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}