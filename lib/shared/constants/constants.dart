class ApiConstants {
  static const String baseUrl = 'https://sunseven.ru/api';
  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/users/me';
  static const String refreshEndpoint = '/auth/refresh';
  static const String scansEndpoint = '/scans';
  static const String settingsEndpoint = '/settings';
  static const String sheetsSyncEndpoint = '/sheets/sync';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
}