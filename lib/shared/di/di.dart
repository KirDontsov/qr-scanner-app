import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/scanner/data/repositories/scan_repository_impl.dart';
import '../../features/scanner/domain/repositories/scan_repository.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  sl.registerSingleton<Dio>(ApiClient.createDio());

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>(), sl<FlutterSecureStorage>()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<ApiClient>(), sl<FlutterSecureStorage>()),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(sl<ApiClient>(), sl<FlutterSecureStorage>()),
  );

  sl.registerFactory<ScannerBloc>(
    () => ScannerBloc(sl<ScanRepository>()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl<ApiClient>(), sl<FlutterSecureStorage>()),
  );

  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl<SettingsRepository>()),
  );
}