[12/07/2026 12:22 ص] Yousef Abbas: # Aidora — Humanitarian Aid Coordination Platform

<p align="center">
  <img src="img/aidora_icon.png" alt="Aidora Logo" width="120"/>
</p>

<p align="center">
  <strong>Connecting refugees with humanitarian organizations and volunteers</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart" />
  <img src="https://img.shields.io/badge/Backend-Django%20REST-092E20?logo=django" />
  <img src="https://img.shields.io/badge/Auth-Simple%20JWT-FF6B35" />
  <img src="https://img.shields.io/badge/State-GetX-8B5CF6" />
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen" />
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

---

## Overview

Aidora is a cross-platform Flutter application that bridges the gap between displaced communities and humanitarian organizations. The platform enables refugees to submit aid requests, track their status in real time, and connect directly with verified NGOs — while giving organizations and volunteers a dedicated dashboard to manage, assign, and fulfill those requests efficiently.

---

## Key Features

| Feature | Description |
|---|---|
| 🔐 Secure Auth | JWT-based login with proactive token refresh and OTP verification |
| 📋 Aid Requests | Refugees submit help requests tied to specific organizations and services |
| 🏢 Organization Profiles | Detailed pages with mission, services, target groups, and impact gallery |
| 📡 Real-time Notifications | Local push notifications for request status updates |
| 🗺️ Location Awareness | Camp/sector location stored in refugee profile with map preview |
| 📷 QR Code System | Volunteers use QR scanning to verify and process aid delivery |
| 👤 Profile Management | Full refugee profile with household data, photo upload, and location |
| 🌐 Multilingual | Arabic and English with runtime language switching |
| 🎭 Guest Mode | Browse organizations and services without registration |
| 🔍 AI-powered Search | Natural language search bar for discovering aid services |

---

## User Roles

