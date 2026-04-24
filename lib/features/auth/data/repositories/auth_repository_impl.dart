import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/network/api_client.dart';
import '../../../../shared/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final loginResponse = LoginResponse.fromJson(response.data);

        await _secureStorage.write(
          key: StorageKeys.accessToken,
          value: loginResponse.token,
        );

        final userResponse = await _apiClient.get(ApiConstants.meEndpoint);
        final user = User.fromJson(userResponse.data['data']['user']);

        await _secureStorage.write(key: StorageKeys.userId, value: user.id);
        await _secureStorage.write(key: StorageKeys.userEmail, value: user.email);

        return user;
      }

      throw AuthException(message: 'Login failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.userEmail);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.read(key: StorageKeys.userId);
    final email = await _secureStorage.read(key: StorageKeys.userEmail);
    if (userId == null || email == null) return null;

    return User(
      id: userId,
      name: '',
      email: email,
      role: 'user',
      verified: false,
      favourite: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }
}