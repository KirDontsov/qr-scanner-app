import 'package:equatable/equatable.dart';
import '../../domain/entities/settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Settings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsSaving extends SettingsState {}

class SettingsSaved extends SettingsState {
  final Settings settings;

  const SettingsSaved(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SheetsConnectionTesting extends SettingsState {}

class SheetsConnectionSuccess extends SettingsState {}

class SheetsConnectionFailed extends SettingsState {
  final String message;

  const SheetsConnectionFailed(this.message);

  @override
  List<Object?> get props => [message];
}