`
┌─────────────────────────────────────────────────────────┐
│                        Aidora                           │
├───────────────┬──────────────────┬──────────────────────┤
│    Refugee    │   Organization   │      Volunteer       │
├───────────────┼──────────────────┼──────────────────────┤
│ • Register /  │ • Dashboard      │ • Registration form  │
│   Login       │ • View requests  │   (5-step wizard)    │
│ • Complete    │ • Assign to      │ • View assigned      │
│   profile     │   volunteers     │   tasks              │
│ • Browse orgs │ • Manage         │ • QR code scan for   │
│ • Submit      │   applications   │   delivery confirm   │
│   requests    │ • Status updates │ • Profile page       │
│ • Track       │ • Reports        │ • Request history    │
│   requests    │                  │                      │
│ • View        │                  │                      │
[12/07/2026 12:22 ص] Yousef Abbas: │   notifications│                 │                      │
└───────────────┴──────────────────┴──────────────────────┘
+
┌───────────────┐
│     Guest     │
├───────────────┤
│ • Browse orgs │
│ • View details│
│ • Prompted to │
│   login for   │
│   requests    │
└───────────────┘

---

## Architecture

Aidora follows a **layered architecture** with clear separation of concerns:

┌──────────────────────────────────────────────────────────────────┐
│                          UI Layer (Views)                         │
│   Screens ─ Widgets ─ Dialogs ─ Bottom Sheets ─ Navigation Bars  │
├──────────────────────────────────────────────────────────────────┤
│                     State Management (GetX)                       │
│   Controllers ─ Reactive State (Rx) ─ Dependency Injection        │
├──────────────────────────────────────────────────────────────────┤
│                        Service Layer                              │
│   API Services ─ Auth Service ─ Token Manager ─ Notifications     │
├──────────────────────────────────────────────────────────────────┤
│                         Data Layer                                │
│   Models ─ Auth Storage (SharedPreferences) ─ API Constants       │
├──────────────────────────────────────────────────────────────────┤
│                       Network Layer                               │
│   HTTP Client ─ JWT Headers ─ Token Refresh ─ Error Handling      │
├──────────────────────────────────────────────────────────────────┤
│                      Backend (Django REST)                         │
│   DRF Endpoints ─ Simple JWT ─ PostgreSQL ─ Media Storage          │
└──────────────────────────────────────────────────────────────────┘

---

### Project Structure

lib/
├── main.dart                        # App entry point, GetX bindings, theme, locale
│
├── controllers/                     # GetX controllers — reactive state
│   ├── bottom_nav_controller.dart   # Active tab index for refugee bottom nav
│   ├── profile_controller.dart      # Refugee profile (source of truth, reactive)
│   ├── requests_controller.dart     # Aid request list state
│   ├── org_controller.dart          # Organization browsing state
│   ├── settings_controller.dart     # App settings (theme, language)
│   ├── form_controller.dart         # Multi-step form state (volunteer wizard)
│   ├── vol_controller.dart          # Volunteer-specific state
│   └── Controller_Two.dart          # Secondary org dashboard controller
│
├── models/                          # Pure Dart data models
│   ├── organization.dart            # Static org model (id: String, name, subtitle, categories)
│   ├── organization_api_model.dart  # API org models (OrganizationCardModel, OrganizationDetailModel, OrgService)
│   ├── service_model.dart           # Service type model {serviceType, icon}
│   ├── request_model.dart           # Aid request model (status, org, service, timestamps)
│   └── my_requests_model.dart       # Refugee's own request list model
│
├── services/                        # Business logic & external communication
│   ├── api_constants.dart           # All API endpoint strings (single source of truth)
│   ├── api_service.dart             # Base HTTP client with JWT injection & retry
│   ├── auth_service.dart            # Login, register, OTP, forgot/reset password
│   ├── auth_storage.dart            # SharedPreferences wrapper (tokens, role, userId)
│   ├── token_manager.dart           # JWT lifecycle: proactive refresh, deduplication
│   ├── profile_api_service.dart     # Refugee profile CRUD & image upload
│   ├── organization_service.dart    # Org cards, details, filter, services
│   ├── requests_api_service.dart    # Submit, list, detail, QR scan for requests
│   ├── services_api_service.dart    # Available services by organization
[12/07/2026 12:22 ص] Yousef Abbas: │   ├── notification_service.dart   # flutter_local_notifications setup & dispatch
│   ├── upload_helper.dart           # Conditional import: native vs web file upload
│   ├── upload_helper_io.dart        # Native (iOS/Android) file upload implementation
│   ├── upload_helper_stub.dart      # Web stub for file upload
│   ├── platform_helper.dart         # Platform-conditional base URL selection
│   ├── platform_helper_io.dart      # Native platform base URL (device IP / emulator)
│   ├── platform_helper_stub.dart    # Web platform base URL
│   ├── web_http.dart                # XHR-based HTTP for Flutter Web (CORS)
│   └── web_http_stub.dart           # Native stub for web_http
│
├── views/                           # All screens organized by role
│   │
│   ├── splash_screen.dart           # Boot screen → checks token → routes to correct role
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
│   ├── home_screen.dart             # Refugee home: org cards + service filter + AI search
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
│   │   ├── org_fore/                # Volunteer applications tab
│   │   ├── assign_task/             # Task assignment flow
│   │   └── update_status/          # Request status update flow
│   │
│   └── volunteer/                   # Volunteer screens
│       ├── form/                    # 5-step volunteer registration wizard
│       │   ├── volunteer_welcome.dart
[12/07/2026 12:22 ص] Yousef Abbas: │       │   ├── page_one.dart        # Personal info
│       │   ├── page_two.dart        # Availability
│       │   ├── page_three.dart      # Skills
│       │   ├── page_fore.dart       # Organization preference
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
├── widgets/                         # Reusable UI components
│   ├── ai_search_bar.dart           # Animated AI-powered search input
│   ├── net_image.dart               # Cached network image with fallback
│   ├── org_initial_avatar.dart      # Text-based avatar fallback for orgs
│   ├── org_logo_avatar.dart         # Circular org logo with border
│   ├── profile_avatar.dart          # Refugee profile photo widget
│   ├── vol_avatar.dart              # Volunteer avatar widget
│   ├── privacy_text.dart            # Privacy policy rich text widget
│   ├── web_img.dart                 # Web-optimized image (XHR-based)
│   └── web_img_stub.dart            # Native stub for web_img
│
└── utils/                           # App-wide utilities and constants
├── app_theme.dart               # Color palette, text styles, ThemeData
├── app_translations.dart        # AR/EN translation key-value maps
├── icon_mapper.dart             # Service icon name → IconData mapping
├── image_url_helper.dart        # URL normalization (fix relative → absolute)
├── organizations_data.dart      # Static org list (id, name, subtitle, categories)
└── snack_helper.dart            # Standardized GetX snackbar helpers

---

### Layer Diagram

User Action
│
▼
┌─────────────┐     Observes Rx      ┌──────────────────┐
│    View     │◄─────────────────────│   GetX Controller │
│  (Screen)   │──── calls method ───►│  (Business Logic) │
└─────────────┘                      └────────┬─────────┘
│ calls
▼
┌──────────────────┐
│  Service / API   │
│  (HTTP + JWT)    │
└────────┬─────────┘
│ JSON
▼
┌──────────────────┐
│   Data Model     │
│  (fromJson / to) │
└────────┬─────────┘
│ persisted
▼
┌──────────────────┐
│ SharedPreferences│
│  (AuthStorage)   │
└──────────────────┘
`

