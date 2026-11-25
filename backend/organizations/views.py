from django.db import transaction
from rest_framework import generics
from rest_framework.generics import ListAPIView
from .models import Service
from .serializers import (
    ServiceTypeSerializer,
    OrganizationCardSerializer,
    OrganizationDetailSerializer,
    TaskSerializer,
)
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from organizations.models import OrganizationService
from .serializers import OrganizationServiceSerializer
from rest_framework.decorators import api_view
from .models import Organization
from accounts.permissions import IsRole
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from drf_spectacular.utils import extend_schema

@extend_schema(tags=["Organizations"])
class OrganizationServicesView(APIView):  
    permission_classes = [IsRole,IsAuthenticated]
    allowed_roles = ["volunteer"]
    def get(self, request, id):

        services = OrganizationService.objects.filter(
            organization_id=id
        ).select_related('service')

        serializer = OrganizationServiceSerializer(services, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)
    

from accounts.models import VolunteerApplication
from .serializers import VolunteerApplicationDetailSerializer
from django.utils.timezone import now    
from django.shortcuts import get_object_or_404
@extend_schema(tags=["Organizations"])
class OrganizationApplicationsAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request):
        organization = request.user.organization

        status_filter = request.query_params.get('status')

        applications = VolunteerApplication.objects.filter(
            organization=organization
        ).select_related(
            'user',
            'user__volunteer_profile'
        ).prefetch_related(
            'selected_services__service'
        ).order_by('-id')

        # 🔹 الفلترة (للتوبات)
        if status_filter and status_filter != "all":
            applications = applications.filter(status=status_filter)

        serializer = VolunteerApplicationDetailSerializer(
            applications,
            many=True,
            context={'request': request}
        )

        return Response({
            "applications": serializer.data
        })
    
    def patch(self, request, pk):
        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Application not found"}, status=404)

        new_status = request.data.get("status")
        if new_status not in {"approved", "rejected"}:
            return Response({"error": "Invalid status"}, status=400)

        with transaction.atomic():
            application = VolunteerApplication.objects.select_for_update().filter(
                id=pk,
                organization=organization,
            ).select_related("user", "organization").first()

            if application is None:
                return Response({"error": "Application not found"}, status=404)

            if application.status != "pending":
                return Response(
                    {"error": "Only pending applications can be updated"},
                    status=400,
                )

            application.status = new_status
            application.processed_at = now()
            application.save(update_fields=["status", "processed_at", "is_verified"])

        serializer = VolunteerApplicationDetailSerializer(
            application,
            context={"request": request},
        )
        return Response(serializer.data)





from django.db.models import Count
from service_requests.models import ServiceRequest, Task
from django.db.models import Q
from .serializers import OrganizationRequestSerializer,OrganizationTaskSerializer
@extend_schema(tags=["Organizations"])
class OrganizationDashboardAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request):
        organization = request.user.organization

        # 🔹 Statistics
        stats = ServiceRequest.objects.filter(
            organization=organization
        ).aggregate(
            pending=Count('id', filter=Q(status='pending')),
            approved=Count('id', filter=Q(status='approved')),
            completed=Count('id', filter=Q(status='completed')),
        )

        # 🔹 Latest 3 requests
        latest_requests = ServiceRequest.objects.filter(
            organization=organization
        ).select_related(
            'service'
        ).order_by('-created_at')[:3]

        requests_serializer = OrganizationRequestSerializer(
            latest_requests,
            many=True
        )

        # 🔹 Completed Tasks
        tasks = Task.objects.filter(
            service_request_id__organization=organization,
            status='completed'
        ).select_related(
            'volunteer_id'
        ).order_by('-updated_at')

        tasks_serializer = OrganizationTaskSerializer(tasks, many=True)
        
        return Response({
        "pending": stats["pending"],
        "approved": stats["approved"],
        "completed": stats["completed"],
        "requests": requests_serializer.data,
        "tasks": tasks_serializer.data
})
    





