from django.test import TestCase, override_settings

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

class ScanQRAuthorizationTests(TestCase):
    """The QR completion endpoint must require a refugee who owns the request."""

    def setUp(self):
        from rest_framework.test import APIClient
        from rest_framework_simplejwt.tokens import RefreshToken

        self.client = APIClient()
        self.owner = User.objects.create_user(
            username="owner", email="owner@example.com",
            password="TestPassword123!", role="refugee",
        )
        self.other = User.objects.create_user(
            username="other", email="other@example.com",
            password="TestPassword123!", role="refugee",
        )
        service = Service.objects.create(
            name="Svc", description="d", icon="food", service_type="food",
        )
        self.org = Organization.objects.create(name="Org", title="Org", about="a")
        self.req = ServiceRequest.objects.create(
            refugee=self.owner.refugee_profile, service=service, organization=self.org,
            family_members=1, description="x", location="y", status="approved",
        )
        self.volunteer_user = User.objects.create_user(
            username="qr_volunteer",
            email="qr-volunteer@example.com",
            password="TestPassword123!",
            role="volunteer",
        )
        self.volunteer = self.volunteer_user.volunteer_profile
        self.volunteer.organization = self.org
        self.volunteer.qr_code = "qr-assigned-volunteer"
        self.volunteer.save(update_fields=["organization", "qr_code"])
        self.url = f"/api/requests/{self.req.id}/scan-qr/"
        self._token = lambda u: str(RefreshToken.for_user(u).access_token)

    def test_anonymous_cannot_scan(self):
        r = self.client.post(self.url, {"qr_code": "x"}, format="json", secure=True)
        self.assertEqual(r.status_code, 401)

    def test_other_refugee_gets_404(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self._token(self.other)}")
        r = self.client.post(self.url, {"qr_code": "x"}, format="json", secure=True)
        self.assertEqual(r.status_code, 404)

    def test_owner_reaches_qr_validation(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self._token(self.owner)}")
        r = self.client.post(self.url, {"qr_code": "not-a-real-code"}, format="json", secure=True)
        self.assertEqual(r.status_code, 400)  # invalid QR, not an auth error

    def test_missing_qr_cannot_match_a_profile_without_generated_qr(self):
        self.volunteer.qr_code = None
        self.volunteer.save(update_fields=["qr_code"])
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self._token(self.owner)}")

        response = self.client.post(self.url, {}, format="json", secure=True)

        self.assertEqual(response.status_code, 400)
        self.req.refresh_from_db()
        self.assertEqual(self.req.status, "approved")

    def test_same_organization_but_unassigned_volunteer_cannot_complete_request(self):
        self.volunteer.qr_code = "qr-unassigned-volunteer"
        self.volunteer.save(update_fields=["qr_code"])
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self._token(self.owner)}")

        response = self.client.post(
            self.url,
            {"qr_code": self.volunteer.qr_code},
            format="json",
            secure=True,
        )

        self.assertEqual(response.status_code, 400)
        self.req.refresh_from_db()
        self.assertEqual(self.req.status, "approved")

    def test_assigned_volunteers_completed_task_can_complete_request(self):
        Task.objects.create(
            service_request_id=self.req,
            volunteer_id=self.volunteer,
            title="Deliver assistance",
            instructions="Confirm the handover",
            status="completed",
        )
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self._token(self.owner)}")

        response = self.client.post(
            self.url,
            {"qr_code": self.volunteer.qr_code},
            format="json",
            secure=True,
        )

        self.assertEqual(response.status_code, 200)
        self.req.refresh_from_db()
        self.assertEqual(self.req.status, "completed")
        self.assertIsNotNone(self.req.received_at)

    def test_assigned_volunteers_pending_task_cannot_complete_request(self):
        Task.objects.create(
            service_request_id=self.req,
            volunteer_id=self.volunteer,
            title="Deliver assistance",
            instructions="Confirm the handover",
            status="pending",
        )
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self._token(self.owner)}")

        response = self.client.post(
            self.url,
            {"qr_code": self.volunteer.qr_code},
            format="json",
            secure=True,
        )

        self.assertEqual(response.status_code, 400)
        self.req.refresh_from_db()
        self.assertEqual(self.req.status, "approved")



@override_settings(SECURE_SSL_REDIRECT=False)
class RefugeeRequestDetailAuthorizationTests(TestCase):
    def setUp(self):
        from rest_framework.test import APIClient

        self.client = APIClient()
        self.owner = User.objects.create_user(
            username="request_owner",
            email="request-owner@example.com",
            password="TestPassword123!",
            role="refugee",
        )
        self.other_refugee = User.objects.create_user(
            username="other_refugee",
            email="other-refugee@example.com",
            password="TestPassword123!",
            role="refugee",
        )
        service = Service.objects.create(
            name="Private Request Service",
            description="Test service",
            icon="test",
            service_type="food",
        )
        organization = Organization.objects.create(
            name="Private Request Org",
            title="Private Request Org",
            about="Test organization",
        )
        self.owner.refugee_profile.sector_name = "Test sector"
        self.owner.refugee_profile.save(update_fields=["sector_name"])

        self.request_record = ServiceRequest.objects.create(
            refugee=self.owner.refugee_profile,
            service=service,
            organization=organization,
            family_members=4,
            description="Private request details",
            location="Private location",
            status="approved",
        )
        self.url = f"/api/requests/{self.request_record.id}/details/"

    def test_other_refugee_cannot_read_request_details(self):
        self.client.force_authenticate(user=self.other_refugee)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 404)

    def test_request_owner_can_read_own_details(self):
        self.client.force_authenticate(user=self.owner)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["family_members"], 4)
