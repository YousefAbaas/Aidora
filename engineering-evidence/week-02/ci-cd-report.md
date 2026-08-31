# Week 02 — CI/CD (GitHub Actions)

Date: 2026-08-29 (first Flutter CI run) — ongoing
Repository: Aidora (this repo, monorepo with Flutter app + Django backend)

## What was done
Two separate GitHub Actions workflows configured for the two halves of
the monorepo, each triggered automatically on every push:

- Flutter CI — runs static analysis and the full test suite
  (test/unit, test/widget, test/integration) against the Flutter
  app on every push.
- Django CI — runs equivalent checks against the Django REST
  backend on every push.

## Evidence
- Flutter CI: 50+ consecutive successful runs since 2026-08-29
  (run #24 through #51+), triggered by regular feature and docs commits.
  See screenshots/flutter-ci-runs-history.jpeg
- Combined workflow history (Flutter CI + Django CI side by side):
  see screenshots/flutter-and-django-ci-runs.jpg
- Two Django CI runs (#33, #34) failed during a merge / repository
  cleanup step. Both failures were investigated and resolved in the
  following commits, after which Django CI returned to passing.

## Why this matters
Having a workflow occasionally fail on a genuine issue rather than
always showing green is a sign the pipeline is actually enforcing
something, not just a formality. Both failures here were caught,
diagnosed, and fixed as part of normal development.

## Notes / Follow-up
- Future improvement: add a build step (e.g. Android APK) to Flutter CI,
  connecting directly into Week 03's release engineering work.
