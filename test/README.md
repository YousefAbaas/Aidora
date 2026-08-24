# Aidora — Humanitarian Aid Coordination Platform

**Connecting displaced communities with humanitarian organizations and volunteers through a structured mobile-first platform.**

[![Flutter](https://img.shields.io/badge/Flutter-Mobile%20%26%20Web-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.4%2B-0175C2?logo=dart)](https://dart.dev/)
[![Django REST](https://img.shields.io/badge/Backend-Django%20REST-092E20?logo=django)](https://www.django-rest-framework.org/)
[![JWT](https://img.shields.io/badge/Auth-JWT-FF6B35)](https://jwt.io/)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-8B5CF6)](https://pub.dev/packages/get)
[![Tests](https://img.shields.io/badge/tests-92%20passing-success)](#testing--code-quality)
[![License](https://img.shields.io/badge/License-Proprietary-lightgrey)](#license)

<p align="center">
  <img src="img/aidora_icon.png" alt="Aidora Logo" width="140">
</p>

---

## Overview

**Aidora** is a cross-platform Flutter application designed to improve coordination between displaced communities, humanitarian organizations, and volunteers.

The platform provides a structured workflow for:

* Discovering humanitarian organizations
* Exploring available services
* Submitting assistance requests
* Tracking request status
* Managing user profiles
* Handling organization and volunteer workflows
* Supporting QR-based verification
* Managing authentication and user sessions

The Flutter client communicates with a **Django REST Framework backend** through a JWT-secured API.

The project focuses not only on UI development, but also on **maintainable architecture, API integration, dependency injection, authentication, image handling, automated testing, and code quality**.

---

## Why Aidora?

Humanitarian assistance workflows can become fragmented when beneficiaries need to discover available services, understand what is offered, submit requests, and follow up through disconnected communication channels.

Aidora aims to provide a structured digital workflow where beneficiaries, organizations, and volunteers interact through role-specific experiences.

The main idea is simple:

```text
                    ┌──────────────────────┐
                    │        Aidora        │
                    └──────────┬───────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
             ▼                 ▼                 ▼
       Beneficiaries      Organizations      Volunteers
             │                 │                 │
             ▼                 ▼                 ▼
       Find services      Provide services   Process requests
       Submit requests   Manage workflows    Verify assistance
       Track requests    Manage requests     QR workflows
```

---

# Core Capabilities

| Capability                  | Description                                                                      |
| --------------------------- | -------------------------------------------------------------------------------- |
| **Authentication**          | JWT-based login, registration, session persistence, and token lifecycle handling |
| **OTP Verification**        | PIN-based verification workflow using Pinput                                     |
| **Assistance Requests**     | Submit, view, track, and manage humanitarian assistance requests                 |
| **Organization Discovery**  | Browse and search available humanitarian organizations                           |
| **Organization Profiles**   | View organization information, services, and related details                     |
| **Guest Mode**              | Explore public organization information without authentication                   |
| **Profile Management**      | Create and maintain beneficiary, volunteer, and organization profiles            |
| **Profile Images**          | Select, upload, normalize, cache, and display profile images                     |
| **Notifications**           | Local notification infrastructure for application events                         |
| **QR Verification**         | QR scanning workflow for volunteer operations                                    |
| **Location Data**           | Store and display relevant location information                                  |
| **Multilingual UI**         | Arabic and English interface support                                             |
| **Smart Search**            | Search interface for discovering relevant humanitarian services                  |
| **Persistent Session Data** | Local persistence using SharedPreferences                                        |
| **External Resources**      | Open external websites and resources through the platform                        |

---

# User Roles

Aidora is designed around multiple role-specific experiences.

## Refugee / Beneficiary

The beneficiary-facing workflow focuses on discovering services and requesting assistance.

Typical capabilities include:

* Account registration
* Authentication
* Profile completion
* Organization discovery
* Service discovery
* Assistance request submission
* Request tracking
* Profile image management
* Notifications

## Organization

Organizations provide humanitarian services through organization-specific workflows.

Typical capabilities include:

* Organization information
* Service management
* Request management
* Organization-specific dashboards
* Reporting workflows

## Volunteer

Volunteer workflows focus on supporting organizations with request processing and verification.

Typical capabilities include:

* Volunteer profile
* Request processing
* Request status handling
* QR scanning
* Assistance verification

## Guest

Unauthenticated users can browse public organization information and explore available services before creating an account.

---

# Application Architecture

Aidora follows a layered Flutter architecture that separates presentation, state management, API communication, models, and reusable UI components.

```text
┌──────────────────────────────────────────────┐
│                  Flutter UI                  │
│                                              │
│     Screens / Views / Widgets / Routing      │
└────────────────────────┬─────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────┐
│               State Management               │
│                     GetX                     │
│                                              │
│       Controllers / Reactive State / UI      │
└────────────────────────┬─────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────┐
│                 Service Layer                │
│                                              │
│ API Services / Auth / Upload / Supporting    │
│ Services                                     │
└────────────────────────┬─────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────┐
│                  REST API                    │
│                                              │
│            Django REST Framework             │
└────────────────────────┬─────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────┐
│               Backend Services               │
│                                              │
│ Authentication / Users / Organizations       │
│ Requests / Services / Application Data       │
└──────────────────────────────────────────────┘
```

This separation keeps API and authentication logic outside individual screens and makes the application easier to test and maintain.

---

# Project Structure

```text
lib/
├── core/
│   └── Application-wide infrastructure
│
├── models/
│   └── API and application data models
│
├── services/
│   ├── API communication
│   ├── Authentication
│   ├── Upload handling
│   └── Supporting services
│
├── utils/
│   ├── Theme utilities
│   ├── Image URL handling
│   └── Shared helpers
│
├── views/
│   ├── Authentication
│   ├── Refugee workflows
│   ├── Organization workflows
│   ├── Volunteer workflows
│   └── Shared application screens
│
├── widgets/
│   └── Reusable UI components
│
└── main.dart

test/
├── helpers/
├── unit/
├── widget/
└── integration/
```

The structure follows application responsibilities rather than placing business and networking logic directly inside UI screens.

---

# State Management

Aidora uses **GetX** for reactive state management and controller-based coordination.

Reactive state is used where application changes need to be reflected immediately in the UI.

For example, profile-related state can be synchronized between screens and controllers without requiring every screen to manually reload the same information.

This approach helps reduce duplicated refresh logic and keeps UI components focused primarily on presentation.

---

# Authentication & Session Management

Authentication is handled through a JWT-based backend integration.

Authentication responsibilities are centralized in dedicated services rather than being embedded directly inside UI screens.

The general lifecycle is:

```text
User
 │
 ▼
Login / Registration
 │
 ▼
Authentication API
 │
 ▼
JWT credentials
 │
 ▼
Local session persistence
 │
 ▼
Authenticated API requests
 │
 ├── Token valid ───────────────► Continue request
 │
 └── Token expired
          │
          ▼
      Refresh token
          │
          ▼
      Retry request
```

Primary authentication responsibilities are centralized in:

```text
lib/services/auth_service.dart
lib/services/api_service.dart
```

This separation makes authentication easier to maintain, mock, and test.

---

# API Integration

The application communicates with the Django REST backend through dedicated service classes.

Instead of placing HTTP requests directly inside widgets, API-related responsibilities are kept in the service layer.

Examples of API areas include:

```text
Authentication
    ├── Login
    ├── Registration
    ├── Token refresh
    └── Profile

Organizations
    ├── Organization cards
    ├── Filtering
    ├── Organization details
    └── Services

Requests
    ├── Create request
    ├── Request list
    ├── Request details
    ├── Status tracking
    └── Volunteer workflows
```

API response models are responsible for converting Django JSON responses into strongly typed Dart objects.

---

# Image URL Handling

Aidora contains centralized image URL normalization to support different backend environments.

For example, backend responses may contain development URLs such as:

```text
http://127.0.0.1:8000/media/...
```

The application normalizes these URLs through:

```text
lib/utils/image_url_helper.dart
```

This prevents URL rewriting logic from being duplicated throughout individual screens.

The helper supports:

* Absolute backend URLs
* Relative media paths
* Development host replacement
* Remote deployment URLs
* Image URL validation

This became especially useful when moving between local development and remotely accessible backend environments.

---

# Engineering Highlights

The project includes several engineering practices intended to improve maintainability and reliability.

### Separation of responsibilities

Authentication, API communication, upload handling, models, and UI responsibilities are separated into dedicated layers.

### Defensive API parsing

Models handle nullable and variable API fields while converting backend JSON into strongly typed Dart objects.

### Centralized image handling

Image URLs are normalized through a single utility instead of duplicating environment-specific URL logic across the application.

### Dependency injection for testing

Services expose test-specific construction and override mechanisms so widgets and business logic can be tested without relying on live backend requests.

### Reusable UI components

Common UI elements such as profile avatars and image widgets are centralized into reusable components.

### Automated testing

The project contains unit, widget, and integration tests covering core application behavior.

### Static analysis

The project currently passes Flutter static analysis with:

```text
No issues found!
```

---

# Testing & Code Quality

Aidora uses a layered automated test strategy covering models, services, widgets, authentication, and critical application flows.

## Current Quality Status

```text
Flutter Analyze
→ No issues found!

Flutter Test
→ 92 tests passed
```

The test suite is divided into three primary layers:

```text
                 ┌────────────────────┐
                 │ Integration Tests  │
                 │   Full app flows   │
                 └─────────▲──────────┘
                           │
                 ┌─────────┴──────────┐
                 │   Widget Tests     │
                 │ Real Flutter UI    │
                 └─────────▲──────────┘
                           │
                 ┌─────────┴──────────┐
                 │    Unit Tests      │
                 │ Pure Dart logic    │
                 └────────────────────┘
```

---

## Test Structure

```text
test/
├── helpers/
│   ├── fixtures.dart
│   └── mock_api_service.dart
│
├── unit/
│   ├── models_test.dart
│   ├── auth_service_test.dart
│   └── requests_service_test.dart
│
├── widget/
│   ├── login_screen_test.dart
│   └── dashboard_widget_test.dart
│
└── integration/
    └── app_flow_test.dart
```

---

## Unit Tests

Unit tests focus on isolated Dart logic without requiring the Flutter rendering framework.

Examples include:

* API model serialization and deserialization
* Request status normalization
* Authentication service behavior
* API service response parsing
* Image URL normalization
* Edge-case handling
* Dashboard and request data parsing

Example:

```dart
final service = RequestsApiService.testInstance(
  _FakeApi(...),
);

final result = await service.fetchMyRequests();
```

This allows services to be tested without making live network requests.

---

# Widget Tests

Widget tests use Flutter's testing framework to exercise real widgets with controlled dependencies.

Examples include:

* Login screen rendering
* Role-specific authentication UI
* Form validation
* Password visibility toggling
* Dashboard rendering
* Request list rendering
* Tab navigation
* Error states

For example:

```dart
setUp(() {
  AuthService.overrideForTest(_FakeApi(...));
});

tearDown(() {
  AuthService.resetOverride();
  Get.reset();
});
```

This allows widgets to run against deterministic fake services instead of a live backend.

---

# Integration Tests

Integration tests verify critical application flows across multiple screens.

Current flows include:

* Successful login
* Navigation away from the login screen
* Invalid credentials
* Login error presentation
* Remaining on the login screen after authentication failure
* Role-specific application entry points

Example flow:

```text
LoginScreen
     │
     ▼
Authentication
     │
     ▼
Profile loading
     │
     ▼
Role-based navigation
     │
     ▼
Application dashboard
```

These tests provide confidence that multiple components work together rather than only testing individual functions.

---

# Dependency Injection for Tests

Network-dependent services expose dedicated injection mechanisms.

## `testInstance(...)`

Used for isolated unit tests.

```dart
final service = RequestsApiService.testInstance(
  _FakeApi(...),
);

final result = await service.fetchMyRequests();
```

This creates a fresh service instance backed by a fake API.

No global singleton state is required.

---

## `overrideForTest(...)`

Used when widgets depend on application-level services.

```dart
setUp(() {
  AuthService.overrideForTest(_FakeApi(...));

  RequestsApiService.overrideForTest(
    RequestsApiService.testInstance(_FakeApi(...)),
  );
});

tearDown(() {
  AuthService.resetOverride();
  RequestsApiService.resetOverride();
  Get.reset();
});
```

Production code can continue using the normal service implementation while tests replace the effective dependency.

---

# Test Fixtures

Test fixtures centralize realistic API responses.

Example fixture categories include:

| Fixture               | API Area               |
| --------------------- | ---------------------- |
| `loginSuccessJson`    | Authentication         |
| `registerSuccessJson` | Registration           |
| `refugeeProfileJson`  | Profile                |
| `requestsListJson`    | Requests               |
| `requestDetailsJson`  | Request details        |
| `orgCardsJson`        | Organizations          |
| `volunteerQrJson`     | Volunteer verification |

Centralized fixtures make API contract changes easier to maintain because shared response shapes are represented in one location.

---

# Why the Testing Architecture Matters

| Pattern                      | Benefit                                           |
| ---------------------------- | ------------------------------------------------- |
| **Fake dependencies**        | Deterministic tests without live backend requests |
| **`testInstance` factories** | Clean dependency injection for unit tests         |
| **Test overrides**           | Safe dependency replacement for widgets           |
| **Centralized fixtures**     | Consistent API response data                      |
| **Unit tests**               | Fast validation of isolated logic                 |
| **Widget tests**             | Validation of real Flutter UI behavior            |
| **Integration tests**        | Verification of complete user flows               |
| **Static analysis**          | Early detection of Dart and Flutter issues        |

The combination provides coverage at multiple levels:

```text
Unit
 ↓
Widget
 ↓
Integration
 ↓
Real application behavior
```

---

# Running the Project

## Requirements

Make sure the development environment includes:

* Flutter SDK
* Dart SDK
* Android Studio or another supported Flutter IDE
* Android/iOS/Web development tooling as required
* A running Aidora Django REST backend

Check the Flutter installation:

```bash
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# Running Tests

Run the complete test suite:

```bash
flutter test
```

Run unit tests:

```bash
flutter test test/unit/
```

Run widget tests:

```bash
flutter test test/widget/
```

Run integration tests:

```bash
flutter test test/integration/
```

Run a specific test file:

```bash
flutter test test/unit/models_test.dart
```

Run static analysis:

```bash
flutter analyze
```

Generate coverage information:

```bash
flutter test --coverage
```

If `genhtml` is installed:

```bash
genhtml coverage/lcov.info -o coverage/html
```

---

# Backend

Aidora's Flutter client communicates with a Django REST Framework backend.

The backend is responsible for application data and server-side workflows such as:

```text
Authentication
Users
Organizations
Services
Assistance Requests
Volunteer Operations
Profile Data
```

The mobile client communicates with the backend through REST endpoints secured by JWT authentication.

> The backend configuration and deployment environment are intentionally kept separate from the Flutter client repository.

---

# Security Considerations

The application uses JWT-based authentication and separates authentication logic from the presentation layer.

Important security responsibilities include:

* Token-based authentication
* Token refresh handling
* Session persistence
* Authenticated API requests
* Separation of user roles
* Backend-controlled authorization

Production deployment should additionally ensure:

* HTTPS-only communication
* Secure backend configuration
* Proper secret management
* Secure token storage appropriate for the deployment platform
* Server-side authorization for every protected operation

Client-side role handling should never be treated as the only authorization mechanism.

---

# Screenshots

> Screenshots can be added here to showcase the main user journeys.

Recommended showcase:

| Screen               | Purpose                       |
| -------------------- | ----------------------------- |
| Login                | Authentication and role entry |
| Organizations        | Organization discovery        |
| Organization Details | Service exploration           |
| Submit Request       | Assistance request workflow   |
| My Requests          | Request tracking              |
| Profile              | User profile management       |
| Volunteer QR         | Assistance verification       |

Example layout:

```text
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│    Login     │  │ Organizations│  │ Organization │
│              │  │              │  │   Details    │
└──────────────┘  └──────────────┘  └──────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│Submit Request│  │ My Requests  │  │    Profile   │
│              │  │              │  │              │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

# Technology Stack

| Layer             | Technology                            |
| ----------------- | ------------------------------------- |
| Mobile / UI       | Flutter                               |
| Language          | Dart                                  |
| State Management  | GetX                                  |
| Backend API       | Django REST Framework                 |
| Authentication    | JWT                                   |
| Local Persistence | SharedPreferences                     |
| Image Handling    | Custom image URL and upload utilities |
| Testing           | Flutter Test                          |
| Mocking / Fakes   | Custom test dependencies              |
| Static Analysis   | Flutter Analyzer                      |

---

# Project Status

The project is currently in active development.

Current engineering status:

```text
Flutter Analyzer
✓ No issues found!

Automated Tests
✓ 92 tests passing

Git Repository
✓ Clean committed implementation
✓ Changes synchronized with origin/master
```

The current focus is improving maintainability, reliability, test coverage, and overall application quality while continuing feature development.

---

# Engineering Goals

The project is being developed with the following engineering goals:

* Maintain a clear separation of responsibilities
* Keep API communication testable
* Reduce coupling between UI and services
* Improve reliability of authentication flows
* Handle backend response variations defensively
* Centralize environment-specific image handling
* Increase automated test coverage
* Keep static analysis clean
* Build reusable Flutter components
* Maintain a codebase that can evolve as application requirements grow

---

# Future Improvements

Potential future improvements include:

* GitHub Actions CI/CD
* Automated test and analyzer checks on every pull request
* Coverage reporting
* Expanded integration testing
* Improved offline behavior
* More comprehensive notification workflows
* Additional accessibility improvements
* Production deployment configuration
* Backend and frontend deployment automation

---

# Development Philosophy

Aidora is developed with a focus on practical software engineering rather than only visual implementation.

The project emphasizes:

```text
Readable Code
     +
Separation of Responsibilities
     +
Testable Services
     +
Reusable Components
     +
Reliable API Integration
     +
Automated Testing
     +
Static Analysis
     =
Maintainable Application
```

---

# License

This project is proprietary.

The source code is available for portfolio and evaluation purposes. Commercial use, redistribution, or reuse of the application and its source code requires explicit permission from the author.

---

# Author

**Yousef Abbas**

Flutter Developer / Software Engineering Student

GitHub: [@YousefAbaas](https://github.com/YousefAbaas)

Project: [Aidora](https://github.com/YousefAbaas/Aidora)

---

## Final Note

Aidora is an ongoing software engineering project focused on building a structured digital platform for humanitarian assistance coordination.

The project combines:

**Flutter + Dart + GetX + Django REST + JWT + API integration + dependency injection + automated testing + static analysis**

with a real-world problem domain involving beneficiaries, humanitarian organizations, and volunteers.
