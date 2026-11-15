# Aidora — API Integration Guide

This guide describes the current integration boundary between the Flutter client and Django REST Framework backend. For the system-level view, see [Architecture Overview](docs/architecture.md).

## Integration architecture

```text
Flutter UI
   ↓
GetX Controllers
   ↓
Client Services / ApiService
   ↓  HTTPS · REST · JSON · JWT
Django REST Framework
   ↓
Django ORM
   ↓
PostgreSQL
```

## Client API layer

The Flutter client centralises HTTP communication in `lib/services/api_service.dart` and related service classes.

Relevant files include:

| File | Responsibility |
|---|---|
| `lib/services/api_constants.dart` | API base URL and endpoint constants |
| `lib/services/api_service.dart` | HTTP methods, response parsing, error handling and authenticated requests |
| `lib/services/auth_service.dart` | Authentication-related operations |
| `lib/services/auth_storage.dart` | Persistent local storage for session tokens and user metadata |
| `lib/services/token_manager.dart` | Access-token lifecycle and refresh coordination |
| `lib/models/` | Typed client-side data models |

The exact set of service files may evolve as the application changes.

## Authentication and token storage

The current Flutter implementation stores access and refresh tokens using the `shared_preferences` package through `AuthStorage`. `TokenManager` coordinates access-token validity and refresh behaviour, while `ApiService` attaches bearer tokens to authenticated requests.

**Security note:** SharedPreferences provides persistence but should not be described as encrypted secure storage. For a security-sensitive production deployment, evaluate a platform-backed secure-storage solution and the associated migration, lifecycle, and web-platform requirements.

Never paste real access tokens, refresh tokens, passwords, or production credentials into issues, documentation, screenshots, or commits.

## Backend API domains

The Django backend groups API functionality into these domains:

| Domain | Main purpose |
|---|---|
| Accounts | Registration, login, token refresh, OTP verification, profiles and password recovery |
| Organisations | Organisation discovery, profiles, services and organisation workflows |
| Service requests | Assistance request operations, volunteer tasks and QR-related workflows |

The backend source is under `backend/`. Consult its [README](backend/README.md) and URL configuration for the current endpoint definitions.

## Environment and base URL

The client base URL is configured in `lib/services/api_constants.dart`. Use the appropriate local or deployed API address for the environment being tested.

Do not commit environment-specific credentials or secrets. Avoid hard-coding private infrastructure values into public examples.

## Error handling

The API client centralises response parsing and network-error handling. Service methods should return structured results to their callers so presentation code can handle success and failure without embedding transport logic in widgets.

## Testing integration

The repository includes unit, widget, and integration tests under `test/`. Backend tests are maintained under `backend/` and its application modules.

Run the Flutter checks from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
```

Run backend checks using the environment and commands documented in [backend/README.md](backend/README.md).

## Documentation maintenance

Keep this guide aligned with the implementation. When endpoint names, authentication flows, token storage, or service boundaries change, update this document and the backend API documentation together.
