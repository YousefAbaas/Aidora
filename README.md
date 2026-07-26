Aidora — Humanitarian Aid Coordination Platform
�
￼ 


�
Connecting refugees with humanitarian organizations and volunteers 


�
￼ ￼ ￼ ￼ ￼ ￼ ￼ 


Table of Contents
Overview
Key Features
User Roles
Architecture
Project Structure
Layer Diagram
State Management
Authentication & Token Lifecycle
API Layer
Navigation Flow
Data Models
Static Assets Strategy
Supported Organizations
Tech Stack
Dependencies
Getting Started
Environment Configuration
Backend Integration
Localization
Testing
Roadmap
Contributing
License
Overview
Aidora is a cross-platform Flutter application that bridges the gap between displaced communities and humanitarian organizations. Refugees can submit aid requests, track their status in real time, and connect directly with verified NGOs, while organizations and volunteers get a dedicated dashboard to manage, assign, and fulfill those requests efficiently.
The project consists of a Flutter client (this repository) and a Django REST Framework backend, connected through a JWT-secured API.
Key Features
Feature
Description
Secure Authentication
JWT-based login with proactive token refresh and OTP verification
Aid Requests
Refugees submit help requests tied to specific organizations and services
Organization Profiles
Detailed pages with mission, services, target groups, and impact gallery
Real-time Notifications
Local push notifications for request status updates
Location Awareness
Camp/sector location stored in the refugee profile with a map preview
QR Code Verification
Volunteers scan QR codes to verify and process aid delivery
Profile Management
Full refugee profile with household data, photo upload, and location
Multilingual UI
Arabic and English with runtime language switching
Guest Mode
Browse organizations and services without registration
Smart Search
Natural-language search bar for discovering aid services
User Roles
Code
Architecture
Aidora follows a layered architecture with clear separation of concerns:
Code
Project Structure
Code
Layer Diagram
Code
State Management
Aidora uses GetX for state management, dependency injection, and navigation.
Controller
Responsibility
Scope
ProfileController
Refugee profile — single reactive source of truth
Permanent (app lifetime)
BottomNavController
Active tab index for refugee shell
Permanent
RequestsController
Aid request list, status filters
Permanent
OrgController
Organization list & filter state
Permanent
SettingsController
Language, theme preferences
Permanent
FormController
Volunteer multi-step wizard state
Per-flow
VolController
Volunteer home & task state
Permanent
Pattern used in views:
Dart
Authentication & Token Lifecycle
Aidora uses Django Simple JWT with an access/refresh token pair.
Code
Role-based routing on splash:
Code
API Layer
All endpoints are defined in a single source of truth, ApiConstants:
Dart
Request flow:
Code
Navigation Flow
Code
Data Models
OrganizationCardModel — used in list views
Dart
OrganizationDetailModel — used in detail views
Dart
RequestModel — aid request
Dart
Organization — static local model
Dart
Static Assets Strategy
To ensure reliable image display independent of server availability, all organization visuals are bundled as local assets:
Code
Organization name → asset key resolution:
Dart
Supported Organizations
Organization
Asset Key
Logo
Impact Images
UNICEF
unicef
org_unicef.png
impact_unicef_1/2.png
INTERSOS
intersos
org_intersos.png
impact_intersos_1/2.png
World Food Programme
wfp
org_wfp.png
impact_wfp_1/2.png
UNHCR
unhcr
org_unhcr.png
impact_unhcr_1/2.png
World Health Organization
who
org_who.png
impact_who_1/2.png
Red Crescent
red_crescent
org_red_crescent.png
impact_red_crescent_1/2.png
Tech Stack
Layer
Technology
Frontend
Flutter 3.x (Dart 3.4+)
State Management
GetX 4.6.6
Backend
Django REST Framework
Authentication
Simple JWT (access + refresh tokens)
Token Storage
SharedPreferences
HTTP Client
dart:http with a custom JWT interceptor
Image Loading
cached_network_image + local assets
Notifications
flutter_local_notifications
QR Scanning
mobile_scanner
Typography
Google Fonts
Localization
GetX Translations (AR / EN)
Deep Links
app_links (password reset)
Dependencies
Yaml
Getting Started
Prerequisites
Flutter SDK >=3.4.0
Dart SDK >=3.4.0
Android Studio or Xcode
A running Django backend (see Backend Integration)
Installation
Bash
Build for Release
Bash
Environment Configuration
Set the backend IP in lib/services/api_constants.dart:
Dart
Backend Integration
The Django backend must expose the following endpoint groups:
Group
Base Path
Auth Required
Auth
/api/auth/
Partial
Organizations
/api/organizations/
No (cards/list)
Requests
/api/requests/
Yes
Volunteer
/api/auth/volunteer/
Yes
Required Django packages:
Code
Recommended JWT settings:
Python
Localization
The app supports Arabic and English with runtime switching via GetX Translations.
Dart
Translation keys are defined in lib/utils/app_translations.dart.
Testing
Bash
Key test files:
File
Purpose
test/api_endpoints_test.dart
API URL construction tests
test/model_parsing_test.dart
JSON → Model parsing tests
test/token_manager_test.dart
JWT lifecycle tests
Roadmap
Planned improvements for upcoming releases:
[ ] Push notifications via Firebase Cloud Messaging (replacing local-only notifications)
[ ] In-app chat between refugees, organizations, and volunteers
[ ] Offline-first support for request submission in low-connectivity areas
[ ] Admin web dashboard for organization-level analytics and reporting
[ ] Automated CI/CD pipeline (GitHub Actions) for build, test, and release
[ ] Expanded language support beyond Arabic and English
[ ] Unit and widget test coverage across all controllers and services
Contributions and suggestions toward any of these are welcome — see Contributing below.
Contributing
Contributions are welcome, whether it's a bug fix, a new feature, or an improvement to documentation.
Fork the repository and create a feature branch from main:
Bash
Follow the existing project structure — controllers in controllers/, screens in views/, business logic in services/, and reusable UI in widgets/.
Keep commits focused and descriptive (e.g. fix: resolve 401 on complete-profile endpoint, not update stuff).
Run tests before submitting:
Bash
Open a pull request with a clear description of the change, the motivation behind it, and any relevant screenshots for UI changes.
Reporting Issues
When filing a bug report, please include:
Flutter/Dart version (flutter --version)
Platform (Android, iOS, or Web) and device/emulator details
Steps to reproduce, expected behavior, and actual behavior
Relevant logs or screenshots
Code Style
Follow the official Dart style guide.
Run dart format . before committing.
Prefer small, single-responsibility widgets and controllers over large monolithic files.
License
This project was developed as part of a humanitarian aid initiative.
© 2026 Aidora Team — All rights reserved.