---

### State Management

Aidora uses GetX for state management, dependency injection, and navigation.

| Controller | Responsibility | Scope |
|---|---|---|
| `ProfileController` | Refugee profile — single reactive source of truth | Permanent (app lifetime) |
| `BottomNavController` | Active tab index for refugee shell | Permanent |
| `RequestsController` | Aid request list, status filters | Permanent |
| `OrgController` | Organization list & filter state | Permanent |
| `SettingsController` | Language, theme preferences | Permanent |
| `FormController` | Volunteer multi-step wizard state | Per-flow |
| `VolController` | Volunteer home & task state | Permanent |
[12/07/2026 12:22 ص] Yousef Abbas: Pattern used in views:
// Reactive rebuild on any profile change
Obx(() => Text(controller.profile.value?.name ?? ''))

// One-time read (no rebuild needed)
final profile = Get.find<ProfileController>().profile.value;
---

### Authentication & Token Lifecycle

Aidora uses Django Simple JWT with access + refresh token pair.

┌──────────┐   POST /api/auth/login/   ┌────────────────┐
│  Client  │──────────────────────────►│  Django Backend │
│          │◄── {access, refresh} ─────│                 │
└──────────┘                           └────────────────┘
│
│  Store in SharedPreferences
▼
┌──────────────────────────────────────────────────────┐
│                    TokenManager                       │
│                                                       │
│  Every API call:                                      │
│  1. Decode JWT exp from base64 payload                │
│  2. If seconds_remaining < 120 → proactive refresh    │
│  3. If 401/403 received → force refresh + retry       │
│  4. Concurrent refresh calls → deduplicated (1 HTTP)  │
│  5. Refresh expired → clear storage → back to login   │
└──────────────────────────────────────────────────────┘
│
│  AuthStorage (SharedPreferences)
▼
access_token  ─── injected as Bearer in every request
refresh_token ─── used only for refresh calls
role          ─── 'refugee' | 'org' | 'volunteer'
user_id       ─── for profile & volunteer QR endpoints
Role-based routing on splash:
SplashScreen boots
│
├─ Token exists? ──NO──► OnboardingScreen
│
└─ YES
├─ role = 'refugee'    ──► MainScreen (Home tab)
├─ role = 'org'        ──► Orgnavigationbar
└─ role = 'volunteer'  ──► Pagerequest
---

### API Layer

All endpoints are defined in a single source of truth — ApiConstants:

