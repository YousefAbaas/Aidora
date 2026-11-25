from django.db import IntegrityError
from django.test import TestCase, override_settings

from .models import Organization, OrganizationService, Service
from accounts.models import User, VolunteerApplication
from rest_framework.test import APIClient
from service_requests.models import ServiceRequest, Task


class OrganizationModelTests(TestCase):
    def setUp(self):
        self.organization = Organization.objects.create(
            name="Test Organization",
            title="Test Organization Title",
            about="Test organization description.",
        )

        self.service = Service.objects.create(
            name="Test Health Service",
            description="Test health service.",
            icon="health",
            service_type="health",
        )

    def test_organization_is_created_correctly(self):
        self.assertEqual(self.organization.name, "Test Organization")
        self.assertEqual(
            str(self.organization),
            "Test Organization",
        )

    def test_service_can_be_linked_to_organization(self):
        organization_service = OrganizationService.objects.create(
            organization=self.organization,
            service=self.service,
        )

        self.assertEqual(
            organization_service.organization,
            self.organization,
        )
        self.assertEqual(
            organization_service.service,
            self.service,
        )

    def test_duplicate_organization_service_is_rejected(self):
        OrganizationService.objects.create(
            organization=self.organization,
            service=self.service,
        )

        with self.assertRaises(IntegrityError):
            OrganizationService.objects.create(
                organization=self.organization,
                service=self.service,
            )

@override_settings(SECURE_SSL_REDIRECT=False)
class TaskReportOrganizationAuthorizationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.organization_user = User.objects.create_user(
            username="org_a_user",
            email="org-a@example.com",
            password="TestPassword123!",
            role="organization",
        )
        self.other_organization_user = User.objects.create_user(
            username="org_b_user",
            email="org-b@example.com",
            password="TestPassword123!",
            role="organization",
        )
        self.organization = Organization.objects.create(
            name="Task Report Org A",
            title="Task Report Org A",
            about="Organization A",
            user=self.organization_user,
        )
        Organization.objects.create(
            name="Task Report Org B",
            title="Task Report Org B",
            about="Organization B",
            user=self.other_organization_user,
        )

        refugee_user = User.objects.create_user(
            username="task_refugee",
            email="task-refugee@example.com",
            password="TestPassword123!",
            role="refugee",
        )
        volunteer_user = User.objects.create_user(
            username="task_volunteer",
            email="task-volunteer@example.com",
            password="TestPassword123!",
            role="volunteer",
        )
        self.volunteer = volunteer_user.volunteer_profile
        self.volunteer.organization = self.organization
        self.volunteer.full_name = "Test Volunteer"
        self.volunteer.profile_completed = True
        self.volunteer.save()

        service = Service.objects.create(
            name="Task Report Service",
            description="Test service",
            icon="test",
            service_type="food",
        )
        service_request = ServiceRequest.objects.create(
            refugee=refugee_user.refugee_profile,
            service=service,
            organization=self.organization,
            family_members=1,
            description="Test request",
            location="Test location",
            status="completed",
        )
        self.task = Task.objects.create(
            service_request_id=service_request,
            volunteer_id=self.volunteer,
            title="Completed task",
            instructions="Test instructions",
            status="completed",
        )
        self.url = f"/api/organizations/tasks/{self.task.id}/report/"

    def test_other_organization_cannot_read_task_report(self):
        self.client.force_authenticate(user=self.other_organization_user)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 404)

    def test_other_organization_cannot_change_volunteer_points(self):
        original_points = self.volunteer.points
        self.client.force_authenticate(user=self.other_organization_user)
        response = self.client.patch(self.url, {"points": 999}, format="json")

        self.assertEqual(response.status_code, 404)
        self.volunteer.refresh_from_db()
        self.task.refresh_from_db()
        self.assertEqual(self.volunteer.points, original_points)
        self.assertFalse(self.task.report_reviewed)

    def test_owning_organization_can_read_and_review_task_report(self):
        self.client.force_authenticate(user=self.organization_user)
        read_response = self.client.get(self.url)
        self.assertEqual(read_response.status_code, 200)

        patch_response = self.client.patch(
            self.url, {"points": 12}, format="json"
        )
        self.assertEqual(patch_response.status_code, 200)
        self.volunteer.refresh_from_db()
        self.task.refresh_from_db()
        self.assertEqual(self.volunteer.points, 12)
        self.assertTrue(self.task.report_reviewed)


