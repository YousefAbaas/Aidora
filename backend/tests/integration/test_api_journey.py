from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import AccessToken

from accounts.models import User


class RefugeeAuthenticationJourneyTest(TestCase):
    """
    Integration journey:

    Register → Login → JWT validation
    """

    def setUp(self):
        self.client = APIClient()

        self.email = "integration_refugee@example.com"
        self.password = "TestPassword123!"

        self.register_payload = {
            "full_name": "Integration Test Refugee",
            "phone_number": "0999999999",
            "email": self.email,
            "password": self.password,
            "confirm_password": self.password,
            "accept_terms": True,
        }

    @staticmethod
    def _step(number, total, title):
        print()
        print(f"[{number}/{total}] {title}")

    @staticmethod
    def _result(label, value):
        print(f"      → {label}: {value}")

    def test_refugee_authentication_journey(self):
        total_steps = 3

        print()
        print("🚀 Refugee Authentication Journey")
        print("=" * 45)

        # ==========================================================
        # 1. REGISTER
        # ==========================================================
        self._step(1, total_steps, "📝 Register refugee")

        register_response = self.client.post(
            "/api/auth/register/refugee/",
            self.register_payload,
            format="json",
        )

        self._result(
            "Endpoint",
            "POST /api/auth/register/refugee/",
        )
        self._result(
            "HTTP status",
            f"{register_response.status_code} "
            f"{'✅' if register_response.status_code == 201 else '❌'}",
        )

        self.assertEqual(
            register_response.status_code,
            201,
            msg=f"Register failed: {register_response.data}",
        )

        self._result("Register response", "OTP sent successfully ✅")

        # Verify User was created.
        user = User.objects.get(email=self.email)

        self.assertEqual(user.email, self.email)
        self.assertEqual(user.role, "refugee")
        self.assertFalse(user.is_verified)

        self._result("User created", f"{user.email} ✅")
        self._result("Role", f"{user.role} ✅")
        self._result("Verified", f"{user.is_verified} ✅")
        self._result(
            "OTP",
            "generated ✅" if user.otp_code else "missing ❌",
        )

        self.assertTrue(
            user.otp_code,
            "OTP was not generated.",
        )

        self.assertIsNotNone(
            user.otp_expires_at,
            "OTP expiration time was not created.",
        )

        self._result("OTP expiration", "created ✅")

        # Verify RefugeeProfile.
        profile = user.refugee_profile

        self.assertEqual(
            profile.full_name,
            "Integration Test Refugee",
        )
        self.assertEqual(
            profile.phone_number,
            "0999999999",
        )
        self.assertFalse(profile.profile_completed)

        self._result("RefugeeProfile", "created ✅")
        self._result("Full name", f"{profile.full_name} ✅")
        self._result("Phone number", f"{profile.phone_number} ✅")
        self._result(
            "Profile completed",
            f"{profile.profile_completed} ✅",
        )

        # ==========================================================
        # 2. LOGIN
        # ==========================================================
        self._step(2, total_steps, "🔐 Login")

        login_response = self.client.post(
            "/api/auth/login/",
            {
                "email": self.email,
                "password": self.password,
            },
            format="json",
        )

        self._result(
            "Endpoint",
            "POST /api/auth/login/",
        )
        self._result(
            "HTTP status",
            f"{login_response.status_code} "
            f"{'✅' if login_response.status_code == 200 else '❌'}",
        )

        self.assertEqual(
            login_response.status_code,
            200,
            msg=f"Login failed: {login_response.data}",
        )

        self.assertIn("access", login_response.data)
        self.assertIn("refresh", login_response.data)
        self.assertEqual(
            login_response.data["role"],
            "refugee",
        )

        access_token = login_response.data["access"]
        refresh_token = login_response.data["refresh"]

        self.assertTrue(access_token)
        self.assertTrue(refresh_token)

        self._result("Access token", "received ✅")
        self._result("Refresh token", "received ✅")
        self._result(
            "Role",
            f"{login_response.data['role']} ✅",
        )

        # ==========================================================
        # 3. JWT VALIDATION
        # ==========================================================
        self._step(3, total_steps, "🎫 Validate JWT")

        token = AccessToken(access_token)

        token_user_id = int(token["user_id"])

        self.assertEqual(
            token_user_id,
            user.id,
            "JWT user_id does not match the registered user.",
        )

        self._result("JWT signature", "valid ✅")
        self._result(
            "JWT user_id",
            f"{token_user_id} ✅",
        )
        self._result(
            "Registered user id",
            f"{user.id} ✅",
        )

        print()
        print("=" * 45)
        print("🎉 Refugee Authentication Journey PASSED ✅")
        print("=" * 45)