// Base URL resolves at runtime based on platform:
// Android emulator  → http://10.0.2.2:8000
// iOS simulator     → http://127.0.0.1:8000
// Real device       → http://<_realDeviceIp>:8000
// Production        → https://api.aidora.app (configured)

ApiConstants.organizationCards      // GET  /api/organizations/cards/
ApiConstants.organizationDetail(id) // GET  /api/organizations/{id}/
ApiConstants.login                  // POST /api/auth/login/
ApiConstants.createRequest(orgId)   // POST /api/requests/{orgId}/createrequest/
ApiConstants.myRequests             // GET  /api/requests/my-requests/
ApiConstants.completeProfile        // PATCH /api/auth/refugees/complete-profile/
Request flow:
Service.fetchData()
│
├─ TokenManager.getValidAccessToken()  ← refresh if needed
│
├─ http.get(url, headers: {Authorization: Bearer <token>})
│
├─ 200 ──► parse JSON → Model.fromJson() → return
│
├─ 401 ──► TokenManager.forceRefresh() → retry once
│
└─ 4xx/5xx ──► throw / return error result
---

### Navigation Flow

SplashScreen
│
├──► OnboardingScreen1 → 2 → 3
│         │
│         └──► SelectionScreen
│                   │
│         ┌─────────┼───────────┐
│         ▼         ▼           ▼
│      Refugee    Organization  Guest
│         │         │           │
│      LoginScreen  LoginScreen OrganizationsListScreen
│         │         │               │
│      RegisterScreen  Orgnavbar  GuestOrgDetailsScreen
│         │
│      OtpVerificationScreen
│         │
│      CompleteProfileScreen (if profile incomplete)
│         │
└──►  MainScreen (Refugee Shell)
│
┌──────┼──────────┐
▼      ▼          ▼
Home  Requests   Profile
│      │
│   MyRequestsScreen
│      │
│   RequestDetailsScreen
│
OrganizationsScreen
│
OrganizationDetailsScreen
│
SubmitNewRequestScreen
---

### Data Models
[12/07/2026 12:22 ص] Yousef Abbas: #### OrganizationCardModel — used in list views
{
id: int,           // Django primary key
name: String,      // "UNICEF"
logo: String,      // URL (ignored — using local assets)
subtitle: String,  // "Humanitarian Organization"
}
#### OrganizationDetailModel — used in detail views
{
id: int,
name: String,
logo: String,
services: List<OrgService>,    // [{id, name, icon}]
impactImage1: String?,         // ignored — using local assets
impactImage2: String?,         // ignored — using local assets
}
#### RequestModel — aid request
{
id: int,
orgName: String,
serviceName: String,
status: String,           // 'pending' | 'approved' | 'completed' | 'rejected'
urgencyLevel: String,
familyMembers: int,
description: String,
createdAt: DateTime,
}
#### Organization — static local model
{
id: String,        // 'unicef' | 'intersos' | 'wfp' | 'unhcr' | 'who' | 'red_crescent'
name: String,
subtitle: String,
categories: List<String>,
}
---

### Static Assets Strategy

To ensure reliable image display independent of server availability, all organization visuals are bundled as local assets:

img/
├── org_unicef.png          ← Organization logo (shown in list + detail header)
├── org_intersos.png
├── org_wfp.png
├── org_unhcr.png
├── org_who.png
├── org_red_crescent.png
│
├── impact_unicef_1.png     ← Our Impact gallery (2 per org in detail screen)
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
├── map_location.png        ← Static map preview in refugee profile
└── food_basket.png         ← Service icon asset
Org name → asset key resolution:
String _orgKey(String name) {
final s = name.toLowerCase();
if (s.contains('unicef'))                          return 'unicef';
if (s.contains('intersos'))                        return 'intersos';
if (s.contains('wfp') || s.contains('food prog'))  return 'wfp';
if (s.contains('unhcr'))                           return 'unhcr';
if (s.contains('who') || s.contains('health org')) return 'who';
if (s.contains('red') && s.contains('crescent'))   return 'red_crescent';
return s.replaceAll(' ', '_');
}
// Usage: Image.asset('img/org_${_orgKey(org.name)}.png')
---

