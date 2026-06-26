# Aidora — API Integration Guide

## Architecture Overview

```
lib/
├── services/
│   ├── api_constants.dart       ← All endpoint URLs in one place
│   ├── api_service.dart         ← Core HTTP client (GET / POST / error handling)
│   ├── auth_service.dart        ← Login + Register refugee
│   ├── auth_storage.dart        ← Token storage (in-memory, swap for secure storage)
│   └── organization_service.dart ← All org-related API calls
├── models/
│   ├── organization_api_model.dart ← OrganizationCardModel, OrganizationDetailModel
│   └── request_model.dart           ← (existing)
└── views/
    ├── organizations_list_screen.dart  ← Fetches /api/organizations/cards/
    ├── guest_org_details_screen.dart   ← Fetches /api/organizations/<id>/
    ├── filter_screen.dart              ← Triggers /api/organizations/filter/<type>/
    ├── login_screen.dart               ← POST /api/auth/login/
    └── register_screen.dart            ← POST /register/refugee/
```

---

## API Endpoints Connected

| Screen | Method | Endpoint |
|--------|--------|----------|
| OrganizationsListScreen | GET | `/api/organizations/cards/` |
| FilterScreen → OrganizationsListScreen | GET | `/api/organizations/filter/<service_type>/` |
| GuestOrgDetailsScreen | GET | `/api/organizations/<id>/` |
| LoginScreen | POST | `/api/auth/login/` |
| RegisterScreen | POST | `/register/refugee/` |

---

## How to Switch to Production

Open `lib/services/api_constants.dart` and change ONE line:

```dart
// Local development:
static const String baseUrl = 'http://127.0.0.1:8000';

// Production:
static const String baseUrl = 'https://your-production-domain.com';
```

---

## Running Locally (Android Emulator)

Android emulator cannot reach `127.0.0.1` (that's the emulator itself).
Use your machine's local IP instead:

```dart
static const String baseUrl = 'http://10.0.2.2:8000';  // Android emulator
static const String baseUrl = 'http://127.0.0.1:8000';  // iOS simulator
```

For a real device on the same WiFi, use your machine's LAN IP (e.g. `192.168.x.x`).

---

## Token Storage (Upgrade Path)

Currently uses in-memory storage (`auth_storage.dart`).
Tokens are lost on app restart. To persist:

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

Then replace the body of `AuthStorage` with `FlutterSecureStorage` calls.

---

## Error Handling Pattern

Every API call returns a typed result object. Always check `.isSuccess`:

```dart
final result = await OrganizationService.instance.fetchOrganizations();

if (result.isSuccess) {
  // use result.organizations
} else {
  // show result.errorMessage
}
```

No try-catch needed in UI code — all errors are caught inside `ApiService`.

