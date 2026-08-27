# Aidora — Humanitarian Aid Coordination Backend

A Django REST Framework backend for coordinating humanitarian assistance between **refugees, volunteers, and organizations**.

Aidora provides the API layer for the Flutter mobile application (see the [root README](../README.md)) and manages the complete aid-request lifecycle — from authentication and profile completion to service requests, organizational processing, volunteer assignment, QR-based delivery confirmation, and notifications.

The backend focuses on **secure authentication, role-based authorization, modular architecture, PostgreSQL integration, and containerized development**.

---

## Overview

```text
Refugee → Requests a service → Organization → Reviews/approves
   → Volunteer → Accepts/completes task → QR-based confirmation
   → Request completed
```

### Core capabilities

* JWT authentication with access and refresh tokens
* Refugee and volunteer registration
* Email OTP verification
* Password recovery and reset
* Role-based authorization
* Profile completion workflow
* Organization and service management
* Humanitarian service requests
* Volunteer applications
* Task assignment and reassignment
* Request approval and rejection
* QR-based request completion
* Notification infrastructure
* PostgreSQL database integration
* Dockerized backend environment
* Environment-based configuration

---

## Architecture

```text
                         ┌─────────────────────┐
                         │   Flutter Mobile    │
                         │      Client         │
                         └──────────┬──────────┘
                                    │
                              REST / JSON
                                    │
                                    ▼
                    ┌───────────────────────────┐
                    │      Django REST API      │
                    └─────────────┬─────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
          ▼                       ▼                       ▼
    ┌───────────┐          ┌──────────────┐       ┌─────────────┐
    │  Accounts │          │ Organizations│       │  Requests   │
    └─────┬─────┘          └──────┬───────┘       └──────┬──────┘
          │                       │                       │
          └───────────────────────┼───────────────────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │   PostgreSQL    │
                         └─────────────────┘
```

### Application responsibilities

| Module          | Responsibility                                                          |
| --------------- | ------------------------------------------------------------------------- |
| `accounts`      | Users, authentication, profiles, OTP, password recovery, notifications  |
| `organizations` | Organizations, services, volunteer applications, organization workflows |
| `requests`      | Service requests, request lifecycle, volunteer tasks, QR completion     |

---

## Tech Stack

| Layer            | Technology                 |
| ----------------- | ---------------------------- |
| Backend          | Django 6.0                 |
| API              | Django REST Framework 3.16 |
| Authentication   | Simple JWT                 |
| Database         | PostgreSQL                 |
| Database Driver  | psycopg2                   |
| Image Processing | Pillow                     |
| QR Generation    | qrcode                     |
| CORS             | django-cors-headers        |
| Containerization | Docker + Docker Compose    |
| Configuration    | Environment variables      |
| Client           | Flutter (see [root README](../README.md)) |

---

## Authentication & Authorization

```text
Client → username + password → JWT Token Endpoint
   ├── Access Token
   └── Refresh Token → Authenticated API
```

### Authentication features

* JWT access tokens
* JWT refresh tokens
* Account activation after OTP verification
* Email OTP verification
* OTP resend flow
* Password recovery
* Password reset tokens
* `/api/auth/me/` endpoint for frontend session and routing decisions

### Role-based authorization

```text
                 Authenticated User
             ┌───────────┼───────────┐
             ▼           ▼           ▼
          Refugee     Volunteer   Organization
             ▼           ▼           ▼
          Requests      Tasks      Management
```

Role-specific permissions are enforced at the API layer rather than relying solely on frontend restrictions.

---

## Service Request Lifecycle

```text
Refugee → Create request → Pending → Organization decision
   ├── Approved → Volunteer workflow → Assigned/Accepted
   │     → Task completion → QR Verification → Completed
   └── Rejected
```

---

## QR-based Completion

```text
Volunteer → Scan QR → Backend validation
   ├── Valid request
   ├── Authorized user
   └── Valid state → Mark request completed
```

---

## Notifications

Generated from backend events (volunteer application updates, organization approval notifications, task status changes, request lifecycle updates) so state changes stay synchronized with business logic.

---

## API Structure

```text
/api/auth/
/api/organizations/
/api/requests/
```

### Authentication
```text
/api/auth/token/
/api/auth/token/refresh/
/api/auth/login/
/api/auth/logout/
/api/auth/register/refugee/
/api/auth/register/volunteer/
/api/auth/verify-otp/
/api/auth/resend-otp/
/api/auth/forgot-password/
/api/auth/reset-password/
/api/auth/me/
```

### Organizations
```text
/api/organizations/cards/
/api/organizations/<id>/
/api/organizations/<id>/services/
/api/organizations/dashboard/
/api/organizations/applications/
/api/organizations/tasks/
/api/organizations/my-org/
```

### Requests
```text
/api/requests/list/
/api/requests/my-requests/
/api/requests/<id>/details/
/api/requests/<id>/services/
/api/requests/org/requests/
/api/requests/volunteer/home/
/api/requests/volunteer/tasks/
/api/requests/<id>/scan-qr/
```

---

## Database

PostgreSQL. Data model centered around:

```text
User ── RefugeeProfile / VolunteerProfile
Organization ── OrganizationService / Volunteer applications
ServiceRequest ── Refugee / Organization / Service / Volunteer / Task lifecycle
```

---

## Security & Configuration

Sensitive configuration is loaded from environment variables, never hard-coded:

```text
SECRET_KEY
DB_NAME
DB_USER
DB_PASSWORD
DB_HOST
DB_PORT
EMAIL_HOST_USER
EMAIL_HOST_PASSWORD
```

`.gitignore` and `.dockerignore` exclude sensitive local configuration (`.env`, `media/`). The application fails explicitly when required security configuration (e.g. `SECRET_KEY`) is missing, preventing accidental use of insecure fallback values.

---

## Local Development

### Requirements

* Python 3.13+
* PostgreSQL
* Docker + Docker Compose (recommended)
* Git

### With Docker Compose (recommended)

```bash
docker-compose up --build
```

This builds and runs both the Django API and a PostgreSQL container, linked over an internal Docker network (Django reaches the database via the service name `db`, not `localhost`). Data persists across container restarts via a named volume.

The API is then available at:
```text
http://localhost:8000/
```

### Without Docker

```bash
python -m venv venv
# activate the venv, then:
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

---

## CI/CD

The backend has its own GitHub Actions workflow (`django-ci.yml`, separate from the Flutter workflow — see [root README](../README.md#cicd--android-build-notes)) that runs against a real PostgreSQL service container, mirroring the local Docker Compose setup.

```text
Checkout → Set up Python → Install dependencies → Django system check → Tests (against PostgreSQL service)
```

---

## Contributing

1. Create a focused branch.
2. Keep changes scoped to a single responsibility.
3. Run `python manage.py test` before opening a pull request.
4. Never commit `.env`, `media/`, or database credentials.

---

## License

This project is currently distributed under a **proprietary license**, part of the Aidora platform (see [root README](../README.md)).
