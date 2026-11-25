from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication


class VerifiedJWTAuthentication(JWTAuthentication):
    """Reject access tokens for accounts that have not verified their email."""

    def get_user(self, validated_token):
        user = super().get_user(validated_token)
        if not user.is_verified:
            raise AuthenticationFailed(
                "Email verification is required.",
                code="account_not_verified",
            )
        return user