@override_settings(SECURE_SSL_REDIRECT=False)
class TaskReportScoringValidationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.organization_user = User.objects.create_user(
            username="scoring_org",
            email="scoring-org@example.com",
            password="TestPassword123!",
            role="organization",
        )
        self.organization = Organization.objects.create(
            name="Scoring Test Org",
            title="Scoring Test Org",
            about="Scoring tests",
            user=self.organization_user,
        )
        refugee_user = User.objects.create_user(
            username="scoring_refugee",
            email="scoring-refugee@example.com",
            password="TestPassword123!",
            role="refugee",
        )
        volunteer_user = User.objects.create_user(
            username="scoring_volunteer",
            email="scoring-volunteer@example.com",
            password="TestPassword123!",
            role="volunteer",
        )
        self.volunteer = volunteer_user.volunteer_profile
        self.volunteer.organization = self.organization
        self.volunteer.full_name = "Scoring Volunteer"
        self.volunteer.profile_completed = True
        self.volunteer.save()
        service = Service.objects.create(
            name="Scoring Service",
            description="Test service",
            icon="test",
            service_type="food",
        )
        service_request = ServiceRequest.objects.create(
            refugee=refugee_user.refugee_profile,
            service=service,
            organization=self.organization,
            family_members=1,
            description="Test request",
            location="Test location",
            status="completed",
        )
        task = Task.objects.create(
            service_request_id=service_request,
            volunteer_id=self.volunteer,
            title="Completed task",
            instructions="Test instructions",
            status="completed",
        )
        self.url = f"/api/organizations/tasks/{task.id}/report/"
        self.client.force_authenticate(user=self.organization_user)

    def test_rejects_negative_points(self):
        response = self.client.patch(self.url, {"points": -1}, format="json")
        self.assertEqual(response.status_code, 400)
        self.volunteer.refresh_from_db()
        self.assertEqual(self.volunteer.points, 0)

    def test_rejects_points_above_ui_limit(self):
        response = self.client.patch(self.url, {"points": 10001}, format="json")
        self.assertEqual(response.status_code, 400)
        self.volunteer.refresh_from_db()
        self.assertEqual(self.volunteer.points, 0)

    def test_rejects_boolean_as_integer_points(self):
        response = self.client.patch(self.url, {"points": True}, format="json")
        self.assertEqual(response.status_code, 400)
        self.volunteer.refresh_from_db()
        self.assertEqual(self.volunteer.points, 0)

    def test_unverified_volunteer_cannot_be_scored(self):
        self.volunteer.profile_completed = False
        self.volunteer.save(update_fields=["profile_completed"])

        response = self.client.patch(
            self.url, {"points": 50}, format="json"
        )

        self.assertEqual(response.status_code, 404)
        self.volunteer.refresh_from_db()
        self.assertEqual(self.volunteer.points, 0)

    def test_accepts_maximum_allowed_points_and_prevents_second_review(self):
        response = self.client.patch(
            self.url, {"points": 10000}, format="json"
        )
        self.assertEqual(response.status_code, 200)
        self.volunteer.refresh_from_db()
        self.assertEqual(self.volunteer.points, 10000)

        second = self.client.patch(
            self.url, {"points": 10}, format="json"
        )
        self.assertEqual(second.status_code, 400)
        self.volunteer.refresh_from_db()
        self.assertEqual(self.volunteer.points, 10000)


