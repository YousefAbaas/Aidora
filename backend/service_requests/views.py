from django.db import transaction
from django.shortcuts import render
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from organizations.models import Service, Organization, OrganizationService
from .models import ServiceRequest
from .serializers import ServiceRequestCreateSerializer
from accounts.permissions import IsRole
from .permissions import IsProfileCompleted
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from drf_spectacular.utils import extend_schema
@extend_schema(tags=["Service Requests"])
class ServiceRequestFormView(APIView):
    permission_classes = [IsAuthenticated, IsProfileCompleted, IsRole]
    allowed_roles = ["refugee"]
    def get(self, request, organization_id, service_id):
        try:
            organization = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({"error": "Organization not found"}, status=404)

        # تحقق أن الخدمة تابعة للمنظمة
        if not OrganizationService.objects.filter(
            organization=organization,
            service_id=service_id
        ).exists():
            return Response(
                {"error": "This service does not belong to the organization."},
                status=status.HTTP_400_BAD_REQUEST
            )

        service = Service.objects.get(id=service_id)

        return Response({
            "service_name": service.name,
            "service_description": service.description
        })

    def post(self, request, organization_id, service_id):
        try:
            organization = Organization.objects.get(id=organization_id)
        except Organization.DoesNotExist:
            return Response({"error": "Organization not found"}, status=404)

        if not OrganizationService.objects.filter(
            organization=organization,
            service_id=service_id
        ).exists():
            return Response(
                {"error": "This service does not belong to the organization."},
                status=status.HTTP_400_BAD_REQUEST
            )

        service = Service.objects.get(id=service_id)
        refugee = request.user.refugee_profile

        serializer = ServiceRequestCreateSerializer(data=request.data)

        if serializer.is_valid():
            request_obj = serializer.save(
                refugee=refugee,
                service=service,
                organization=organization,
                status="pending"
            )

            return Response({
                "message": "Request sent successfully",
                "request_id": request_obj.id
            }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


from rest_framework.views import APIView
from rest_framework.response import Response
from django.db.models import Count, Q
from .models import Task
@extend_schema(tags=["Service Requests"])
class VolunteerHomeAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["volunteer"]

    def get(self, request):
        volunteer = request.user.volunteer_profile

        # 🔹 معلومات المتطوع
        full_name = volunteer.full_name

        profile_image = None
        if volunteer.profile_image:
          profile_image = request.build_absolute_uri(
        volunteer.profile_image.url
              )
        # 🔹 كل المهام تبعه
        tasks = Task.objects.filter(volunteer_id=volunteer)

        # 🔹 الإحصائيات
        stats = tasks.aggregate(
            completed=Count('id', filter=Q(status='completed')),
            failed=Count('id', filter=Q(status='failed')),
            pending=Count('id', filter=Q(status='pending')),
        )

        # 🔹 آخر 3 مهام (الأحدث)
        last_tasks = tasks.select_related('service_request_id__service')\
                          .order_by('-created_at')[:3]

        from .serializers import TaskHomeSerializer
        last_tasks_data = TaskHomeSerializer(
            last_tasks,
            many=True,
            context={'request': request}  # 🔥 مهم
        ).data

        return Response({
            "full_name": full_name,
            "profile_image": profile_image,
            "statistics": stats,
            "recent_tasks": last_tasks_data
        })

from rest_framework.generics import ListAPIView
from .serializers import TaskListSerializer
@extend_schema(tags=["Service Requests"])
class VolunteerTasksAPIView(ListAPIView):
    serializer_class = TaskListSerializer
    permission_classes=[IsAuthenticated,IsRole]
    allowed_roles = ["volunteer"]

    def get_queryset(self):
        volunteer = self.request.user.volunteer_profile
        status_filter = self.request.query_params.get('status', 'all')

        queryset = Task.objects.filter(
            volunteer_id=volunteer
        ).select_related('service_request_id')

        if status_filter != 'all':
            queryset = queryset.filter(status=status_filter)

        return queryset.order_by('-created_at')

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()

        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)        

