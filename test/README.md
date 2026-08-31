# Aidora — Test Suite

Professional test coverage designed to demonstrate production-grade Flutter development skills.

---

## Structure

```
test/
├── helpers/
│   ├── fixtures.dart           # Centralised fake API responses (matches real Django JSON)
│   └── mock_api_service.dart   # @GenerateMocks annotations for Mockito
│
├── unit/
│   ├── models_test.dart        # 30+ tests: fromJson, toJson, edge-cases for all models
│   ├── auth_service_test.dart  # 11 tests: login, register, forgot password
│   └── requests_service_test.dart # 12 tests: dashboard, list, details, submit
│
├── widget/
│   ├── login_screen_test.dart      # 14 tests: rendering, validation, password toggle
│   └── dashboard_widget_test.dart  # 22 tests: dashboard + my requests screens
│
└── integration/
    └── app_flow_test.dart      # 6 tests: end-to-end login→dashboard flow
```

---

## Running Tests

```bash
# All tests
flutter test

# Specific layer
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# Single file
flutter test test/unit/models_test.dart

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Architecture: Dependency Injection for Tests

Every service that hits the network exposes **two injection points**:

### 1. `testInstance(ApiService api)` — for unit tests
```dart
final svc = RequestsApiService.testInstance(_FakeApi(...));
final result = await svc.fetchMyRequests();
```
Creates a fresh instance backed by your fake. No globals touched.

### 2. `overrideForTest(...)` / `resetOverride()` — for widget tests
```dart
setUp(() {
  AuthService.overrideForTest(_FakeApi(...));
  RequestsApiService.overrideForTest(RequestsApiService.testInstance(_FakeApi(...)));
});
tearDown(() {
  AuthService.resetOverride();
  RequestsApiService.resetOverride();
  Get.reset();
});
```
Replaces the singleton for the duration of the test. The screens call
`RequestsApiService.effective` which returns the override when set.

---

## What Each Layer Tests

### Unit tests (`test/unit/`)
- **No Flutter framework** — pure Dart, instant execution
- `RequestModel.fromJson` handles all 5 status variants
- `MyRequestsModel.fromJson` supports both new API shape and legacy test shape
- `ImageUrlHelper.fix()` correctly rewrites URLs for Web/Android/iOS
- `AuthService` routes to correct role after login
- `RequestsApiService` parses dashboard counts and filtered lists

### Widget tests (`test/widget/`)
- **Flutter test framework** — pumps real widgets with fakes injected
- `LoginScreen` renders correctly per role (refugee / volunteer / org)
- Form validation blocks API calls on empty fields
- Password visibility toggle works
- `RequestsDashboardScreen` renders all sections from API data
- `MyRequestsScreen` renders tab bar and card content

### Integration tests (`test/integration/`)
- **Full navigation flows** — from LoginScreen through to next screen
- Successful login navigates away from LoginScreen
- Wrong credentials shows error and stays on LoginScreen
- Role-specific UI verified per entry point

---

## Fixtures (`test/helpers/fixtures.dart`)

All fake data is production-realistic and matches the actual Django response shapes:

| Constant | Endpoint |
|---|---|
| `loginSuccessJson` | `POST /api/auth/login/` |
| `registerSuccessJson` | `POST /api/auth/register/refugee/` |
| `refugeeProfileJson` | `GET /api/auth/profile/refugee/` |
| `requestsListJson` | `GET /api/requests/list/` |
| `requestDetailsJson` | `GET /api/requests/<pk>/details/` |
| `orgCardsJson` | `GET /api/organizations/cards/` |
| `volunteerQrJson` | `GET /api/auth/volunteers/<id>/qr/` |

---

## Why This Matters

| Pattern | Benefit |
|---|---|
| **Fake over Mock** | No generated code, no fragile `when().thenReturn()` chains |
| **testInstance factory** | Clean DI without touching singletons in unit tests |
| **overrideForTest** | Singleton-safe injection for widget/integration tests |
| **Centralised fixtures** | One change updates all tests that use that response |
| **Three test layers** | Unit (fast) → Widget (realistic) → Integration (end-to-end) |
