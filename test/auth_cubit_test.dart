import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner_flutter/features/auth/domain/entities/user.dart';
import 'package:qr_scanner_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:qr_scanner_flutter/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:qr_scanner_flutter/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthCubit authCubit;

  final testUser = User(
    id: 'test-id',
    name: 'Test User',
    email: 'test@test.com',
    role: 'user',
    verified: true,
    favourite: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(testUser);
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    authCubit = AuthCubit(mockRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('checkAuth', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is authenticated',
        build: () {
          when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => true);
          when(() => mockRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuth(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having((s) => s.user.id, 'user.id', 'test-id'),
        ],
        verify: (_) {
          verify(() => mockRepository.isAuthenticated()).called(1);
          verify(() => mockRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is not authenticated',
        build: () {
          when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => false);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuth(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when getCurrentUser returns null',
        build: () {
          when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => true);
          when(() => mockRepository.getCurrentUser())
              .thenAnswer((_) async => null);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuth(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on exception',
        build: () {
          when(() => mockRepository.isAuthenticated())
              .thenThrow(Exception('Network error'));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuth(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
      );
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful login',
        build: () {
          when(() => mockRepository.login(any(), any()))
              .thenAnswer((_) async => testUser);
          return authCubit;
        },
        act: (cubit) => cubit.login('test@test.com', 'password'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having((s) => s.user.id, 'user.id', 'test-id'),
        ],
        verify: (_) {
          verify(() => mockRepository.login('test@test.com', 'password')).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failed login',
        build: () {
          when(() => mockRepository.login(any(), any()))
              .thenThrow(Exception('Invalid credentials'));
          return authCubit;
        },
        act: (cubit) => cubit.login('test@test.com', 'wrong password'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on successful logout',
        build: () {
          when(() => mockRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(() => mockRepository.logout()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failed logout',
        build: () {
          when(() => mockRepository.logout())
              .thenThrow(Exception('Logout failed'));
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });
  });
}