## Supported Organizations

| Organization | Asset Key | Logo | Impact Images |
|---|---|---|---|
| UNICEF | unicef | org_unicef.png | impact_unicef_1/2.png |
| INTERSOS | intersos | org_intersos.png | impact_intersos_1/2.png |
| World Food Programme | wfp | org_wfp.png | impact_wfp_1/2.png |
| UNHCR | unhcr | org_unhcr.png | impact_unhcr_1/2.png |
| World Health Organization | who | org_who.png | impact_who_1/2.png |
| Red Crescent | red_crescent | org_red_crescent.png | impact_red_crescent_1/2.png |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x (Dart 3.4+) |
| State Management | GetX 4.6.6 |
| Backend | Django REST Framework |
| Authentication | Simple JWT (access + refresh tokens) |
| Token Storage | SharedPreferences |
| HTTP Client | dart:http + custom JWT interceptor |
| Image Loading | cached_network_image + local assets |
| Notifications | flutter_local_notifications |
| QR Scanning | mobile_scanner |
| Fonts | Google Fonts |
| Localization | GetX Translations (AR / EN) |
| Deep Links | app_links (password reset) |

---

## Dependencies

`yaml
dependencies:
get: ^4.6.6                      # State management, navigation, DI
intl: ^0.19.0                    # Date/number formatting
[12/07/2026 12:22 ص] Yousef Abbas: mobile_scanner: ^6.0.0           # QR code camera scanning
permission_handler: ^11.3.1      # Camera & notification permissions
google_fonts: ^6.2.1             # Typography
flutter_svg: ^2.0.9              # SVG icon rendering
cached_network_image: ^3.4.1     # Network image caching
http: ^1.2.0                     # HTTP client
image_picker: ^1.1.2             # Profile photo selection
flutter_local_notifications: ^18.0.0 # Push notifications
timezone: ^0.9.4                 # Notification scheduling
url_launcher: ^6.3.1             # External links (email, web)
pinput: ^5.0.0                   # OTP PIN input field
shared_preferences: ^2.3.3      # Local token & settings storage

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.4.0`
- Dart SDK `>=3.4.0`
- Android Studio / Xcode
- Django backend running (see [Backend Integration](#backend-integration))

### Installation

bash
# Clone the repository
git clone https://github.com/your-org/aidora.git
cd aidora/aidora_app

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

### Build for Release

bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

---

## Environment Configuration

Set your backend IP in `lib/services/api_constants.dart`:

dart
// For physical device testing:
static const String _realDeviceIp = '192.168.1.100';  // your machine's local IP

// For emulator (auto-configured):
// Android → 10.0.2.2:8000
// iOS     → 127.0.0.1:8000

// For production:
static const String _realDeviceIp = 'api.aidora.app';

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
djangorestframework
djangorestframework-simplejwt
django-cors-headers
Pillow  (media uploads)

**JWT settings (recommended):**
python
SIMPLE_JWT = {
'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
'ROTATE_REFRESH_TOKENS': False,   # Keep False to avoid session death bug
'BLACKLIST_AFTER_ROTATION': False,
}

---

## Localization

The app supports **Arabic** and **English** with runtime switching via GetX Translations.

dart
// Switch language at runtime
Get.updateLocale(const Locale('ar', 'SA'));  // Arabic
Get.updateLocale(const Locale('en', 'US'));  // English

// Usage in widgets
Text('request_help'.tr)   // resolves to "Request Help" or "طلب مساعدة"

Translation keys are defined in `lib/utils/app_translations.dart`.

---

## Testing

bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Key test files
test/api_endpoints_test.dart    # API URL construction tests
test/model_parsing_test.dart    # JSON → Model parsing tests
test/token_manager_test.dart    # JWT lifecycle tests
`

---

## License

This project is developed as part of a humanitarian aid initiative.  
© 2024 Aidora Team — All rights reserved.