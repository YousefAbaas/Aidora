from django.db import IntegrityError
from django.test import TestCase

from .models import Organization, OrganizationService, Service
from accounts.models import User
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
