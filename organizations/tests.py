from django.db import IntegrityError
from django.test import TestCase

from .models import Organization, OrganizationService, Service


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