from django.test import TestCase
from rest_framework.test import APIClient

from accounts.models import User


class RegisterRefugeeIntegrationTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_register_refugee(self):
        payload = {
            "full_name": "Integration Test Refugee",
            "phone_number": "0999999999",
            "email": "integration_refugee@example.com",
            "password": "TestPassword123!",
            "confirm_password": "TestPassword123!",
            "accept_terms": True,
        }

        response = self.client.post(
            "/api/auth/register/refugee/",
            payload,
            format="json",
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(
            response.data["message"],
            "OTP sent successfully",
        )
        self.assertEqual(
            response.data["email"],
            "integration_refugee@example.com",
        )

        user = User.objects.get(
            email="integration_refugee@example.com"
        )

        self.assertEqual(user.role, "refugee")
        self.assertFalse(user.is_verified)
        self.assertTrue(user.otp_code)
        self.assertIsNotNone(user.otp_expires_at)

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