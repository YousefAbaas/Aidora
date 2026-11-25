from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings

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


@override_settings(SECURE_SSL_REDIRECT=False)
class VerifiedJWTEndpointTests(TestCase):
    def setUp(self):
        self.client = APIClient()
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

    def test_existing_access_token_is_rejected_for_unverified_account(self):
        access = str(RefreshToken.for_user(self.unverified).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")

        response = self.client.get("/api/auth/me/")

        self.assertEqual(response.status_code, 401)

    def test_verified_account_can_use_an_access_token(self):
        access = str(RefreshToken.for_user(self.verified).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")

        response = self.client.get("/api/auth/me/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["role"], "refugee")

    def test_unverified_access_token_does_not_block_public_otp_verification(self):
        from datetime import timedelta
        from django.core.cache import cache
        from django.utils import timezone

        cache.clear()
        self.unverified.otp_code = "123456"
        self.unverified.otp_expires_at = timezone.now() + timedelta(minutes=10)
        self.unverified.save(update_fields=["otp_code", "otp_expires_at"])
        old_access = str(RefreshToken.for_user(self.unverified).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {old_access}")

        response = self.client.post(
            "/api/auth/verify-otp/",
            {"email": self.unverified.email, "otp": "123456"},
            format="json",
        )

        self.assertEqual(response.status_code, 200)
        self.unverified.refresh_from_db()
        self.assertTrue(self.unverified.is_verified)

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


@override_settings(SECURE_SSL_REDIRECT=False)
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
        import io
        from PIL import Image

        buffer = io.BytesIO()
        Image.new("RGB", (2, 2), color="white").save(buffer, format="PNG")
        upload = SimpleUploadedFile(
            "profile.png", buffer.getvalue(), content_type="image/png"
        )
        response = self.client.patch(
            "/api/auth/profile/upload-image/",
            {"profile_image": upload}, format="multipart"
        )
        self.assertEqual(response.status_code, 200)
        self.user.refugee_profile.refresh_from_db()
        self.assertTrue(self.user.refugee_profile.profile_image)

@override_settings(SECURE_SSL_REDIRECT=False)
class VolunteerApplicationRoleAuthorizationTests(TestCase):
    def test_refugee_cannot_submit_volunteer_application(self):
        client = APIClient()
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


@override_settings(SECURE_SSL_REDIRECT=False)
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


@override_settings(SECURE_SSL_REDIRECT=False)
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
        self.profile.organization = self.organization
        self.profile.verification_pin = "1234"
        self.profile.pin_expires_at = timezone.now() + timedelta(minutes=10)
        self.profile.save(
            update_fields=["organization", "verification_pin", "pin_expires_at"]
        )

    def test_pin_verifies_only_the_current_organizations_application(self):
        from datetime import timedelta
        from django.utils import timezone
        from accounts.models import VolunteerApplication
        from organizations.models import Organization

        other_organization = Organization.objects.create(
            name="Newer PIN Organization",
            title="Newer PIN Organization",
            about="A second organization application",
        )
        other_application = VolunteerApplication.objects.create(
            user=self.user,
            organization=other_organization,
            phone_number="123456789",
            why_volunteer="I want to help another organization.",
            i_commit=True,
            i_agree_terms=True,
            status="approved",
        )
        self.profile.organization = self.organization
        self.profile.verification_pin = "1234"
        self.profile.pin_expires_at = timezone.now() + timedelta(minutes=10)
        self.profile.save(
            update_fields=["organization", "verification_pin", "pin_expires_at"]
        )
        self.client.force_authenticate(user=self.user)

        response = self.client.post(
            "/api/auth/verify-pin/", {"pin": "1234"}, format="json"
        )

        self.assertEqual(response.status_code, 200)
        self.application.refresh_from_db()
        other_application.refresh_from_db()
        self.profile.refresh_from_db()
        self.assertTrue(self.application.is_verified)
        self.assertFalse(other_application.is_verified)
        self.assertEqual(self.profile.organization, self.organization)

    def test_pin_resend_cannot_be_triggered_by_another_organizations_application(self):
        from unittest.mock import patch
        from accounts.models import VolunteerApplication
        from organizations.models import Organization

        self.application.is_verified = True
        self.application.save(update_fields=["is_verified"])
        other_organization = Organization.objects.create(
            name="Other Approved PIN Organization",
            title="Other Approved PIN Organization",
            about="A different approved organization",
        )
        VolunteerApplication.objects.create(
            user=self.user,
            organization=other_organization,
            phone_number="123456789",
            why_volunteer="I want to help another organization.",
            i_commit=True,
            i_agree_terms=True,
            status="approved",
            is_verified=False,
        )
        self.profile.organization = self.organization
        self.profile.save(update_fields=["organization"])
        self.client.force_authenticate(user=self.user)

        with patch("accounts.views.send_aidora_email") as send_email:
            response = self.client.post("/api/auth/resend-pin/", {}, format="json")

        self.assertEqual(response.status_code, 403)
        send_email.assert_not_called()

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


    def test_database_lockout_survives_throttle_cache_reset(self):
        from django.core.cache import cache
        self.client.force_authenticate(user=self.user)

        for _ in range(3):
            response = self.client.post(
                "/api/auth/verify-pin/",
                {"pin": "9999"},
                format="json",
            )
            self.assertEqual(response.status_code, 400)

        # Simulate a different app worker with an empty local throttle cache.
        cache.clear()
        fourth = self.client.post(
            "/api/auth/verify-pin/",
            {"pin": "9999"},
            format="json",
        )
        self.assertEqual(fourth.status_code, 400)

        fifth = self.client.post(
            "/api/auth/verify-pin/",
            {"pin": "9999"},
            format="json",
        )
        self.assertEqual(fifth.status_code, 429)

        self.profile.refresh_from_db()
        self.assertEqual(self.profile.pin_failed_attempts, 5)
        self.assertIsNotNone(self.profile.pin_locked_until)

    def test_resend_rotates_a_locked_pin_and_resets_failures(self):
        from django.core.cache import cache
        from unittest.mock import patch

        self.client.force_authenticate(user=self.user)
        for _ in range(3):
            response = self.client.post(
                "/api/auth/verify-pin/",
                {"pin": "9999"},
                format="json",
            )
            self.assertEqual(response.status_code, 400)

        cache.clear()
        self.assertEqual(
            self.client.post(
                "/api/auth/verify-pin/",
                {"pin": "9999"},
                format="json",
            ).status_code,
            400,
        )
        self.assertEqual(
            self.client.post(
                "/api/auth/verify-pin/",
                {"pin": "9999"},
                format="json",
            ).status_code,
            429,
        )

        with patch("accounts.views.send_aidora_email") as send_email:
            response = self.client.post(
                "/api/auth/resend-pin/",
                {},
                format="json",
            )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(send_email.call_count, 1)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.pin_failed_attempts, 0)
        self.assertIsNone(self.profile.pin_locked_until)
        self.assertIsNotNone(self.profile.verification_pin)


    def test_pin_resend_account_limit_survives_cache_reset(self):
        from django.core.cache import cache
        from unittest.mock import patch

        self.client.force_authenticate(user=self.user)
        with patch("accounts.views.send_aidora_email") as send_email:
            for _ in range(3):
                cache.clear()
                response = self.client.post(
                    "/api/auth/resend-pin/",
                    {},
                    format="json",
                )
                self.assertEqual(response.status_code, 200)

            cache.clear()
            limited = self.client.post(
                "/api/auth/resend-pin/",
                {},
                format="json",
            )

        self.assertEqual(limited.status_code, 429)
        self.assertEqual(send_email.call_count, 3)
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.pin_resend_count, 3)


    def test_verified_application_cannot_resend_or_reuse_pin(self):
        from unittest.mock import patch

        self.application.is_verified = True
        self.application.save(update_fields=["is_verified"])
        self.client.force_authenticate(user=self.user)

        with patch("accounts.views.send_aidora_email") as send_email:
            resend = self.client.post(
                "/api/auth/resend-pin/",
                {},
                format="json",
            )
            verify = self.client.post(
                "/api/auth/verify-pin/",
                {"pin": "1234"},
                format="json",
            )

        self.assertEqual(resend.status_code, 403)
        self.assertEqual(verify.status_code, 403)
        send_email.assert_not_called()

@override_settings(SECURE_SSL_REDIRECT=False)
class OTPVerificationSecurityTests(TestCase):
    def setUp(self):
        from datetime import timedelta
        from django.core.cache import cache
        from django.utils import timezone

        cache.clear()
        self.client = APIClient()
        self.user = User.objects.create_user(
            username="otp_security_user",
            email="otp-security@example.com",
            password="TestPassword123!",
            role="refugee",
            is_verified=False,
        )
        self.user.otp_code = "123456"
        self.user.otp_expires_at = timezone.now() + timedelta(minutes=12)
        self.user.save(update_fields=["otp_code", "otp_expires_at"])

    def test_otp_wrong_attempts_persistently_lock_the_account(self):
        from django.core.cache import cache

        for _ in range(3):
            response = self.client.post(
                "/api/auth/verify-otp/",
                {"email": self.user.email, "otp": "999999"},
                format="json",
            )
            self.assertEqual(response.status_code, 400)

        # Simulate a different application worker with an empty local cache.
        cache.clear()
        fourth = self.client.post(
            "/api/auth/verify-otp/",
            {"email": self.user.email, "otp": "999999"},
            format="json",
        )
        self.assertEqual(fourth.status_code, 400)

        fifth = self.client.post(
            "/api/auth/verify-otp/",
            {"email": self.user.email, "otp": "999999"},
            format="json",
        )
        self.assertEqual(fifth.status_code, 400)

        self.user.refresh_from_db()
        self.assertEqual(self.user.otp_failed_attempts, 5)
        self.assertIsNotNone(self.user.otp_locked_until)

        # Isolate the persisted account lock from the independent per-IP throttle.
        cache.clear()
        sixth = self.client.post(
            "/api/auth/verify-otp/",
            {"email": self.user.email, "otp": "123456"},
            format="json",
        )
        self.assertEqual(sixth.status_code, 400)

    def test_valid_otp_verifies_account_and_consumes_code(self):
        response = self.client.post(
            "/api/auth/verify-otp/",
            {"email": self.user.email, "otp": "123456"},
            format="json",
        )
        self.assertEqual(response.status_code, 200)

        self.user.refresh_from_db()
        self.assertTrue(self.user.is_verified)
        self.assertIsNone(self.user.otp_code)
        self.assertIsNone(self.user.otp_expires_at)
        self.assertEqual(self.user.otp_failed_attempts, 0)
        self.assertIsNone(self.user.otp_locked_until)

    def test_resend_otp_rotates_code_and_clears_lockout(self):
        from datetime import timedelta
        from unittest.mock import patch
        from django.utils import timezone

        self.user.otp_failed_attempts = 5
        self.user.otp_locked_until = timezone.now() + timedelta(minutes=10)
        self.user.save(update_fields=["otp_failed_attempts", "otp_locked_until"])

        with patch("accounts.views.Thread") as thread:
            response = self.client.post(
                "/api/auth/resend-otp/",
                {"email": self.user.email},
                format="json",
            )

        self.assertEqual(response.status_code, 200)
        thread.assert_called_once()
        self.user.refresh_from_db()
        self.assertEqual(self.user.otp_failed_attempts, 0)
        self.assertIsNone(self.user.otp_locked_until)
        self.assertEqual(self.user.otp_resend_count, 1)
        self.assertIsNotNone(self.user.otp_code)
        self.assertIsNotNone(self.user.otp_expires_at)
        self.assertNotEqual(self.user.otp_code, "123456")

    def test_resend_account_limit_survives_cache_reset(self):
        from unittest.mock import patch
        from django.core.cache import cache

        with patch("accounts.views.Thread"):
            for _ in range(3):
                cache.clear()
                response = self.client.post(
                    "/api/auth/resend-otp/",
                    {"email": self.user.email},
                    format="json",
                )
                self.assertEqual(response.status_code, 200)

            cache.clear()
            limited = self.client.post(
                "/api/auth/resend-otp/",
                {"email": self.user.email},
                format="json",
            )

        self.assertEqual(limited.status_code, 200)
        self.assertEqual(
            limited.data["message"],
            "If this account is eligible, a new OTP will be sent.",
        )
        self.user.refresh_from_db()
        self.assertEqual(self.user.otp_resend_count, 3)

    def test_verify_does_not_disclose_unknown_or_verified_accounts(self):
        unknown = self.client.post(
            "/api/auth/verify-otp/",
            {"email": "unknown-otp@example.com", "otp": "123456"},
            format="json",
        )

        self.user.is_verified = True
        self.user.save(update_fields=["is_verified"])
        verified = self.client.post(
            "/api/auth/verify-otp/",
            {"email": self.user.email, "otp": "999999"},
            format="json",
        )

        self.assertEqual(unknown.status_code, 400)
        self.assertEqual(verified.status_code, 400)
        self.assertEqual(unknown.data, verified.data)

    def test_resend_does_not_disclose_unknown_or_verified_accounts(self):
        from unittest.mock import patch

        with patch("accounts.views.Thread"):
            unknown = self.client.post(
                "/api/auth/resend-otp/",
                {"email": "unknown-otp@example.com"},
                format="json",
            )
            self.assertEqual(unknown.status_code, 200)

            self.user.is_verified = True
            self.user.save(update_fields=["is_verified"])
            verified = self.client.post(
                "/api/auth/resend-otp/",
                {"email": self.user.email},
                format="json",
            )

        self.assertEqual(verified.status_code, 200)
        self.assertEqual(unknown.data["message"], verified.data["message"])
