from rest_framework_simplejwt.authentication import JWTAuthentication


class VerifiedJWTAuthentication(JWTAuthentication):
    """Ignore access tokens for accounts that have not verified their email."""

    def authenticate(self, request):
        authentication = super().authenticate(request)
        if authentication is None:
            return None

        user, validated_token = authentication
        if not user.is_verified:
            # DRF authenticates before checking permissions, even on AllowAny
            # endpoints. Treat this token as absent so public OTP endpoints
            # remain usable while protected endpoints stay unauthenticated.
            return None

        return user, validated_token
