# Aidora — Humanitarian Aid Coordination Backend

A Django REST Framework backend for coordinating humanitarian assistance between **refugees, volunteers, and organizations**.

Aidora provides the API layer for a Flutter mobile application and manages the complete aid-request lifecycle — from authentication and profile completion to service requests, organizational processing, volunteer assignment, QR-based delivery confirmation, and notifications.

The backend focuses on **secure authentication, role-based authorization, modular architecture, PostgreSQL integration, and containerized development**.

---

## Overview

Aidora addresses a practical humanitarian coordination workflow:

```text
Refugee
   │
   │ Requests a service
   ▼
Organization
   │
   │ Reviews / approves
   ▼
Volunteer
   │
   │ Accepts / completes task
   ▼
QR-based confirmation
   │
   ▼
Request completed
```

The backend is responsible for enforcing the business rules and authorization boundaries throughout this lifecycle.

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

Aidora is organized into independent Django applications with responsibilities separated by domain.

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
| --------------- | ----------------------------------------------------------------------- |
| `accounts`      | Users, authentication, profiles, OTP, password recovery, notifications  |
| `organizations` | Organizations, services, volunteer applications, organization workflows |
| `requests`      | Service requests, request lifecycle, volunteer tasks, QR completion     |

This separation keeps domain logic organized and makes individual modules easier to maintain and extend.

---

## Tech Stack

| Layer            | Technology                 |
| ---------------- | -------------------------- |
| Backend          | Django 6.0                 |
| API              | Django REST Framework 3.16 |
| Authentication   | Simple JWT                 |
| Database         | PostgreSQL                 |
| Database Driver  | psycopg2                   |
| Image Processing | Pillow                     |
| QR Generation    | qrcode                     |
| CORS             | django-cors-headers        |
| Containerization | Docker                     |
| Configuration    | Environment variables      |
| Client           | Flutter                    |

---

## Authentication & Authorization

Authentication is implemented using **JWT access and refresh tokens**.

```text
Client
  │
  │ username + password
  ▼
JWT Token Endpoint
  │
  ├── Access Token
  └── Refresh Token
          │
          ▼
     Authenticated API
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

The backend distinguishes between the main application roles:

```text
                 Authenticated User
                         │
             ┌───────────┼───────────┐
             ▼           ▼           ▼
          Refugee     Volunteer   Organization
             │           │           │
             ▼           ▼           ▼
          Requests      Tasks      Management
```

Role-specific permissions are enforced at the API layer rather than relying solely on frontend restrictions.

---

## Service Request Lifecycle

The service-request workflow is the central business process of Aidora.

```text
┌─────────┐
│ Refugee │
└────┬────┘
     │
     │ Create request
     ▼
┌─────────┐
│ Pending │
└────┬────┘
     │
     │ Organization decision
     ├───────────────┐
     │               │
     ▼               ▼
 Approved         Rejected
     │
     │ Volunteer workflow
     ▼
 Assigned / Accepted
     │
     │ Task completion
     ▼
 QR Verification
     │
     ▼
 Completed
```

The backend controls state transitions and prevents unauthorized users from performing actions outside their role.

---

## QR-based Completion

Aidora uses QR-based verification as part of the service delivery workflow.

The QR workflow allows the backend to associate a physical/service completion action with the corresponding request.

```text
Volunteer
    │
    │ Scan QR
    ▼
Backend validation
    │
    ├── Valid request
    ├── Authorized user
    └── Valid state
            │
            ▼
      Mark request completed
```

This provides an additional verification layer instead of relying exclusively on client-side state changes.

---

## Notifications

The backend includes notification infrastructure for important workflow events.

Examples include:

* Volunteer application updates
* Organization approval notifications
* Task status changes
* Request lifecycle updates

Notifications are generated from backend events so that important state changes remain synchronized with the application's business logic.

---

## API Structure

The API is organized around clear domain prefixes:

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

The API surface is intentionally grouped by domain rather than placing all endpoints in a single application.

---

## Database

Aidora uses **PostgreSQL** as its relational database.

The data model is centered around:

```text
User
 │
 ├── RefugeeProfile
 │
 └── VolunteerProfile

