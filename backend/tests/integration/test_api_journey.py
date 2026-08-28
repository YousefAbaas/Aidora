from django.test import TestCase
from rest_framework.test import APIClient

from accounts.models import User


class RegisterLoginIntegrationTest(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_refugee_register_then_login(self):
        email = "integration_refugee@example.com"
        password = "TestPassword123!"

        register_payload = {
            "full_name": "Integration Test Refugee",
            "phone_number": "0999999999",
            "email": email,
            "password": password,
            "confirm_password": password,
            "accept_terms": True,
        }

        # 1. Register
        register_response = self.client.post(
            "/api/auth/register/refugee/",
            register_payload,
            format="json",
        )

        self.assertEqual(register_response.status_code, 201)

        # 2. Verify database state
        user = User.objects.get(email=email)

        self.assertEqual(user.role, "refugee")
        self.assertFalse(user.is_verified)

        profile = user.refugee_profile

        self.assertEqual(
            profile.full_name,
            "Integration Test Refugee",
        )

        self.assertFalse(profile.profile_completed)

        # 3. Login using the same credentials
        login_response = self.client.post(
            "/api/auth/login/",
            {
                "email": email,
                "password": password,
            },
            format="json",
        )

        self.assertEqual(login_response.status_code, 200)

        # 4. Verify token response
        self.assertIn("access", login_response.data)
        self.assertIn("refresh", login_response.data)
        self.assertEqual(
            login_response.data["role"],
            "refugee",
        )

        self.assertTrue(login_response.data["access"])
        self.assertTrue(login_response.data["refresh"])