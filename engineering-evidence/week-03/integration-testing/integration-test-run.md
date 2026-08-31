# Week 03 — Integration Testing Evidence

## Objective

This week's engineering work focused exclusively on Integration Testing for the Aidora Flutter application.

The goal was to verify critical user flows across the application boundary, including authentication, backend communication, profile loading, navigation, and authentication error handling.

The tests were executed against the real application flow rather than isolated unit-level behavior.

---

## Test Scope

The integration test suite covers the following authentication flows:

1. Successful login and navigation.
2. Failed login with invalid credentials.

Test file:

    test/integration/app_flow_test.dart

Execution command:

    flutter test test/integration/app_flow_test.dart -r expanded

---

## Test 1 — Successful Login → Navigation

### Scenario

A refugee user submits valid login credentials.

### Verification

The integration test verifies that:

- Login completes successfully.
- Authentication tokens are saved.
- The refugee profile is loaded successfully.
- Application navigation settles after authentication.
- The LoginScreen is no longer present.
- Test cleanup completes successfully.
- Test teardown completes successfully.

### Result

PASS

---

## Test 2 — Invalid Credentials → Error Handling

### Scenario

A user submits invalid login credentials.

### Verification

The integration test verifies that:

- Invalid credentials are submitted.
- An error widget is displayed.
- The Login button remains available.
- The email field remains available.
- The password field remains available.
- The user remains on the LoginScreen.
- Test cleanup completes successfully.
- Test teardown completes successfully.

### Result

PASS

---

## Execution Result

Tests executed: 2  
Tests passed: 2  
Tests failed: 0

Overall result: PASS

The Flutter test runner reported:

    00:01 +2: All tests passed!

---

## Engineering Evidence

This test run provides evidence that the implemented authentication flows behave correctly across multiple application layers.

The successful-login scenario verifies the flow from authentication through token persistence, profile retrieval, and navigation.

The invalid-credentials scenario verifies that authentication failures are handled without incorrectly navigating the user away from the LoginScreen.

This evidence is part of Week 03 — Integration Testing.