from .serializers import TaskReportSerializer
@extend_schema(tags=["Organizations"])
class TaskReportAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get_object(self, request, pk):
        try:
            organization = request.user.organization
        except Organization.DoesNotExist:
            return get_object_or_404(Task.objects.none(), id=pk)

        queryset = Task.objects.filter(
            service_request_id__organization=organization
        ).select_related(
            'service_request_id',
            'volunteer_id'
        ).filter(
            volunteer_id__profile_completed=True,
        )
        return get_object_or_404(queryset, id=pk)

    def get(self, request, pk):
        task = self.get_object(request, pk)

        # 🔐 حماية
        if task.status != 'completed' or task.service_request_id.status != 'completed':
            return Response(
                {"error": "Report not available until completion"},
                status=403
            )

        serializer = TaskReportSerializer(task)
        return Response(serializer.data)

    def patch(self, request, pk):
        points = request.data.get("points")
        if type(points) is not int or not 0 <= points <= 10000:
            return Response(
                {"error": "Points must be an integer between 0 and 10000"},
                status=400,
            )

        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Task not found"}, status=404)

        with transaction.atomic():
            task = Task.objects.select_for_update(of=("self",)).filter(
                id=pk,
                service_request_id__organization=organization,
            ).select_related(
                "service_request_id",
            ).filter(
                volunteer_id__profile_completed=True,
            ).first()

            if task is None:
                return Response({"error": "Task not found"}, status=404)

            if (
                task.status != "completed"
                or task.service_request_id.status != "completed"
            ):
                return Response(
                    {"error": "Cannot update before completion"},
                    status=403,
                )

            if task.report_reviewed:
                return Response({"error": "Already reviewed"}, status=400)

            if task.volunteer_id_id is None:
                return Response({"error": "No volunteer assigned"}, status=400)

            volunteer = VolunteerProfile.objects.select_for_update().get(
                pk=task.volunteer_id_id,
                profile_completed=True,
            )
            task.volunteer_id = volunteer
            volunteer.points = points
            volunteer.save(update_fields=["points", "updated_at"])

            task.report_reviewed = True
            task.save(update_fields=["report_reviewed", "updated_at"])

        serializer = TaskReportSerializer(task)
        return Response(serializer.data)

    
from .serializers import AssignTaskGetSerializer, AssignTaskResponseSerializer
from accounts.models import Notification
from accounts.models import VolunteerProfile
@extend_schema(tags=["Organizations"])
class AssignTaskAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request, request_id):
        service_request = get_object_or_404(
            ServiceRequest,
            id=request_id,
            organization=request.user.organization
        )
        serializer = AssignTaskGetSerializer(
            service_request,
            context={'request': request}
        )
        return Response(serializer.data)

    def post(self, request, request_id):
        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Request not found"}, status=404)

        volunteer_id = request.data.get("volunteer_id")
        title = request.data.get("title")
        instructions = request.data.get("instructions")

        if not isinstance(title, str) or not title.strip() or len(title.strip()) > 255:
            return Response({"error": "A task title of 1-255 characters is required"}, status=400)
        if not isinstance(instructions, str) or not instructions.strip() or len(instructions.strip()) > 5000:
            return Response({"error": "Task instructions of 1-5000 characters are required"}, status=400)

        with transaction.atomic():
            service_request = get_object_or_404(
                ServiceRequest.objects.select_for_update(),
                id=request_id,
                organization=organization,
            )

            if service_request.status != "approved":
                return Response(
                    {"error": "Request must be approved first"},
                    status=400,
                )

            if Task.objects.filter(service_request_id=service_request).exists():
                return Response({"error": "Task already assigned"}, status=400)

            # Serialize assignment with organization re-approval, which also
            # locks and resets this volunteer profile.
            volunteer = get_object_or_404(
                VolunteerProfile.objects.select_for_update(),
                id=volunteer_id,
                organization=organization,
                profile_completed=True,
            )

            task = Task.objects.create(
                service_request_id=service_request,
                volunteer_id=volunteer,
                title=title.strip(),
                instructions=instructions.strip(),
            )

            Notification.objects.create(
                user=volunteer.user,
                message=(
                    f"You can pick up the service request {service_request.service.name}. "
                    f"The task has been assigned to {volunteer.full_name}."
                ),
                notification_type="assigned",
            )

        serializer = AssignTaskResponseSerializer(task)
        return Response(serializer.data, status=201)

class TaskListAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request):
        # 🔹 Filter by organization
        tasks = Task.objects.filter(
            service_request_id__organization=request.user.organization
        ).select_related(
            'volunteer_id', 'service_request_id'
        )

        # 🔹 Statistics (counts for each status)
        stats = tasks.aggregate(
            pending=Count('id', filter=Q(status='pending')),
            completed=Count('id', filter=Q(status='completed')),
            failed=Count('id', filter=Q(status='failed'))
        )

        # 🔹 Serialize tasks
        task_serializer = TaskSerializer(tasks, many=True)

        return Response({
        "pending": stats["pending"],
        "failed": stats["failed"],
        "completed": stats["completed"],
        "tasks": task_serializer.data
        })
    

