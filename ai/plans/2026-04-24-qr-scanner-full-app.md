# Final Implementation Plan — QR Scanner App

**Date:** 2026-04-24  
**Task:** Full QR Scanner mobile app with backend integration (Rust/Axum/Postgres)

---

## Synthesis Summary
- **Confirmed:** Auth, Scanner, Backend phases as proposed
- **Modified:** Phase 1 - минимизировать зависимости до essentials; Phase 6 - тесты ДО implementation
- **Rejected:** Nothing - все фазы соответствуют требованиям

---

## Atomic Task Plan

### Phase 1: Foundation
- [ ] Настроить структуру проекта (features/auth, features/scanner, features/settings)
- [ ] Обновить pubspec.yaml: `flutter_bloc`, `dio`, `get_it`, `go_router`, `equatable`
- [ ] Создать DI контейнер (`lib/shared/di.dart`)
- [ ] Создать ApiClient с Dio (`lib/shared/network/`)
- [ ] Создать базовые error classes (`lib/shared/errors/`)
- [ ] Unit тесты для ApiClient

### Phase 2: Authentication
- [ ] Auth entity (`lib/features/auth/domain/`)
- [ ] AuthRepository interface + impl (`lib/features/auth/data/`)
- [ ] AuthCubit + states (`lib/features/auth/presentation/`)
- [ ] Login page UI
- [ ] JWT storage (`flutter_secure_storage`)
- [ ] Auth guard (redirect если не авторизован)
- [ ] Unit tests: AuthCubit 100%
- [ ] Widget tests: LoginPage

### Phase 3: Scanner
- [ ] Scan entity (date, user, qr_text, barcode_type, comment)
- [ ] ScanRepository + impl
- [ ] ScannerBloc + events/states
- [ ] Refactor ScannerPage → BlocBuilder/BlocListener
- [ ] Optional: Hive offline queue
- [ ] Unit tests: ScannerBloc 100%
- [ ] Widget tests: ScannerPage
- [ ] Integration test: scan → POST → verify

### Phase 4: Backend (Rust/Axum - существующий проект)
- [ ] Добавить таблицы `scans` и `settings` в существующую БД
- [ ] PostgreSQL schema:
  ```sql
  -- Таблица users уже существует:
  -- id, name, email, password, role, photo, verified, favourite, created_at, updated_at

  CREATE TABLE scans (
      id UUID PRIMARY KEY,
      user_id UUID REFERENCES users(id),
      qr_text TEXT NOT NULL,
      barcode_type TEXT,
      comment TEXT,
      scanned_at TIMESTAMP DEFAULT NOW()
  );

  CREATE TABLE settings (
      user_id UUID PRIMARY KEY REFERENCES users(id),
      google_sheets_id TEXT,
      access_token TEXT,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
  );
  ```
- [ ] `/auth/login` endpoint
- [ ] `/auth/refresh` endpoint
- [ ] `/scans` POST endpoint
- [ ] `/scans` GET endpoint (list user's scans)
- [ ] `/settings` PUT endpoint
- [ ] Unit + integration tests

### Phase 5: Settings + Google Sheets
- [ ] SettingsEntity + SettingsRepository
- [ ] SettingsCubit
- [ ] Settings page UI (Google Sheets ID input, test connection)
- [ ] Backend: sync endpoint
- [ ] Unit tests: SettingsCubit 100%
- [ ] Widget tests: SettingsPage

### Phase 6: Polish & Integration
- [ ] HomePage + bottom navigation
- [ ] History page (list past scans)
- [ ] Loading/error states everywhere
- [ ] `flutter analyze` + `flutter test` pass
- [ ] `flutter build ios` + `flutter build apk` succeed

---

## Success Criteria

### Automated
- [ ] `flutter analyze` passes with zero errors
- [ ] All unit tests pass (BLoC/Cubit: 100%)
- [ ] All widget tests pass
- [ ] Integration tests pass

### Manual
- [ ] Login/logout flow works
- [ ] Scanner → POST → backend saves
- [ ] Settings page saves/loads Google Sheets config
- [ ] iOS build succeeds
- [ ] Android build succeeds

---

## What We Are NOT Doing
- QR code generation (only scanning)
- Biometric authentication
- Push notifications
- Real-time WebSocket sync
- Dark mode
- i18n

---

## Key Risks

1. **Google Sheets OAuth complexity**  
   Risk: Full OAuth flow is complex  
   Mitigation: Start with user-provided access token

2. **JWT refresh race conditions**  
   Risk: Multiple concurrent requests trigger simultaneous refreshes  
   Mitigation: Mutex/lock pattern in ApiClient

3. **Offline queue conflicts**  
   Risk: Scans queued offline may conflict with server state  
   Mitigation: UUID for deduplication, `ON CONFLICT DO NOTHING`