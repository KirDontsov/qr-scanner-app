# QR Scanner

Мобильное приложение для сканирования QR-кодов с интеграцией с backend API.

## Функции

- Сканирование QR-кодов через камеру устройства
- Авторизация пользователей (JWT)
- История сканирований
- Настройки Google Sheets для экспорта
- Bottom navigation (3 вкладки)

## Технологии

- **Flutter** 3.x
- **Dart** 3.x
- **flutter_bloc** - управление состоянием
- **dio** - HTTP клиент
- **get_it** - внедрение зависимостей
- **mobile_scanner** - сканирование QR-кодов
- **flutter_secure_storage** - безопасное хранение токенов

## Структура проекта

```
lib/
├── main.dart                       # Точка входа
├── shared/
│   ├── di/di.dart              # Dependency Injection
│   ├── network/api_client.dart   # Dio HTTP клиент
│   ├── errors/exceptions.dart   # Обработка ошибок
│   └── constants/constants.dart  # Константы
└── features/
    ├── auth/                   # Авторизация
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── scanner/               # Сканер
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── settings/              # Настройки
        ├── data/
        ├── domain/
        └── presentation/
```

## Установка

```bash
flutter pub get
```

## Запуск

```bash
# Запуск на устройстве
flutter run

# Запуск на конкретном устройстве
flutter run -d <device-id>
```

## Тесты

```bash
# Запуск всех тестов
flutter test

# Статический анализ
flutter analyze
```

## API Endpoints

- `POST /api/auth/login` - Авторизация
- `POST /api/auth/refresh` - Обновление токена
- `GET /api/scans` - Получить список сканирований
- `POST /api/scans` - Создать сканирование
- `GET /api/settings` - Получить настройки
- `PUT /api/settings` - Сохранить настройки

## Build

```bash
# iOS
flutter build ios

# APK (Android)
flutter build apk --release
```

## Тесты - покрытие

| Компонент | Тесты |
|----------|-------|
| AuthCubit | 9 |
| ScannerBloc | 9 |
| SettingsCubit | 8 |
| **Всего** | **26** |

## Статус

- [x] flutter analyze - 0 issues
- [x] flutter test - all passed
- [x] iOS build - ready