Organization
 │
 ├── OrganizationService
 │
 └── Volunteer / Application relationships

ServiceRequest
 │
 ├── Refugee
 ├── Organization
 ├── Service
 └── Volunteer / Task lifecycle
```

The model structure supports the relationships required for authentication, humanitarian requests, organizational processing, and volunteer workflows.

---

## Security & Configuration

Sensitive configuration is loaded from environment variables rather than being hard-coded into the repository.

Examples include:

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

The repository excludes sensitive local configuration through `.gitignore` and `.dockerignore`.

The application also fails explicitly when required security configuration, such as `SECRET_KEY`, is missing.

This prevents accidental use of insecure fallback values.

---

## Docker

The backend can be built and executed as a Docker container.

Build the image:

```bash
docker build -t aidora-backend .
```

Run the development container:

```bash
docker run --rm --env-file .env -p 8000:8000 aidora-backend
```

The containerized setup keeps the backend runtime environment reproducible and separates application dependencies from the host Python installation.

### Container structure

```text
Dockerfile
   │
   ├── Python runtime
   ├── Application dependencies
   ├── Django project
   └── Development server
```

Local secrets and runtime data are excluded from the Docker build context where appropriate.

---

## Local Development

### Requirements

* Python 3.13+
* PostgreSQL
* Docker (optional but recommended)
* Git

### Without Docker

Create and activate a virtual environment:

```bash
python -m venv venv
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Configure the required environment variables and run:

```bash
python manage.py migrate
python manage.py runserver
```

### With Docker

```bash
docker build -t aidora-backend .
docker run --rm --env-file .env -p 8000:8000 aidora-backend
```

The API will then be available at:

```text
http://localhost:8000/
```

---

## Project Structure

```text
Aidora/
│
├── Aidora/
│   ├── settings.py
│   ├── urls.py
│   └── ...
│
├── accounts/
│   ├── models.py
│   ├── views.py
│   ├── serializers.py
│   ├── permissions.py
│   └── ...
│
├── organizations/
│   ├── models.py
│   ├── views.py
│   ├── serializers.py
│   └── ...
│
├── requests/
│   ├── models.py
│   ├── views.py
│   ├── serializers.py
│   ├── permissions.py
│   └── ...
│
├── Dockerfile
├── .dockerignore
├── .gitignore
├── requirements.txt
├── manage.py
└── README.md
```

---

## Engineering Highlights

The project demonstrates practical backend engineering concepts rather than only basic CRUD development.

### Authentication

* JWT authentication
* OTP verification
* Password recovery
* Account activation
* Role-aware access control

### API design

* Domain-oriented endpoint organization
* DRF serializers and API views
* Explicit permission classes
* Controlled request state transitions

### Data layer

* PostgreSQL integration
* Relational model design
* Profile relationships
* Organization/service/request relationships

### Security

* Environment-based secrets
* Protected API endpoints
* Role-based authorization
* Backend-side validation
* QR verification workflow

### Deployment readiness

* Dockerfile
* `.dockerignore`
* Environment-driven configuration
* Reproducible dependency installation

---

## Team Contributions

Aidora was developed collaboratively.

### Siedra-Ziedan

Contributed to:

* Accounts module
* Organizations module
* Requests module
* JWT authentication
* OTP verification
* Password recovery
* Volunteer and organization workflows
* Role-based authorization
* Notification infrastructure
* Database architecture

### Shahd-Ibraheem

Contributed to:

* Refugee module
* Refugee profile management
* Service-request functionality
* QR-based completion workflow
* Flutter integration
* Notification-related functionality

---

## Development Status

The backend is actively developed as part of the Aidora humanitarian coordination platform.

Current engineering work focuses on:

* Backend reliability
* API organization
* Security hardening
* Containerized development
* Database integration
* Flutter/backend integration

---

## License

This project is currently developed as an academic and portfolio project.

---

## Author

**Yousef Abbas**

Flutter Developer · Django REST Framework

GitHub: **YousefAbaas**
