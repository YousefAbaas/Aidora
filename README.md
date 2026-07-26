# Aidora — Humanitarian Aid Coordination Platform

<p align="center">
  <img src="img/aidora_icon.png" alt="Aidora Logo" width="120"/>
</p>

<p align="center">
  <strong>Connecting refugees with humanitarian organizations and volunteers</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Backend-Django%20REST-092E20?logo=django" alt="Django REST" />
  <img src="https://img.shields.io/badge/Auth-Simple%20JWT-FF6B35" alt="Simple JWT" />
  <img src="https://img.shields.io/badge/State-GetX-8B5CF6" alt="GetX" />
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen" alt="Version" />
  <img src="https://img.shields.io/badge/License-Proprietary-lightgrey" alt="License" />
</p>

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [User Roles](#user-roles)
4. [Architecture](#architecture)
   - [Project Structure](#project-structure)
   - [Layer Diagram](#layer-diagram)
   - [State Management](#state-management)
   - [Authentication & Token Lifecycle](#authentication--token-lifecycle)
   - [API Layer](#api-layer)
   - [Navigation Flow](#navigation-flow)
   - [Data Models](#data-models)
   - [Static Assets Strategy](#static-assets-strategy)
5. [Supported Organizations](#supported-organizations)
6. [Tech Stack](#tech-stack)
7. [Dependencies](#dependencies)
8. [Getting Started](#getting-started)
9. [Environment Configuration](#environment-configuration)
10. [Backend Integration](#backend-integration)
11. [Localization](#localization)
12. [Testing](#testing)
13. [Roadmap](#roadmap)
14. [Contributing](#contributing)
15. [License](#license)

---

## Overview

Aidora is a cross-platform Flutter application that bridges the gap between displaced communities and humanitarian organizations. Refugees can submit aid requests, track their status in real time, and connect directly with verified NGOs, while organizations and volunteers get a dedicated dashboard to manage, assign, and fulfill those requests efficiently.

The project consists of a Flutter client (this repository) and a Django REST Framework backend, connected through a JWT-secured API.

---

## Key Features

| Feature | Description |
|---|---|
| Secure Authentication | JWT-based login with proactive token refresh and OTP verification |
| Aid Requests | Refugees submit help requests tied to specific organizations and services |
| Organization Profiles | Detailed pages with mission, services, target groups, and impact gallery |
| Real-time Notifications | Local push notifications for request status updates |
| Location Awareness | Camp/sector location stored in the refugee profile with a map preview |
| QR Code Verification | Volunteers scan QR codes to verify and process aid delivery |
| Profile Management | Full refugee profile with household data, photo upload, and location |
| Multilingual UI | Arabic and English with runtime language switching |
| Guest Mode | Browse organizations and services without registration |
| Smart Search | Natural-language search bar for discovering aid services |

---

## User Roles

```
┌─────────────────────────────────────────────────────────┐
│                          Aidora                          │
├───────────────┬───────────────────┬──────────────────────┤
│    Refugee    │   Organization    │      Volunteer       │
├───────────────┼───────────────────┼──────────────────────┤
│ Register /    │ Dashboard         │ Registration form    │
│ Login         │ View requests     │ (5-step wizard)      │
│ Complete      │ Assign to         │ View assigned tasks  │
│ profile       │ volunteers        │ QR scan for delivery │
│ Browse orgs   │ Manage            │ confirmation         │
│ Submit        │ applications      │ Profile page         │
│ requests      │ Status updates    │ Request history       │
│ Track         │ Reports           │                       │
│ requests      │                   │                       │
│ View          │                   │                       │
│ notifications │                   │                       │
└───────────────┴───────────────────┴──────────────────────┘

┌───────────────┐
│     Guest     │
├───────────────┤
│ Browse orgs   │
│ View details  │
│ Prompted to   │
│ log in for    │
│ requests      │
└───────────────┘
```

---

## Architecture

Aidora follows a layered architecture with clear separation of concerns:

```
┌──────────────────────────────────────────────────────────────────┐
│                        UI Layer (Views)                          │
│   Screens · Widgets · Dialogs · Bottom Sheets · Navigation Bars  │
├──────────────────────────────────────────────────────────────────┤
│                   State Management (GetX)                        │
│   Controllers · Reactive State (Rx) · Dependency Injection       │
├──────────────────────────────────────────────────────────────────┤
│                        Service Layer                             │
│   API Services · Auth Service · Token Manager · Notifications    │
├──────────────────────────────────────────────────────────────────┤
│                         Data Layer                               │
│   Models · Auth Storage (SharedPreferences) · API Constants      │
├──────────────────────────────────────────────────────────────────┤
│                        Network Layer                             │
│   HTTP Client · JWT Headers · Token Refresh · Error Handling     │
├──────────────────────────────────────────────────────────────────┤
│                     Backend (Django REST)                        │
│   DRF Endpoints · Simple JWT · PostgreSQL · Media Storage         │
└──────────────────────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── main.dart                        # App entry point, GetX bindings, theme, locale
│
├── controllers/                     # GetX controllers — reactive state
│   ├── bottom_nav_controller.dart   # Active tab index for refugee bottom nav
│   ├── profile_controller.dart      # Refugee profile (single reactive source of truth)
│   ├── requests_controller.dart     # Aid request list state
│   ├── org_controller.dart          # Organization browsing state
│   ├── settings_controller.dart     # App settings (theme, language)
│   ├── form_controller.dart         # Multi-step form state (volunteer wizard)
│   ├── vol_controller.dart          # Volunteer-specific state
│   └── controller_two.dart          # Secondary organization dashboard controller
│
├── models/                          # Pure Dart data models
│   ├── organization.dart            # Static org model (id, name, subtitle, categories)
│   ├── organization_api_model.dart  # API org models (card, detail, service)
│   ├── service_model.dart           # Service type model {serviceType, icon}
│   ├── request_model.dart           # Aid request model (status, org, service, timestamps)
│   └── my_requests_model.dart       # Refugee's own request list model
│
├── services/                        # Business logic and external communication
│   ├── api_constants.dart           # All API endpoint strings (single source of truth)
│   ├── api_service.dart             # Base HTTP client with JWT injection & retry
│   ├── auth_service.dart            # Login, register, OTP, forgot/reset password
│   ├── auth_storage.dart            # SharedPreferences wrapper (tokens, role, userId)
│   ├── token_manager.dart           # JWT lifecycle: proactive refresh, deduplication
│   ├── profile_api_service.dart     # Refugee profile CRUD & image upload
│   ├── organization_service.dart    # Org cards, details, filter, services
│   ├── requests_api_service.dart    # Submit, list, detail, QR scan for requests
│   ├── services_api_service.dart    # Available services by organization
│   ├── notification_service.dart    # flutter_local_notifications setup & dispatch
│   ├── upload_helper.dart           # Conditional import: native vs. web file upload
│   ├── upload_helper_io.dart        # Native (iOS/Android) file upload implementation
│   ├── upload_helper_stub.dart      # Web stub for file upload
│   ├── platform_helper.dart         # Platform-conditional base URL selection
│   ├── platform_helper_io.dart      # Native platform base URL (device IP / emulator)
│   ├── platform_helper_stub.dart    # Web platform base URL
│   ├── web_http.dart                # XHR-based HTTP for Flutter Web (CORS)
│   └── web_http_stub.dart           # Native stub for web_http
│
├── views/                           # All screens, organized by role
│   ├── splash_screen.dart           # Boot screen — checks token, routes to correct role
│   ├── onboarding_screens.dart      # 3-page onboarding carousel (first launch)
│   ├── selection_screen.dart        # Role selection: Refugee / Organization / Guest
│   ├── login_screen.dart            # Login with role-aware routing on success
│   ├── register_screen.dart         # Refugee registration (step 1)
│   ├── signup_screen.dart           # Account creation (step 2)
│   ├── otp_verification_screen.dart # OTP code entry with resend timer
│   ├── forgot_password_screen.dart  # Password recovery (email entry)
│   ├── reset_password_screen.dart   # New password form (from deep link)
│   │
│   ├── main_screen.dart             # Refugee bottom nav shell (Home/Requests/Profile)
│   ├── home_screen.dart             # Refugee home: org cards, service filter, smart search
│   ├── profile_screen.dart          # Refugee profile: avatar, household, location map
│   ├── complete_profile_screen.dart # Guided profile completion (required for requests)
│   ├── my_requests_screen.dart      # Tabbed request list: Pending/Approved/Completed
│   ├── my_requests_list_screen.dart # Reusable list widget used inside my_requests_screen
│   ├── submit_new_request_screen.dart # New aid request form (org + service + details)
│   ├── request_details_screen.dart  # Single request detail with status timeline
│   ├── notifications_screen.dart    # Notification inbox
│   ├── settings_screen.dart         # App settings (language, theme)
│   │
│   ├── organizations_screen.dart    # Org list for logged-in refugee (static assets)
│   ├── organization_details_screen.dart # Org detail for refugee (mission, services, impact)
│   ├── organizations_list_screen.dart   # Org list for guests (with login prompt)
│   ├── guest_org_details_screen.dart    # Org detail for guests (static assets + services)
│   ├── filter_screen.dart           # Service category filter bottom sheet
│   ├── service_request_screen.dart  # Quick service-specific request screen
│   ├── welcome_screen.dart          # Post-login welcome screen
│   ├── qr_scanner_screen.dart       # Camera-based QR code scanner
│   ├── requests_dashboard_screen.dart # Admin/org request overview
│   ├── refugee_home_screen.dart     # Alternate refugee home layout
│   │
│   ├── org/                         # Organization dashboard screens
│   │   ├── org_navigation_bar.dart  # Org bottom nav shell
│   │   ├── org_one/                 # Dashboard tab (stats, overview)
│   │   ├── org_two/                 # Requests tab (pending, approved, rejected)
│   │   ├── org_three/               # Tasks tab (assigned volunteer tasks)
│   │   ├── org_four/                # Volunteer applications tab
│   │   ├── assign_task/             # Task assignment flow
│   │   └── update_status/           # Request status update flow
│   │
│   └── volunteer/                   # Volunteer screens
│       ├── form/                    # 5-step volunteer registration wizard
│       │   ├── volunteer_welcome.dart
│       │   ├── page_one.dart        # Personal info
│       │   ├── page_two.dart        # Availability
│       │   ├── page_three.dart      # Skills
│       │   ├── page_four.dart       # Organization preference
│       │   └── page_five.dart       # Review & submit
│       ├── my_request/              # Volunteer request tracking
│       │   ├── page_request.dart    # Main volunteer home (tabbed)
│       │   ├── approved.dart        # Approved tasks list
│       │   ├── rejected.dart        # Rejected applications list
│       │   └── pinput_example.dart  # PIN input utility
│       └── navigation/              # Volunteer main navigation
│           ├── vol_navigation_bar.dart
│           ├── vol_home_page.dart
│           ├── vol_all_task.dart
│           └── vol_profile_page.dart
│
├── widgets/                          # Reusable UI components
│   ├── ai_search_bar.dart           # Animated smart search input
│   ├── net_image.dart               # Cached network image with fallback
│   ├── org_initial_avatar.dart      # Text-based avatar fallback for organizations
│   ├── org_logo_avatar.dart         # Circular organization logo with border
│   ├── profile_avatar.dart          # Refugee profile photo widget
│   ├── vol_avatar.dart              # Volunteer avatar widget
│   ├── privacy_text.dart            # Privacy policy rich text widget
│   ├── web_img.dart                 # Web-optimized image (XHR-based)
│   └── web_img_stub.dart            # Native stub for web_img
│
└── utils/                            # App-wide utilities and constants
    ├── app_theme.dart                # Color palette, text styles, ThemeData
    ├── app_translations.dart         # AR/EN translation key-value maps
    ├── icon_mapper.dart              # Service icon name → IconData mapping
    ├── image_url_helper.dart         # URL normalization (relative → absolute)
    ├── organizations_data.dart       # Static org list (id, name, subtitle, categories)
    └── snack_helper.dart             # Standardized GetX snackbar helpers
```

### Layer Diagram

```
User Action
     │
     ▼
┌─────────────┐   observes Rx    ┌────────────────────┐
│    View     │◄─────────────────│   GetX Controller  │
│  (Screen)   │──── calls ──────►│  (Business Logic)  │
└─────────────┘                  └──────────┬─────────┘
                                             │ calls
                                             ▼
                                  ┌────────────────────┐
                                  │  Service / API      │
                                  │  (HTTP + JWT)        │
                                  └──────────┬─────────┘
                                             │ JSON
                                             ▼
                                  ┌────────────────────┐
                                  │   Data Model         │
                                  │  (fromJson / toJson) │
                                  └──────────┬─────────┘
                                             │ persisted
                                             ▼
                                  ┌────────────────────┐
                                  │ SharedPreferences    │
                                  │  (AuthStorage)       │
                                  └────────────────────┘
```

### State Management

Aidora uses **GetX** for state management, dependency injection, and navigation.

| Controller | Responsibility | Scope |
|---|---|---|
| `ProfileController` | Refugee profile — single reactive source of truth | Permanent (app lifetime) |
| `BottomNavController` | Active tab index for refugee shell | Permanent |
| `RequestsController` | Aid request list, status filters | Permanent |
| `OrgController` | Organization list & filter state | Permanent |
| `SettingsController` | Language, theme preferences | Permanent |
| `FormController` | Volunteer multi-step wizard state | Per-flow |
| `VolController` | Volunteer home & task state | Permanent |

Pattern used in views:

```dart
// Reactive rebuild on any profile change
Obx(() => Text(controller.profile.value?.name ?? ''));

// One-time read (no rebuild needed)
final profile = Get.find<ProfileController>().profile.value;
```

### Authentication & Token Lifecycle

Aidora uses Django Simple JWT with an access/refresh token pair.

```
┌──────────┐   POST /api/auth/login/   ┌─────────────────┐
│  Client  │──────────────────────────►│  Django Backend │
│          │◄──── {access, refresh} ───│                 │
└──────────┘                           └─────────────────┘
      │
      │  Store in SharedPreferences
      ▼
┌────────────────────────────────────────────────────────┐
│                     TokenManager                        │
│                                                          │
│  On every API call:                                     │
│  1. Decode JWT `exp` from the base64 payload             │
│  2. If seconds_remaining < 120 → proactive refresh       │
│  3. If 401/403 received → force refresh + retry          │
│  4. Concurrent refresh calls → deduplicated (1 request)  │
│  5. Refresh expired → clear storage → return to login    │
└────────────────────────────────────────────────────────┘
      │
      │  AuthStorage (SharedPreferences)
      ▼
access_token   — injected as Bearer token on every request
refresh_token  — used only for refresh calls
role           — 'refugee' | 'org' | 'volunteer'
user_id        — used for profile & volunteer QR endpoints
```

Role-based routing on splash:

```
SplashScreen boots
   │
   ├─ Token exists? ── No ──► OnboardingScreen
   │
   └─ Yes
        ├─ role = 'refugee'   ──► MainScreen (Home tab)
        ├─ role = 'org'       ──► OrgNavigationBar
        └─ role = 'volunteer' ──► PageRequest
```

### API Layer

All endpoints are defined in a single source of truth, `ApiConstants`:

```dart
// Base URL resolves at runtime based on platform:
// Android emulator  → http://10.0.2.2:8000
// iOS simulator     → http://127.0.0.1:8000
// Real device       → http://<realDeviceIp>:8000
// Production        → https://api.aidora.app

ApiConstants.organizationCards       // GET   /api/organizations/cards/
ApiConstants.organizationDetail(id)  // GET   /api/organizations/{id}/
ApiConstants.login                   // POST  /api/auth/login/
ApiConstants.createRequest(orgId)    // POST  /api/requests/{orgId}/create-request/
ApiConstants.myRequests              // GET   /api/requests/my-requests/
ApiConstants.completeProfile         // PATCH /api/auth/refugees/complete-profile/
```

Request flow:

```
Service.fetchData()
   │
   ├─ TokenManager.getValidAccessToken()   — refreshes if needed
   │
   ├─ http.get(url, headers: {Authorization: 'Bearer <token>'})
   │
   ├─ 200      ──► parse JSON → Model.fromJson() → return
   ├─ 401      ──► TokenManager.forceRefresh() → retry once
   └─ 4xx/5xx  ──► throw / return error result
```

### Navigation Flow

```
SplashScreen
   │
   └──► OnboardingScreen1 → 2 → 3
            │
            └──► SelectionScreen
                    │
        ┌───────────┼───────────────┐
        ▼           ▼               ▼
     Refugee    Organization       Guest
        │           │                │
   LoginScreen  LoginScreen  OrganizationsListScreen
        │           │                │
  RegisterScreen  OrgNavBar   GuestOrgDetailsScreen
        │
  OtpVerificationScreen
        │
  CompleteProfileScreen (if profile incomplete)
        │
        ▼
  MainScreen (Refugee Shell)
        │
   ┌────┼─────────┐
   ▼    ▼         ▼
 Home Requests  Profile
        │
   MyRequestsScreen
        │
   RequestDetailsScreen

  OrganizationsScreen
        │
   OrganizationDetailsScreen
        │
   SubmitNewRequestScreen
```

### Data Models

**`OrganizationCardModel`** — used in list views

```dart
{
  id: int,           // Django primary key
  name: String,      // e.g. "UNICEF"
  logo: String,      // URL (unused — local assets are used instead)
  subtitle: String,  // e.g. "Humanitarian Organization"
}
```

**`OrganizationDetailModel`** — used in detail views

```dart
{
  id: int,
  name: String,
  logo: String,
  services: List<OrgService>,   // [{id, name, icon}]
  impactImage1: String?,        // unused — local assets are used instead
  impactImage2: String?,        // unused — local assets are used instead
}
```

**`RequestModel`** — aid request

```dart
{
  id: int,
  orgName: String,
  serviceName: String,
  status: String,          // 'pending' | 'approved' | 'completed' | 'rejected'
  urgencyLevel: String,
  familyMembers: int,
  description: String,
  createdAt: DateTime,
}
```

**`Organization`** — static local model

```dart
{
  id: String,         // 'unicef' | 'intersos' | 'wfp' | 'unhcr' | 'who' | 'red_crescent'
  name: String,
  subtitle: String,
  categories: List<String>,
}
```

### Static Assets Strategy

To ensure reliable image display independent of server availability, all organization visuals are bundled as local assets:

```
img/
├── org_unicef.png          # Organization logo (list + detail header)
├── org_intersos.png
├── org_wfp.png
├── org_unhcr.png
├── org_who.png
├── org_red_crescent.png
│
├── impact_unicef_1.png     # "Our Impact" gallery (2 images per organization)
├── impact_unicef_2.png
├── impact_intersos_1.png
├── impact_intersos_2.png
├── impact_wfp_1.png
├── impact_wfp_2.png
├── impact_unhcr_1.png
├── impact_unhcr_2.png
├── impact_who_1.png
├── impact_who_2.png
├── impact_red_crescent_1.png
├── impact_red_crescent_2.png
│
├── map_location.png        # Static map preview in the refugee profile
└── food_basket.png         # Service icon asset
```

Organization name → asset key resolution:

```dart
String _orgKey(String name) {
  final s = name.toLowerCase();
  if (s.contains('unicef'))                          return 'unicef';
  if (s.contains('intersos'))                        return 'intersos';
  if (s.contains('wfp') || s.contains('food prog'))   return 'wfp';
  if (s.contains('unhcr'))                            return 'unhcr';
  if (s.contains('who') || s.contains('health org'))  return 'who';
  if (s.contains('red') && s.contains('crescent'))    return 'red_crescent';
  return s.replaceAll(' ', '_');
}

// Usage: Image.asset('img/org_${_orgKey(org.name)}.png')
```

---

## Supported Organizations

| Organization | Asset Key | Logo | Impact Images |
|---|---|---|---|
| UNICEF | `unicef` | `org_unicef.png` | `impact_unicef_1/2.png` |
| INTERSOS | `intersos` | `org_intersos.png` | `impact_intersos_1/2.png` |
| World Food Programme | `wfp` | `org_wfp.png` | `impact_wfp_1/2.png` |
| UNHCR | `unhcr` | `org_unhcr.png` | `impact_unhcr_1/2.png` |
| World Health Organization | `who` | `org_who.png` | `impact_who_1/2.png` |
| Red Crescent | `red_crescent` | `org_red_crescent.png` | `impact_red_crescent_1/2.png` |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x (Dart 3.4+) |
| State Management | GetX 4.6.6 |
| Backend | Django REST Framework |
| Authentication | Simple JWT (access + refresh tokens) |
| Token Storage | SharedPreferences |
| HTTP Client | `dart:http` with a custom JWT interceptor |
| Image Loading | `cached_network_image` + local assets |
| Notifications | `flutter_local_notifications` |
| QR Scanning | `mobile_scanner` |
| Typography | Google Fonts |
| Localization | GetX Translations (AR / EN) |
| Deep Links | `app_links` (password reset) |

---

## Dependencies

```yaml
dependencies:
  get: ^4.6.6                          # State management, navigation, DI
  intl: ^0.19.0                        # Date/number formatting
  mobile_scanner: ^6.0.0               # QR code camera scanning
  permission_handler: ^11.3.1          # Camera & notification permissions
  google_fonts: ^6.2.1                 # Typography
  flutter_svg: ^2.0.9                  # SVG icon rendering
  cached_network_image: ^3.4.1         # Network image caching
  http: ^1.2.0                         # HTTP client
  image_picker: ^1.1.2                 # Profile photo selection
  flutter_local_notifications: ^18.0.0 # Push notifications
  timezone: ^0.9.4                     # Notification scheduling
  url_launcher: ^6.3.1                 # External links (email, web)
  pinput: ^5.0.0                       # OTP PIN input field
  shared_preferences: ^2.3.3           # Local token & settings storage
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.4.0`
- Dart SDK `>=3.4.0`
- Android Studio or Xcode
- A running Django backend (see [Backend Integration](#backend-integration))

### Installation

```bash
# Clone the repository
git clone https://github.com/YousefAbaas/aidora.git
cd aidora/aidora_app

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Environment Configuration

Set the backend IP in `lib/services/api_constants.dart`:

```dart
// For physical device testing:
static const String _realDeviceIp = '192.168.1.100'; // your machine's local IP

// Emulators are auto-configured:
// Android → 10.0.2.2:8000
// iOS     → 127.0.0.1:8000

// For production:
static const String _realDeviceIp = 'api.aidora.app';
```

---

## Backend Integration

The Django backend must expose the following endpoint groups:

| Group | Base Path | Auth Required |
|---|---|---|
| Auth | `/api/auth/` | Partial |
| Organizations | `/api/organizations/` | No (cards/list) |
| Requests | `/api/requests/` | Yes |
| Volunteer | `/api/auth/volunteer/` | Yes |

**Required Django packages:**

```
djangorestframework
djangorestframework-simplejwt
django-cors-headers
Pillow  # media uploads
```

**Recommended JWT settings:**

```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': False,   # keep False to avoid the session-death bug
    'BLACKLIST_AFTER_ROTATION': False,
}
```

---

## Localization

The app supports **Arabic** and **English** with runtime switching via GetX Translations.

```dart
// Switch language at runtime
Get.updateLocale(const Locale('ar', 'SA')); // Arabic
Get.updateLocale(const Locale('en', 'US')); // English

// Usage in widgets
Text('request_help'.tr) // resolves to "Request Help" or "طلب مساعدة"
```

Translation keys are defined in `lib/utils/app_translations.dart`.

---

## Testing

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage
```

Key test files:

| File | Purpose |
|---|---|
| `test/api_endpoints_test.dart` | API URL construction tests |
| `test/model_parsing_test.dart` | JSON → Model parsing tests |
| `test/token_manager_test.dart` | JWT lifecycle tests |

---

## Roadmap

Planned improvements for upcoming releases:

- [ ] Push notifications via Firebase Cloud Messaging (replacing local-only notifications)
- [ ] In-app chat between refugees, organizations, and volunteers
- [ ] Offline-first support for request submission in low-connectivity areas
- [ ] Admin web dashboard for organization-level analytics and reporting
- [ ] Automated CI/CD pipeline (GitHub Actions) for build, test, and release
- [ ] Expanded language support beyond Arabic and English
- [ ] Unit and widget test coverage across all controllers and services

Contributions and suggestions toward any of these are welcome — see [Contributing](#contributing) below.

---

## Contributing

Contributions are welcome, whether it's a bug fix, a new feature, or an improvement to documentation.

1. **Fork** the repository and create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Follow the existing project structure** — controllers in `controllers/`, screens in `views/`, business logic in `services/`, and reusable UI in `widgets/`.
3. **Keep commits focused and descriptive** (e.g. `fix: resolve 401 on complete-profile endpoint`, not `update stuff`).
4. **Run tests before submitting**:
   ```bash
   flutter test
   ```
5. **Open a pull request** with a clear description of the change, the motivation behind it, and any relevant screenshots for UI changes.

### Reporting Issues

When filing a bug report, please include:

- Flutter/Dart version (`flutter --version`)
- Platform (Android, iOS, or Web) and device/emulator details
- Steps to reproduce, expected behavior, and actual behavior
- Relevant logs or screenshots

### Code Style

- Follow the [official Dart style guide](https://dart.dev/effective-dart).
- Run `dart format .` before committing.
- Prefer small, single-responsibility widgets and controllers over large monolithic files.

---

## License

This project was developed as part of a humanitarian aid initiative.
© 2026 Aidora Team — All rights reserved.
