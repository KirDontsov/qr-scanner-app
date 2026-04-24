import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsLoaded(const Settings()));
    }
  }

  Future<void> saveSettings({
    String? googleSheetsId,
    String? accessToken,
  }) async {
    emit(SettingsSaving());
    try {
      final settings = Settings(
        googleSheetsId: googleSheetsId,
        accessToken: accessToken,
      );
      final saved = await _repository.saveSettings(settings);
      emit(SettingsSaved(saved));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> testSheetsConnection(String sheetsId) async {
    emit(SheetsConnectionTesting());
    try {
      final success = await _repository.testGoogleSheetsConnection(sheetsId);
      if (success) {
        emit(SheetsConnectionSuccess());
      } else {
        emit(const SheetsConnectionFailed('Connection failed'));
      }
    } catch (e) {
      emit(SheetsConnectionFailed(e.toString()));
    }
  }
}