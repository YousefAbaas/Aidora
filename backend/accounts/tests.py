from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase

from .models import Notification, RefugeeProfile, User
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode


class UserModelTests(TestCase):
    def test_user_is_created_with_expected_role_and_terms(self):
        user = User.objects.create_user(
            username="test_refugee",
            email="refugee@example.com",
            password="TestPassword123!",
            role="refugee",
            accept_terms=True,
        )

        self.assertEqual(user.role, "refugee")
        self.assertTrue(user.accept_terms)
        self.assertFalse(user.is_verified)

    def test_refugee_profile_image_is_saved_to_storage(self):
        user = User.objects.create_user(
            username="image_test_user",
            email="image@example.com",
            password="TestPassword123!",
            role="refugee",
        )

        profile = user.refugee_profile

        image = SimpleUploadedFile(
            name="profile.png",
            content=(
                b"\x89PNG\r\n\x1a\n"
                b"\x00\x00\x00\rIHDR"
                b"\x00\x00\x00\x01"
                b"\x00\x00\x00\x01"
                b"\x08\x02\x00\x00\x00"
                b"\x90wS\xde"
                b"\x00\x00\x00\x0cIDAT"
                b"\x08\xd7c\xf8\xcf\xc0\x00"
                b"\x00\x00\x03\x00\x01"
                b"\x00\x18\xdd\x8d\xb4"
                b"\x00\x00\x00\x00IEND\xaeB`\x82"
            ),
            content_type="image/png",
        )

        profile.profile_image = image
        profile.save()

        profile.refresh_from_db()

        self.assertTrue(profile.profile_image)
        self.assertTrue(
            profile.profile_image.storage.exists(profile.profile_image.name)
        )

    def test_refugee_profile_is_linked_to_user(self):
        user = User.objects.create_user(
            username="refugee_profile_user",
            email="profile@example.com",
            password="TestPassword123!",
            role="refugee",
        )

        profile = user.refugee_profile

        self.assertEqual(profile.user, user)
        self.assertEqual(profile.full_name, "")
        self.assertFalse(profile.profile_completed)

    def test_notification_defaults_to_unread(self):
        user = User.objects.create_user(
            username="notification_user",
            email="notification@example.com",
            password="TestPassword123!",
            role="refugee",
        )

        notification = Notification.objects.create(
            user=user,
            message="Test notification",
            notification_type="general",
        )

        self.assertFalse(notification.is_read)
        self.assertEqual(notification.user, user)


class VerifiedJWTEndpointTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.client.defaults["wsgi.url_scheme"] = "https"
        self.unverified = User.objects.create_user(
            username="unverified",
            email="unverified@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=False,
        )
        self.verified = User.objects.create_user(
            username="verified",
            email="verified@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=True,
        )

    def test_custom_login_rejects_unverified_account(self):
        response = self.client.post(
            "/api/auth/login/",
            {"email": self.unverified.email, "password": "TestPassword123!"},
            format="json",
        )
        self.assertEqual(response.status_code, 403)

    def test_standard_jwt_obtain_route_rejects_unverified_account(self):
        response = self.client.post(
            "/api/auth/token/",
            {"username": self.unverified.username, "password": "TestPassword123!"},
            format="json",
        )
        self.assertEqual(response.status_code, 401)

    def test_refresh_route_rejects_unverified_account(self):
        refresh = str(RefreshToken.for_user(self.unverified))
        response = self.client.post(
            "/api/auth/token/refresh/",
            {"refresh": refresh},
            format="json",
        )
        self.assertEqual(response.status_code, 401)

    def test_verified_account_can_obtain_and_refresh_tokens(self):
        obtain = self.client.post(
            "/api/auth/token/",
            {"username": self.verified.username, "password": "TestPassword123!"},
            format="json",
        )
        self.assertEqual(obtain.status_code, 200)
        self.assertIn("access", obtain.data)
        self.assertIn("refresh", obtain.data)
        self.assertEqual(obtain.data["role"], "refugee")

        refresh = self.client.post(
            "/api/auth/token/refresh/",
            {"refresh": obtain.data["refresh"]},
            format="json",
        )
        self.assertEqual(refresh.status_code, 200)
        self.assertIn("access", refresh.data)

    def test_logout_cannot_blacklist_another_users_refresh_token(self):
        other_refresh = str(RefreshToken.for_user(self.verified))
        actor = User.objects.create_user(
            username="actor",
            email="actor@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=True,
        )
        actor_access = str(RefreshToken.for_user(actor).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {actor_access}")

        response = self.client.post(
            "/api/auth/logout/",
            {"refresh": other_refresh},
            format="json",
        )
        self.assertEqual(response.status_code, 400)

        refresh_response = self.client.post(
            "/api/auth/token/refresh/",
            {"refresh": other_refresh},
            format="json",
        )
        self.assertEqual(refresh_response.status_code, 200)


class ProfileImageUploadSecurityTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.client.defaults["wsgi.url_scheme"] = "https"
        self.user = User.objects.create_user(
            username="image_owner",
            email="image-owner@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=True,
        )
        self.client.force_authenticate(user=self.user)

    def test_non_image_upload_is_rejected(self):
        upload = SimpleUploadedFile(
            "not-an-image.txt", b"this is not an image", content_type="text/plain"
        )
        response = self.client.patch(
            "/api/auth/profile/upload-image/",
            {"profile_image": upload}, format="multipart"
        )
        self.assertEqual(response.status_code, 400)
        self.assertFalse(self.user.refugee_profile.profile_image)

    def test_oversized_valid_image_is_rejected(self):
        import io
        import os
        from PIL import Image

        image = Image.frombytes("RGB", (1400, 1400), os.urandom(1400 * 1400 * 3))
        buffer = io.BytesIO()
        image.save(buffer, format="PNG", compress_level=0)
        self.assertGreater(len(buffer.getvalue()), 5 * 1024 * 1024)
        upload = SimpleUploadedFile(
            "large.png", buffer.getvalue(), content_type="image/png"
        )
        response = self.client.patch(
            "/api/auth/profile/upload-image/",
            {"profile_image": upload}, format="multipart"
        )
        self.assertEqual(response.status_code, 400)
        self.assertFalse(self.user.refugee_profile.profile_image)

    def test_valid_png_upload_succeeds(self):
        image_bytes = bytes.fromhex(
            "89504e470d0a1a0a0000000d4948445200000001000000010802000000"
            "907753de0000000c4944415408d763f8cfc00000000300010018dd8db4"
            "0000000049454e44ae426082"
        )
        upload = SimpleUploadedFile(
            "profile.png", image_bytes, content_type="image/png"
        )
        response = self.client.patch(
            "/api/auth/profile/upload-image/",
            {"profile_image": upload}, format="multipart"
        )
        self.assertEqual(response.status_code, 200)
        self.user.refugee_profile.refresh_from_db()
        self.assertTrue(self.user.refugee_profile.profile_image)

class VolunteerApplicationRoleAuthorizationTests(TestCase):
    def test_refugee_cannot_submit_volunteer_application(self):
        client = APIClient()
        client.defaults["wsgi.url_scheme"] = "https"
        refugee = User.objects.create_user(
            username="applicant_refugee",
            email="applicant-refugee@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=True,
        )
        client.force_authenticate(user=refugee)

        response = client.post(
            "/api/auth/org/1/volunteer/applications/",
            {
                "phone_number": "123456789",
                "why_volunteer": "I want to help.",
                "i_commit": True,
                "i_agree_terms": True,
                "selected_services": [1],
            },
            format="json",
        )
        self.assertEqual(response.status_code, 403)


class PasswordResetSessionRevocationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.client.defaults["wsgi.url_scheme"] = "https"
        self.user = User.objects.create_user(
            username="password_reset_user",
            email="password-reset@example.com",
            password="OldPassword123!",
            role="refugee",
            is_verified=True,
        )
        self.refresh_token = str(RefreshToken.for_user(self.user))

    def test_password_reset_blacklists_existing_refresh_tokens(self):
        uid = urlsafe_base64_encode(force_bytes(self.user.pk))
        token = PasswordResetTokenGenerator().make_token(self.user)

        response = self.client.patch(
            "/api/auth/reset-password/",
            {
                "uid": uid,
                "token": token,
                "new_password": "NewPassword456!",
                "confirm_password": "NewPassword456!",
            },
            format="json",
        )
        self.assertEqual(response.status_code, 200)

        refresh_response = self.client.post(
            "/api/auth/token/refresh/",
            {"refresh": self.refresh_token},
            format="json",
        )
        self.assertEqual(refresh_response.status_code, 401)


class VolunteerPINSecurityTests(TestCase):
    def setUp(self):
        from datetime import timedelta
        from django.core.cache import cache
        from django.utils import timezone
        from organizations.models import Organization
        from accounts.models import VolunteerApplication

        cache.clear()
        self.client = APIClient()
        self.client.defaults["wsgi.url_scheme"] = "https"
        self.user = User.objects.create_user(
            username="pin_volunteer",
            email="pin-volunteer@example.com",
            password="TestPassword123!",
            role="volunteer",
            is_verified=True,
        )
        self.profile = self.user.volunteer_profile
        self.organization = Organization.objects.create(
            name="PIN Test Organization",
            title="PIN Test Organization",
            about="Organization for PIN verification tests",
        )
        self.application = VolunteerApplication.objects.create(
            user=self.user,
            organization=self.organization,
            phone_number="123456789",
            why_volunteer="I want to help.",
            i_commit=True,
            i_agree_terms=True,
            status="approved",
        )
        self.profile.verification_pin = "1234"
        self.profile.pin_expires_at = timezone.now() + timedelta(minutes=10)
        self.profile.save(update_fields=["verification_pin", "pin_expires_at"])

    def test_refugee_cannot_verify_volunteer_pin(self):
        refugee = User.objects.create_user(
            username="pin_refugee",
            email="pin-refugee@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=True,
        )
        self.client.force_authenticate(user=refugee)

        response = self.client.post(
            "/api/auth/verify-pin/",
            {"pin": "1234"},
            format="json",
        )
        self.assertEqual(response.status_code, 403)

    def test_wrong_pin_attempts_are_rate_limited_per_user(self):
        self.client.force_authenticate(user=self.user)

        for _ in range(3):
            response = self.client.post(
                "/api/auth/verify-pin/",
                {"pin": "9999"},
                format="json",
            )
            self.assertEqual(response.status_code, 400)

        limited = self.client.post(
            "/api/auth/verify-pin/",
            {"pin": "9999"},
            format="json",
        )
        self.assertEqual(limited.status_code, 429)

    def test_successful_pin_verification_consumes_pin_and_marks_application(self):
        self.client.force_authenticate(user=self.user)

        response = self.client.post(
            "/api/auth/verify-pin/",
            {"pin": "1234"},
            format="json",
        )
        self.assertEqual(response.status_code, 200)

        self.profile.refresh_from_db()
        self.application.refresh_from_db()
        self.assertTrue(self.profile.profile_completed)
        self.assertEqual(self.profile.organization, self.organization)
        self.assertTrue(self.application.is_verified)
        self.assertIsNone(self.profile.verification_pin)
        self.assertIsNone(self.profile.pin_expires_at)

    def test_pin_resend_is_rate_limited(self):
        from unittest.mock import patch

        self.client.force_authenticate(user=self.user)
        with patch("accounts.views.send_aidora_email") as send_email:
            for _ in range(3):
                response = self.client.post(
                    "/api/auth/resend-pin/",
                    {},
                    format="json",
                )
                self.assertEqual(response.status_code, 200)

            limited = self.client.post(
                "/api/auth/resend-pin/",
                {},
                format="json",
            )

        self.assertEqual(limited.status_code, 429)
        self.assertEqual(send_email.call_count, 3)
