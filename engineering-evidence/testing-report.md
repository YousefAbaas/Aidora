# Week 01 — Automated Testing

**Date:** 2026-08-15
**Goal:** Unit + Widget tests for Aidora

## Result
- 27/27 tests passed (127ms total runtime)
- Test types: unit tests (API endpoint construction, JSON model parsing,
  request body validation) + widget tests (dashboard rendering)
- Files: `test/unit/`, `test/widget/`, `test/api_endpoints_test.dart`

## What was tested
- **API endpoint construction**: verifies `ApiConstants` builds correct
  URL paths for all endpoints (auth, organizations, requests), including
  dynamic path parameters (org ID, service ID)
- **JSON model parsing**: verifies model classes (`OrganizationCardModel`,
  `RequestModel`, `MyRequestsModel`, `MeResult`) correctly deserialize API
  responses across all request states (approved, rejected, pending,
  completed), including edge cases like missing/null fields
- **Request body validation**: verifies outgoing payloads (login,
  registration, profile completion, token refresh) contain the correct
  required fields and formats (e.g. `date_of_birth` as `YYYY-MM-DD`)
- **Widget rendering**: `dashboard_widget_test.dart` verifies the
  dashboard screen renders correctly against mocked API data

## Evidence
See `screenshots/unit_tests.PNG` and `screenshots/widget_tests.PNG`

## Notes / Follow-up
- 37 warnings flagged in the initial run — cleaned up unused imports and
  deprecated API usage
- Test suite later expanded with dedicated `test/unit/`, `test/widget/`,
  and `test/integration/` directories, plus a dependency-injection setup
  (`testInstance` / `overrideForTest`) — see the main `test/README.md`
  for full architecture details