@extend_schema(tags=["Organizations"])
class ReassignTaskAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def patch(self, request, task_id):
        task = get_object_or_404(
            Task,
            id=task_id,
            service_request_id__organization=request.user.organization,
            volunteer_id__profile_completed=True,
        )

        # 🔒 فقط إذا كانت failed
        if task.status != 'failed':
            return Response(
                {"error": "Only failed tasks can be reassigned"},
                status=400
            )

        # 🔥 رجعها pending + احذف السبب
        task.status = 'pending'
        task.rejection_reason = None
        task.save()

        return Response({
            "message": "Task reassigned successfully",
            "task_id": task.id,
            "status": task.status
        })
from .serializers import VolunteerListSerializer,ApprovedServiceRequestSerializer
@extend_schema(tags=["Organizations"])
class AssignTaskListAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request):

        service_requests = ServiceRequest.objects.filter(
            organization=request.user.organization,
            status='approved'
        )

        volunteers = VolunteerProfile.objects.filter(
            organization=request.user.organization,
            profile_completed=True,
        )

        return Response({
            "service_requests": ApprovedServiceRequestSerializer(
                service_requests,
                many=True
            ).data,
            "volunteers": VolunteerListSerializer(
                volunteers,
                many=True
            ).data
        })

    def post(self, request):
        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Request not found"}, status=404)

        service_request_id = request.data.get("service_request_id")
        volunteer_id = request.data.get("volunteer_id")
        title = request.data.get("title")
        instructions = request.data.get("instructions")

        if not isinstance(title, str) or not title.strip() or len(title.strip()) > 255:
            return Response({"error": "A task title of 1-255 characters is required"}, status=400)
        if not isinstance(instructions, str) or not instructions.strip() or len(instructions.strip()) > 5000:
            return Response({"error": "Task instructions of 1-5000 characters are required"}, status=400)

        with transaction.atomic():
            service_request = get_object_or_404(
                ServiceRequest.objects.select_for_update(),
                id=service_request_id,
                organization=organization,
                status="approved",
            )

            if Task.objects.filter(service_request_id=service_request).exists():
                return Response({"error": "Task already assigned"}, status=400)

            volunteer = get_object_or_404(
                VolunteerProfile,
                id=volunteer_id,
                organization=organization,
                profile_completed=True,
            )

            task = Task.objects.create(
                service_request_id=service_request,
                volunteer_id=volunteer,
                title=title.strip(),
                instructions=instructions.strip(),
            )

            Notification.objects.create(
                user=volunteer.user,
                message=(
                    f"You can pick up the service request {service_request.service.name}. "
                    f"The task has been assigned to {volunteer.full_name}."
                ),
                notification_type="assigned",
            )

        serializer = AssignTaskResponseSerializer(task)
        return Response(serializer.data, status=201)

class ServiceTypeListAPIView(ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = ServiceTypeSerializer

    def get_queryset(self):
        # نرجع فقط الـ 10 أنواع الأساسية بدون تكرار
        return Service.objects.order_by('service_type').distinct('service_type')
@extend_schema(tags=["Organizations"])
class OrganizationsByServiceTypeAPIView(APIView):
    permission_classes = [AllowAny]
    def get(self, request, service_type):
        organizations = Organization.objects.filter(
            organization_services__service__service_type__iexact=service_type
        ).distinct()
        

        data = [
            {
                "name": org.name,
                "logo": request.build_absolute_uri(org.logo.url) if org.logo else None,
                "id" :org.id,
            }
            for org in organizations
        ]

        return Response(data)
@extend_schema(tags=["Organizations"])
class OrganizationCardListAPIView(ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = OrganizationCardSerializer

    def get_queryset(self):
        return Organization.objects.all()[:6]

@extend_schema(tags=["Organizations"])
class OrganizationDetailAPIView(generics.RetrieveAPIView):
    permission_classes = [AllowAny]

    queryset = Organization.objects.all()
    serializer_class = OrganizationDetailSerializer   



from .serializers import OrganizationProfileSerializer
@extend_schema(tags=["Organizations"])
class MyOrganizationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        # تحقق إنو المستخدم دوره organization
        if user.role != 'organization':
            return Response({"error": "You are not an organization user"}, status=403)

        try:
            organization = user.organization
        except Organization.DoesNotExist:
            return Response({"error": "No organization found for this user"}, status=404)

        serializer = OrganizationProfileSerializer(organization)
        return Response(serializer.data)


