# Aidora — System Architecture

## 1. System overview

Aidora is a full-stack humanitarian assistance coordination platform built as a fourth-year Informatics Engineering academic project.

The system uses a client–server architecture:

- **Client:** Flutter application written in Dart, with GetX for reactive state management.
- **API:** Django REST Framework application exposing REST/JSON endpoints.
- **Persistence:** PostgreSQL, accessed through Django's ORM.
- **Authentication:** JWT-based access and refresh token workflows.

## 2. Technical ownership

The end-to-end technical design and implementation were led by Yousef Abbas. This included defining the system architecture, structuring the client and backend, designing the data model and API surface, implementing both application components, and integrating the client with backend services.

This document describes the implemented repository structure and documented system boundaries. It does not imply that every possible operational or production concern was independently audited.

## 3. High-level architecture

```text
┌───────────────────────────────────────────────┐
│               Flutter Client                  │
│                                               │
│  Presentation → GetX State → Services/Models  │
└───────────────────────┬───────────────────────┘
                        │ HTTPS / REST / JSON
                        │ JWT access / refresh
                        ▼
┌───────────────────────────────────────────────┐
│            Django REST Framework              │
│                                               │
│  Accounts | Organisations | Service Requests  │
│  Authentication | Permissions | Validation   │
└───────────────────────┬───────────────────────┘
                        │ Django ORM
                        ▼
┌───────────────────────────────────────────────┐
│                  PostgreSQL                   │
└───────────────────────────────────────────────┘
```

## 4. Backend domain boundaries

| Domain | Main responsibilities |
|---|---|
| `accounts` | User accounts, authentication, profiles, OTP verification and password recovery |
| `organizations` | Organisation profiles, services and organisation-side workflows |
| `service_requests` | Assistance requests, task lifecycle, volunteer operations and QR completion |

The backend enforces role-aware access at the API layer. Client-side navigation and UI state are not treated as substitutes for server-side authorization.

## 5. Mobile application layers

The Flutter client separates concerns into:

| Layer | Main responsibility |
|---|---|
| Views and widgets | User interface and presentation |
| Controllers | Reactive state and coordination through GetX |
| Services | HTTP communication, authentication and supporting operations |
| Models | Typed representations of API data |
| Utilities | Shared helpers and application-wide concerns |

This separation keeps request logic out of presentation widgets and provides clearer boundaries for testing and maintenance.

## 6. Core workflow

```text
Beneficiary discovers an organisation/service
                  ↓
          Submits assistance request
                  ↓
        Organisation reviews request
                  ↓
        Volunteer task is coordinated
                  ↓
         Volunteer performs the task
                  ↓
         QR-based completion check
                  ↓
           Request/task updated
```

The actual workflow and available actions depend on role permissions and request state, which are enforced by backend endpoints.

## 7. Authentication and API integration

The client communicates with the backend through REST endpoints. JWT access and refresh tokens support authenticated requests and session renewal.

The backend exposes separate endpoint groups for accounts, organisations, and service requests. The API documentation is generated through the project's OpenAPI/Swagger integration where enabled.

## 8. Data model

The domain model links user identities and role-specific profiles with organisations, services, assistance requests, and volunteer task records. PostgreSQL provides persistence, while Django models and the ORM define the application-level data access boundary.

The repository includes an ER diagram at [ER_Diagram.pdf](../ER_Diagram.pdf). Review the diagram alongside current Django models and migrations when making schema-level decisions.

## 9. Testing and delivery

The repository separates Flutter tests and Django backend tests. GitHub Actions contains distinct workflows for the Flutter application and Django backend.

See:
- [CI/CD Notes](ci-cd.md)
- [Engineering Decisions](engineering-decisions.md)
- [Backend README](../backend/README.md)

A workflow definition documents intended automation; successful current CI status should be verified from GitHub Actions rather than inferred from the presence of YAML files.

## 10. Security and operational boundaries

- Keep credentials and environment-specific configuration outside source control.
- Use environment variables or a dedicated secrets manager for secret values.
- Do not publish production database dumps, personal records, access tokens, signing keys, or user-uploaded private media.
- Verify production security settings and deployment status against the live environment; repository documentation alone is not proof of a current security audit.

## 11. Further reading

- [Project README](../README.md)
- [Backend documentation](../backend/README.md)
- [Engineering decisions](engineering-decisions.md)
- [API integration guide](../API_INTEGRATION_GUIDE.md)
