# Aidora Architecture Overview

## System boundary

Aidora is a humanitarian aid platform with a Flutter mobile client and a Django REST backend backed by PostgreSQL.

```text
┌─────────────────────┐
│   Flutter Mobile    │
│      Client         │
└──────────┬──────────┘
           │ HTTPS / REST
           ▼
┌─────────────────────┐
│   Django REST API   │
│ Authentication      │
│ Organizations       │
│ Refugees / Requests │
│ Tasks / Ratings     │
└──────────┬──────────┘
           │ ORM
           ▼
┌─────────────────────┐
│     PostgreSQL      │
└─────────────────────┘
```

## Authentication model

The backend uses JWT-based authentication with access and refresh tokens. The `/api/auth/me/` endpoint provides role and profile/application state used by the mobile client to determine the appropriate application flow.

## Core domain flow

```text
Refugee creates service request
          ↓
Organization reviews request
          ↓
Task is created/matched
          ↓
Volunteer receives assignment
          ↓
Volunteer completes interaction
          ↓
QR validation confirms completion
          ↓
Task becomes completed
          ↓
Eligible rating/notification flows execute
```

## Engineering concerns

The backend emphasizes role-based access control, pagination, query optimization, automated notifications, and validation around task completion and ratings.

## Mobile testing architecture

Flutter tests are separated into:

- Unit tests for isolated logic.
- Widget tests for UI behavior and widget composition.
- Integration tests for end-to-end app flows.

The CI pipeline executes all three categories before release distribution.

## Deployment boundary

The application has separate CI concerns for Flutter/Android and Django/backend. The Android workflow owns mobile validation, signing, and Firebase QA distribution; the Django workflow owns backend checks/tests against a CI PostgreSQL service.