@extend_schema(tags=["Service Requests"])
class TaskUpdateAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["volunteer"]

    def get(self, request, id):
        volunteer = request.user.volunteer_profile
        if not volunteer.profile_completed:
            return Response({"error": "Volunteer PIN verification is required"}, status=403)

        try:
            task = Task.objects.get(id=id, volunteer_id=volunteer, status="pending")
        except Task.DoesNotExist:
            return Response({"error": "Task not found"}, status=404)

        return Response({
            "title": task.title,
            "request_display": f"Request#{str(task.service_request_id.id).zfill(4)}",
        })

    def patch(self, request, id):
        volunteer = request.user.volunteer_profile
        if not volunteer.profile_completed:
            return Response({"error": "Volunteer PIN verification is required"}, status=403)

        with transaction.atomic():
            task = Task.objects.select_for_update().filter(
                id=id,
                volunteer_id=volunteer,
            ).first()
            if task is None:
                return Response({"error": "Task not found"}, status=404)

            if task.status != "pending":
                return Response(
                    {"error": "Only pending tasks can be updated"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            new_status = request.data.get("status")
            if new_status not in {"failed", "completed"}:
                return Response(
                    {"error": "Status must be either 'failed' or 'completed'"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            reason = request.data.get("rejection_reason")
            if new_status == "failed":
                if not isinstance(reason, str) or not reason.strip():
                    return Response(
                        {"error": "A rejection reason is required for failed status"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                if len(reason.strip()) > 2000:
                    return Response(
                        {"error": "Rejection reason must not exceed 2000 characters"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                task.rejection_reason = reason.strip()
            else:
                task.rejection_reason = ""

            task.status = new_status
            task.save(update_fields=["status", "rejection_reason", "updated_at"])

        from .serializers import TaskUpdateSerializer

        serializer = TaskUpdateSerializer(task, context={"request": request})
        return Response(serializer.data)


#شهد
from django.shortcuts import render
from rest_framework import generics
from rest_framework import status
from rest_framework.generics import ListAPIView
from organizations.models import Service ,OrganizationService,Organization
from .serializers import ServiceSerializer
from rest_framework.generics import CreateAPIView
from rest_framework.permissions import IsAuthenticated,AllowAny
from .models import ServiceRequest
from .serializers import CreateRequestSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils.timezone import now
from django.utils import timezone
from accounts.models import VolunteerProfile
from .serializers import (
    ApprovedRequestSerializer,
    RejectedRequestSerializer,
    RefugeeMiniSerializer)
from .serializers import ServiceRequestDetailSerializer
from .serializers import ConfirmDeliverySerializer
from .serializers import (
    ApprovedSerializer,
    CompletedSerializer,
    RejectedSerializer,
    PendingSerializer
)
from .serializers import OrganizationRequestSerializer
from .serializers import RequestDetailsSerializer
from .serializers import ApproveButtonSerializer
from .serializers import RejectButtonSerializer
from accounts.models import Notification

@extend_schema(tags=["Service Requests"])
class OrganizationServicesAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]

    def get(self, request, pk):
        services = OrganizationService.objects.filter(
            organization_id=pk
        ).select_related("service")

        data = [
            {
                "id": item.service.id,
                "name": item.service.name,
                'icon':item.service.icon,
            }
            for item in services
        ]

        return Response(data)
@extend_schema(tags=["Service Requests"])
class CreateRequestAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole,IsProfileCompleted]
    allowed_roles = ["refugee"]
    46
    def post(self, request, pk):
       
        organization = Organization.objects.filter(id=pk).first()
        if not organization:
            return Response({"error": "Organization not found"}, status=404)

        #refugee = ServiceRequest.objects.first().refugee
        refugee = request.user.refugee_profile
        serializer = CreateRequestSerializer(data=request.data,context={"organization": organization})

        if serializer.is_valid():
            serializer.save(
                refugee=refugee,
                organization=organization
            )
            return Response({"message": "Request submitted successfully"}, status=201)

        return Response(serializer.errors, status=400)
@extend_schema(tags=["Service Requests"])
class MyRequestsAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]
    def get(self, request):

        refugee = request.user.refugee_profile
        requests = ServiceRequest.objects.filter(
             refugee=refugee).select_related( "refugee","service","organization") 
        # refugee = ServiceRequest.objects.first().refugee  # مؤقت للتجربة
        # requests = ServiceRequest.objects.filter( refugee=refugee)

        refugee_data = RefugeeMiniSerializer( refugee,context={"request": request}).data
        total_requests = requests.count()
        approved_requests = requests.filter(status="approved").count()
        rejected_requests = requests.filter(status="rejected").count()
        
        approved_list = requests.filter(status="approved")
        rejected_list = requests.filter(status="rejected") 

        data = {
            "refugee": refugee_data,
            "Total": total_requests,
            "Approved": approved_requests,
            "Rejected": rejected_requests,
                        
            "Approved Requests": ApprovedRequestSerializer(approved_list, many=True).data,
            "Rejected Requests": RejectedRequestSerializer(rejected_list, many=True).data,
            
        }

        return Response(data)
@extend_schema(tags=["Service Requests"])
class ServiceRequestDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]
    def get(self, request, pk):
        service_request = ServiceRequest.objects.filter(
            id=pk,
            refugee__user=request.user,
        ).select_related(
            "organization", "service", "refugee"
        ).first()

        if not service_request:
            return Response({"error": "Request not found"}, status=404)

        serializer = ServiceRequestDetailSerializer(service_request,context={"request": request})
        return Response(serializer.data)

from django.utils.timezone import now
@extend_schema(tags=["Service Requests"])
class ScanQRAPIView(APIView):
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]

    def post(self, request, pk):
        qr_code = request.data.get("qr_code")
        if not isinstance(qr_code, str) or not qr_code.strip() or len(qr_code) > 100:
            return Response(
                {"error": "Invalid QR code for this request."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        qr_code = qr_code.strip()

        # Lock the request so two concurrent scans cannot complete it twice.
        with transaction.atomic():
            service_request = ServiceRequest.objects.select_for_update().filter(
                id=pk,
                refugee__user=request.user,
            ).first()

            if not service_request:
                return Response(
                    {"error": "Request not found"},
                    status=status.HTTP_404_NOT_FOUND,
                )

            if service_request.status == "completed":
                return Response(
                    {"error": "Request already completed"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if service_request.status != "approved":
                return Response(
                    {"error": "Request is not approved"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Never allow a missing/NULL QR value to match a profile whose
            # QR has not been generated.
            volunteer = VolunteerProfile.objects.filter(
                qr_code=qr_code,
                qr_code__isnull=False,
                organization_id=service_request.organization_id,
                profile_completed=True,
            ).first()

            if volunteer is None:
                return Response(
                    {"error": "Invalid QR code for this request."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Only the volunteer assigned to this request may confirm handover,
            # and only after they have marked the assigned task completed.
            assigned_completed_task = Task.objects.filter(
                service_request_id=service_request,
                volunteer_id=volunteer,
                status="completed",
            ).exists()

            if not assigned_completed_task:
                return Response(
                    {"error": "Invalid QR code for this request."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            service_request.status = "completed"
            service_request.received_at = now()
            service_request.save(update_fields=["status", "received_at", "updated_at"])

        return Response(
            {
                "message": "Request completed successfully",
                "request_id": f"R-{service_request.id}",
                "status": service_request.status,
                "received_at": service_request.received_at,
            },
            status=status.HTTP_200_OK,
        )
@extend_schema(tags=["Service Requests"])
class RequestsListAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]

    def get_serializer_class(self, status):
        if status == "approved":
            return ApprovedSerializer
        elif status == "completed":
            return CompletedSerializer
        elif status == "rejected":
            return RejectedSerializer
        elif status == "pending":
            return PendingSerializer
        else:
            return None  # للـ All

    def get(self, request):
        refugee = request.user.refugee_profile
        #refugee = ServiceRequest.objects.first().refugee
        status_filter = request.query_params.get("status")

        requests = ServiceRequest.objects.filter(refugee=refugee).select_related(
            "refugee", "service"
        )
        counts = {
            "All": requests.count(),

            "Approved": requests.filter(status="approved").count(),

            "Rejected": requests.filter(status="rejected").count(),

            "Pending": requests.filter(status="pending").count(),

            "Completed": requests.filter(status="completed").count(),
         }

        if status_filter:
            requests = requests.filter(status=status_filter)

        serializer_class = self.get_serializer_class(status_filter)

        if serializer_class:
            serializer = serializer_class(requests, many=True).data
        else:
            # All requests: يمكن دمجهم في JSON واحد حسب الحالة
            serializer = {
                "Approved": ApprovedSerializer(
                    requests.filter(status="approved"), many=True
                ).data,
                "Completed": CompletedSerializer(
                    requests.filter(status="completed"), many=True
                ).data,
                "Rejected": RejectedSerializer(
                    requests.filter(status="rejected"), many=True
                ).data,
                "Pending": PendingSerializer(
                    requests.filter(status="pending"), many=True
                ).data,
            }
        return Response({"counts": counts,"data": serializer}) 

@extend_schema(tags=["Service Requests"])
#تفاصيل عرض الطلبات بواجهة المنظمة
class OrganizationRequestsAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request):

        organization = request.user.organization

        status_filter = request.query_params.get("status")

        requests = ServiceRequest.objects.filter(
            organization=organization
        ).select_related(
            "refugee",
            "service"
        )

        if status_filter:
            requests = requests.filter(status=status_filter)

        serializer = OrganizationRequestSerializer(
            requests,
            many=True
        )

        return Response(serializer.data)
@extend_schema(tags=["Service Requests"])
class RequestDetailsAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def get(self, request, pk):
        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Request not found"}, status=404)

        req = get_object_or_404(
            ServiceRequest.objects.filter(organization=organization).select_related(
                "refugee", "service", "organization"
            ),
            id=pk,
        )
        serializer = RequestDetailsSerializer(req, context={"request": request})
        return Response(serializer.data)


from django.contrib.auth import get_user_model
User = get_user_model()
@extend_schema(tags=["Service Requests"])
#كرمال زر قبول الطلب
class ApproveButtonAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def post(self, request, pk):
        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Request not found"}, status=404)

        with transaction.atomic():
            req = ServiceRequest.objects.select_for_update().filter(
                id=pk,
                organization=organization,
            ).select_related("refugee", "service", "organization").first()
            if req is None:
                return Response({"error": "Request not found"}, status=404)

            if req.status != "pending":
                return Response({"error": "Request is not pending"}, status=400)

            req.status = "approved"
            req.approved_at = timezone.now()
            req.save(update_fields=["status", "approved_at", "updated_at"])

            Notification.objects.create(
                user=req.refugee.user,
                message=(
                    f"Your request has been approved by {req.organization.name} "
                    f"for service {req.service.name}"
                ),
                notification_type="approved",
            )

        return Response({"message": "Request approved successfully"}, status=200)


#كرمال زر رفض الطلب
@extend_schema(tags=["Service Requests"])
class RejectButtonAPIView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["organization"]

    def post(self, request, pk):
        serializer = RejectButtonSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        organization = getattr(request.user, "organization", None)
        if organization is None:
            return Response({"error": "Request not found"}, status=404)

        with transaction.atomic():
            req = ServiceRequest.objects.select_for_update().filter(
                id=pk,
                organization=organization,
            ).select_related("refugee", "service", "organization").first()
            if req is None:
                return Response({"error": "Request not found"}, status=404)

            if req.status != "pending":
                return Response({"error": "Request is not pending"}, status=400)

            req.status = "rejected"
            req.rejection_reason = serializer.validated_data["rejection_reason"]
            req.save(update_fields=["status", "rejection_reason", "updated_at"])

            Notification.objects.create(
                user=req.refugee.user,
                message=(
                    f"Your request has been rejected by {req.organization.name} "
                    f"for service {req.service.name}"
                ),
                notification_type="rejected",
            )

        return Response(
            {
                "message": "Request rejected successfully",
                "rejection_reason": req.rejection_reason,
            },
            status=200,
        )
