import '../entities/settings.dart';

abstract class SettingsRepository {
  Future<Settings> getSettings();
  Future<Settings> saveSettings(Settings settings);
  Future<bool> testGoogleSheetsConnection(String sheetsId);
}