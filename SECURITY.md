# Security Policy

Aidora handles information about people in vulnerable situations, so security and privacy reports are taken seriously.

## Reporting a vulnerability

Please do **not** open a public issue. Email the maintainer (see the GitHub profile) or use GitHub's private
"Report a vulnerability" feature on this repository. Expect an acknowledgement within 7 days.

## Handled in this repository

- No secrets are committed; configuration is read from environment variables (`SECRET_KEY` is mandatory at startup).
- `DEBUG` defaults to `False`; CORS is only opened to all origins in debug mode.
- Authentication uses short-lived JWT access tokens with refresh-token rotation.
- Production database exports, keystores and credential files are git-ignored.

## Known limitations

- This is an academic project; it has not had an independent security audit.
- Personal data in a deployment must be protected according to the local law and the operator's data-protection policy.
