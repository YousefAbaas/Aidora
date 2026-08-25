from django.test import TestCase

from accounts.models import RefugeeProfile, User
from organizations.models import Organization, Service

from .models import ServiceRequest, Task


class ServiceRequestModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="test_refugee",
            email="refugee@example.com",
            password="TestPassword123!",
            role="refugee",
        )

        self.refugee = self.user.refugee_profile

        self.service = Service.objects.create(
            name="Test Food Service",
            description="Test food service.",
            icon="food",
            service_type="food",
        )

        self.organization = Organization.objects.create(
            name="Test Organization",
            title="Test Organization Title",
            about="Test organization description.",
        )

    def test_service_request_defaults_are_correct(self):
        request = ServiceRequest.objects.create(
            refugee=self.refugee,
            service=self.service,
            family_members=3,
            description="Need food assistance.",
            location="Test Location",
        )

        self.assertEqual(request.status, "pending")
        self.assertEqual(request.urgency_level, "normal")
        self.assertEqual(request.family_members, 3)

    def test_service_request_can_be_assigned_to_organization(self):
        request = ServiceRequest.objects.create(
            refugee=self.refugee,
            service=self.service,
            family_members=2,
            description="Need assistance.",
            organization=self.organization,
            location="Test Location",
        )

        self.assertEqual(request.organization, self.organization)
        self.assertEqual(request.refugee, self.refugee)
        self.assertEqual(request.service, self.service)

    def test_task_is_created_with_pending_status(self):
        request = ServiceRequest.objects.create(
            refugee=self.refugee,
            service=self.service,
            family_members=1,
            description="Need assistance.",
            location="Test Location",
        )

        task = Task.objects.create(
            service_request_id=request,
            title="Deliver assistance",
            instructions="Deliver the requested service.",
        )

        self.assertEqual(task.status, "pending")
        self.assertEqual(task.service_request_id, request)
        self.assertIsNone(task.volunteer_id)