@override_settings(SECURE_SSL_REDIRECT=False)
class TaskAssignmentVolunteerVerificationTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.organization_user = User.objects.create_user(
            username="assign_org",
            email="assign-org@example.com",
            password="TestPassword123!",
            role="organization",
        )
        self.organization = Organization.objects.create(
            name="Assignment Verification Org",
            title="Assignment Verification Org",
            about="Assignment verification tests",
            user=self.organization_user,
        )
        volunteer_user = User.objects.create_user(
            username="unverified_assign_volunteer",
            email="unverified-assign-volunteer@example.com",
            password="TestPassword123!",
            role="volunteer",
        )
        self.volunteer = volunteer_user.volunteer_profile
        self.volunteer.organization = self.organization
        self.volunteer.profile_completed = False
        self.volunteer.save(update_fields=["organization", "profile_completed"])

        refugee = User.objects.create_user(
            username="assign_refugee",
            email="assign-refugee@example.com",
            password="TestPassword123!",
            role="refugee",
        )
        service = Service.objects.create(
            name="Assignment Service",
            description="Test service",
            icon="test",
            service_type="food",
        )
        self.request_record = ServiceRequest.objects.create(
            refugee=refugee.refugee_profile,
            service=service,
            organization=self.organization,
            family_members=1,
            description="Request for task assignment",
            location="Test location",
            status="approved",
        )
        self.client.force_authenticate(user=self.organization_user)

    def test_unverified_volunteer_is_not_in_assignment_list(self):
        response = self.client.get("/api/organizations/assign-task/")
        self.assertEqual(response.status_code, 200)
        listed_ids = [v["id"] for v in response.data["volunteers"]]
        self.assertNotIn(self.volunteer.id, listed_ids)

    def test_unverified_volunteer_cannot_be_assigned_through_list_endpoint(self):
        response = self.client.post(
            "/api/organizations/assign-task/",
            {
                "service_request_id": self.request_record.id,
                "volunteer_id": self.volunteer.id,
                "title": "Test task",
                "instructions": "Test instructions",
            },
            format="json",
        )
        self.assertEqual(response.status_code, 404)
        self.assertFalse(
            Task.objects.filter(service_request_id=self.request_record).exists()
        )

    def test_unverified_volunteer_cannot_be_assigned_through_single_request_endpoint(self):
        response = self.client.post(
            f"/api/organizations/assign-task/{self.request_record.id}/",
            {
                "volunteer_id": self.volunteer.id,
                "title": "Test task",
                "instructions": "Test instructions",
            },
            format="json",
        )
        self.assertEqual(response.status_code, 404)
        self.assertFalse(
            Task.objects.filter(service_request_id=self.request_record).exists()
        )


@override_settings(SECURE_SSL_REDIRECT=False)
class ApplicationApprovalResetsVolunteerVerificationTests(TestCase):
    def test_new_organization_approval_requires_a_fresh_pin(self):
        from datetime import timedelta
        from unittest.mock import patch
        from django.utils import timezone

        self.client = APIClient()
        organization_user = User.objects.create_user(
            username="fresh_pin_org",
            email="fresh-pin-org@example.com",
            password="TestPassword123!",
            role="organization",
        )
        new_organization = Organization.objects.create(
            name="New Approval Organization",
            title="New Approval Organization",
            about="Fresh PIN approval test",
            user=organization_user,
        )
        old_organization = Organization.objects.create(
            name="Previous Organization",
            title="Previous Organization",
            about="Previously verified organization",
        )
        volunteer_user = User.objects.create_user(
            username="previously_verified_volunteer",
            email="previously-verified-volunteer@example.com",
            password="TestPassword123!",
            role="volunteer",
        )
        profile = volunteer_user.volunteer_profile
        profile.organization = old_organization
        profile.profile_completed = True
        profile.verification_pin = "4321"
        profile.pin_expires_at = timezone.now() + timedelta(minutes=10)
        profile.qr_code = "old-organization-qr"
        profile.save()

        application = VolunteerApplication.objects.create(
            user=volunteer_user,
            organization=new_organization,
            phone_number="123456789",
            why_volunteer="I want to help.",
            i_commit=True,
            i_agree_terms=True,
            status="pending",
            is_verified=True,
        )
        self.client.force_authenticate(user=organization_user)

        with patch("accounts.utils.send_aidora_email") as send_email:
            response = self.client.patch(
                f"/api/organizations/applications/{application.id}/update-status/",
                {"status": "approved"},
                format="json",
            )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(send_email.call_count, 1)

        application.refresh_from_db()
        profile.refresh_from_db()
        self.assertEqual(application.status, "approved")
        self.assertFalse(application.is_verified)
        self.assertEqual(profile.organization, new_organization)
        self.assertFalse(profile.profile_completed)
        self.assertNotEqual(profile.verification_pin, "4321")
        self.assertIsNotNone(profile.pin_expires_at)
        self.assertIsNone(profile.qr_code)
