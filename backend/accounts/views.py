from django.shortcuts import render
from .utils import send_aidora_email
# Create your views here.
from django.contrib.auth import authenticate, get_user_model
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.response import Response
from rest_framework import status
import jwt
import secrets
from django.conf import settings
from .serializers import RefugeeProfileCompleteSerializer
from .serializers import RegisterSerializer
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import RefugeeProfile
from rest_framework import generics, permissions
from .models import VolunteerProfile
from .serializers import ( VolunteerProfileSerializer ,VolunteerApplicationSerializer,
                         VolunteerProfileViewSerializer, VolunteerApplicationReadOnlySerializer)    
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.settings import api_settings
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
from django.db import transaction
from accounts.utils import get_or_create_pin
from django.utils import timezone
from .models import VolunteerApplication
from rest_framework.generics import RetrieveAPIView
from rest_framework.viewsets import ViewSet
from .permissions import IsRole
from .throttles import VolunteerPINResendThrottle, VolunteerPINVerificationThrottle, OTPResendThrottle, OTPVerificationThrottle
from .serializers import ResendOTPSerializer
from drf_spectacular.utils import extend_schema, OpenApiResponse
User = get_user_model()
from rest_framework import serializers

from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    LoginResponseSerializer,
    ErrorResponseSerializer,
    AuthMeResponseSerializer,
    ProfileImageUploadSerializer,
    MyTokenObtainPairSerializer,
    VerifiedTokenRefreshSerializer,
)
from drf_spectacular.utils import (
    extend_schema,
    OpenApiResponse,
    OpenApiParameter,
    OpenApiTypes,
)
import logging

logger = logging.getLogger(__name__)

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(
        write_only=True,
        style={"input_type": "password"},
    )
class VerifiedTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer


class VerifiedTokenRefreshView(TokenRefreshView):
    serializer_class = VerifiedTokenRefreshSerializer


@extend_schema(
    tags=["Authentication"],
    summary="Login",
    description=(
        "Authenticate a user using email and password "
        "and return JWT access and refresh tokens."
    ),
    request=LoginSerializer,
  responses={
      200: OpenApiResponse(
          response=LoginResponseSerializer,
          description="Login successful.",
      ),
      400: OpenApiResponse(
          response=ErrorResponseSerializer,
          description=(
              "Missing credentials, unknown email, "
              "or incorrect password."
          ),
      ),
      403: OpenApiResponse(
          response=ErrorResponseSerializer,
          description="Email verification is required before login.",
      ),
  },
)
@api_view(["POST"])
@permission_classes([AllowAny])

def login_api(request):
    email = request.data.get("email")
    password = request.data.get("password")

    if not email or not password:
        return Response(
            {"error": "Email and password are required."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        candidate = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response(
            {"error": "Invalid email or password."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    user = authenticate(username=candidate.username, password=password)

    if user is None:
        return Response(
            {"error": "Invalid email or password."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if not user.is_verified:
        return Response(
            {"error": "Please verify your email before logging in."},
            status=status.HTTP_403_FORBIDDEN,
        )

    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    refresh_token = str(refresh)

    return Response(
        {
            "access": access_token,
            "refresh": refresh_token,
            "role": user.role,
        }
    )

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    
    try:
        refresh_token = request.data["refresh"]
        token = RefreshToken(refresh_token)
        token_user_id = token.get(api_settings.USER_ID_CLAIM)
        if str(token_user_id) != str(request.user.pk):
            return Response(
                {"error": "Invalid token"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        token.blacklist()

        return Response({"message": "Logged out successfully"}, status=status.HTTP_205_RESET_CONTENT)

    except Exception:
        return Response({"error": "Invalid token"}, status=status.HTTP_400_BAD_REQUEST)

from rest_framework.decorators import (
    api_view,
    permission_classes
)

from rest_framework.response import Response

from rest_framework import status

from django.utils import timezone

from .serializers import (
    RegisterSerializer,
    VerifyOTPSerializer
)

from .models import User


@extend_schema(tags=["Authentication"])
@api_view(["POST"])
@permission_classes([AllowAny])
def register_refugee(request):

    serializer = RegisterSerializer(
        data=request.data,
        context={"role": "refugee"}
    )

    if serializer.is_valid():

        user = serializer.save()

        return Response(
            {
                "message": "OTP sent successfully",
                "email": user.email
            },
            status=status.HTTP_201_CREATED
        )

    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )


@extend_schema(tags=["Authentication"])
@api_view(["POST"])
@permission_classes([AllowAny])
def register_volunteer(request):

    serializer = RegisterSerializer(
        data=request.data,
        context={"role": "volunteer"}
    )

    if serializer.is_valid():

        user = serializer.save()

        return Response(
            {
                "message": "OTP sent successfully",
                "email": user.email
            },
            status=status.HTTP_201_CREATED
        )

    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )

from threading import Thread
from django.utils import timezone
from datetime import timedelta
from django.core.mail import send_mail
from .utils import generate_otp


@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([OTPResendThrottle])
def resend_otp(request):
    serializer = ResendOTPSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    email = serializer.validated_data["email"]
    with transaction.atomic():
        user = User.objects.select_for_update().filter(email=email).first()
        # Return the same public response for unknown and already-verified accounts.
        if user is None or user.is_verified:
            return Response(
                {"message": "If this account is eligible, a new OTP will be sent."},
                status=status.HTTP_200_OK,
            )

        now = timezone.now()
        window_started = user.otp_resend_window_started_at
        if window_started is None or now - window_started >= timedelta(hours=1):
            user.otp_resend_count = 0
            user.otp_resend_window_started_at = now

        if user.otp_resend_count >= 3:
            # Keep the public response indistinguishable from other ineligible accounts.
            return Response(
                {"message": "If this account is eligible, a new OTP will be sent."},
                status=status.HTTP_200_OK,
            )

        otp = generate_otp()
        user.otp_resend_count += 1
        user.otp_code = otp
        user.otp_expires_at = now + timedelta(minutes=12)
        user.otp_failed_attempts = 0
        user.otp_locked_until = None
        user.save(
            update_fields=[
                "otp_resend_count",
                "otp_resend_window_started_at",
                "otp_code",
                "otp_expires_at",
                "otp_failed_attempts",
                "otp_locked_until",
            ]
        )

    def _send_otp_email(otp_code, user_email):
        try:
            send_aidora_email(
                subject="OTP Verification",
                message=f"Your new OTP code is: {otp_code}",
                recipient=user_email,
            )
        except Exception:
            logger.exception("Failed to resend OTP email")

    Thread(target=_send_otp_email, args=(otp, user.email)).start()
    return Response(
        {"message": "If this account is eligible, a new OTP will be sent."},
        status=status.HTTP_200_OK,
    )


@extend_schema(tags=["Authentication"])
@api_view(["POST"])
@permission_classes([AllowAny])
@throttle_classes([OTPVerificationThrottle])
def verify_otp(request):
    serializer = VerifyOTPSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    email = serializer.validated_data["email"]
    submitted_otp = serializer.validated_data["otp"]

    with transaction.atomic():
        user = User.objects.select_for_update().filter(email=email).first()
        # Unknown accounts and wrong/expired codes share the same response.
        if user is None:
            return Response(
                {"error": "Invalid or expired OTP."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if user.is_verified:
            return Response(
                {"error": "Invalid or expired OTP."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        now = timezone.now()
        if user.otp_locked_until and user.otp_locked_until > now:
            return Response(
                {"error": "Invalid or expired OTP."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp_valid = (
            bool(user.otp_code)
            and user.otp_expires_at is not None
            and user.otp_expires_at > now
            and secrets.compare_digest(str(user.otp_code), str(submitted_otp))
        )
        if not otp_valid:
            user.otp_failed_attempts += 1
            if user.otp_failed_attempts >= 5:
                user.otp_locked_until = (
                    user.otp_expires_at
                    if user.otp_expires_at and user.otp_expires_at > now
                    else now + timedelta(minutes=12)
                )
            user.save(
                update_fields=[
                    "otp_failed_attempts",
                    "otp_locked_until",
                ]
            )
            return Response(
                {"error": "Invalid or expired OTP."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user.is_verified = True
        user.otp_code = None
        user.otp_expires_at = None
        user.otp_failed_attempts = 0
        user.otp_locked_until = None
        user.save(
            update_fields=[
                "is_verified",
                "otp_code",
                "otp_expires_at",
                "otp_failed_attempts",
                "otp_locked_until",
            ]
        )

    return Response(
        {"message": "Account verified successfully"},
        status=status.HTTP_200_OK,
    )


from rest_framework.views import APIView

class CompleteRefugeeProfileView(APIView):
    permission_classes = [IsAuthenticated, IsRole]
    allowed_roles = ["refugee"]

    def patch(self, request):
        try:
            profile = RefugeeProfile.objects.get(user=request.user)
        except RefugeeProfile.DoesNotExist:
            return Response({"error": "Profile not found"}, status=404)

        serializer = RefugeeProfileCompleteSerializer(
            profile,
            data=request.data,
            partial=True
        )

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Profile completed"})

        return Response(serializer.errors, status=400)
class VolunteerProfileViewSet(ViewSet):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["volunteer"]
    def get_profile(self, request):
        profile, _ = VolunteerProfile.objects.get_or_create(
            user=request.user
        )
        return profile


    # ✅ PATCH (الواجهة الأولى)
    def update_profile(self, request):
        profile = self.get_profile(request)

        serializer = VolunteerProfileSerializer(
            profile,
            data=request.data,
            partial=True
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data)

    # ✅ PATCH skills
    def update_skills(self, request):
        profile = self.get_profile(request)

        fields = ['education_level', 'languages', 'previous_experience', 'skills']
        data = {f: request.data.get(f) for f in fields if f in request.data}

        serializer = VolunteerProfileSerializer(profile, data=data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data)

    # ✅ PATCH availability
    def update_availability(self, request):
        profile = self.get_profile(request)
        data = request.data.copy() 
        DAY_MAP = {
        'S': 'sunday',
        'M': 'monday',
        'TU': 'tuesday',
        'W': 'wednesday',
        'TH': 'thursday',
        'F': 'friday',
        'SA': 'saturday',
        }
        if 'available_days' in data:
          data['available_days'] = [
          DAY_MAP.get(day.upper(), day).strip().lower()
          for day in data.get('available_days', [])
              ]      
        if 'availability_shift' in data:
            data['availability_shift'] = data.get('availability_shift').lower()        
        fields = ['availability_shift', 'available_days', 'start_date', 'expected_duration']
        data = {f: data.get(f) for f in fields if f in data}

        serializer = VolunteerProfileSerializer(profile, data=data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


@extend_schema(
    tags=["Volunteers"],
    summary="Submit volunteer application",
    description=(
        "Submit a volunteer application for a specific organization. "
        "The authenticated volunteer can select one or more services."
    ),
    parameters=[
        OpenApiParameter(
            name="id",
            type=OpenApiTypes.INT,
            location=OpenApiParameter.PATH,
            description="Organization ID.",
        ),
    ],
    request=VolunteerApplicationSerializer,
    responses={
        201: OpenApiResponse(
            description="Volunteer application submitted successfully.",
        ),
        400: OpenApiResponse(
            description="Validation error.",
        ),
        401: OpenApiResponse(
            description="Authentication credentials were not provided or are invalid.",
        ),
    },
)
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def submit_volunteer_application(request, id):
    if request.user.role != "volunteer":
        return Response(
            {"error": "Only volunteer accounts can submit volunteer applications."},
            status=status.HTTP_403_FORBIDDEN,
        )

    serializer = VolunteerApplicationSerializer(
        data=request.data,
        context={
            "request": request,
            "organization_id": id
        }
    )

    if serializer.is_valid():
        serializer.save()
        return Response(
            {"detail": "Your request submitted successfully."},
            status=status.HTTP_201_CREATED
        )

    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )

@extend_schema(
    tags=["Authentication"],
    summary="Get current user",
    description=(
        "Return basic information about the authenticated user."
    ),
    responses={
        200: OpenApiResponse(
            response=AuthMeResponseSerializer,
            description="Authenticated user information.",
        ),
        401: OpenApiResponse(
            description="Authentication credentials were not provided or are invalid.",
        ),
    },
)
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def auth_me(request):
    user = request.user
    profile_completed = False

    response_data = {
        "role": user.role,
        "profile_completed": False,
    }

    if user.role == "refugee":
        profile = getattr(user, "refugee_profile", None)
        if profile:
            response_data["profile_completed"] = profile.profile_completed

        # ❌ ما منضيف application_status

    elif user.role == "volunteer":
        profile = getattr(user, "volunteer_profile", None)
        if profile:
            response_data["profile_completed"] = profile.profile_completed

        application = VolunteerApplication.objects.filter(user=user).order_by('-id').first()
        response_data["application_status"] = application.status if application else None

    return Response(response_data)






@api_view(["POST"])
@permission_classes([IsAuthenticated])
@throttle_classes([VolunteerPINResendThrottle])
def resend_pin(request):
    user = request.user
    if user.role != "volunteer":
        return Response(
            {"detail": "Only volunteer accounts can request a verification PIN."},
            status=status.HTTP_403_FORBIDDEN,
        )

    # Fetch from the database instead of relying on a potentially cached
    # reverse OneToOne relation attached to request.user.
    profile = VolunteerProfile.objects.filter(user=user).first()
    if profile is None:
        return Response(
            {"detail": "Volunteer profile not found."},
            status=status.HTTP_404_NOT_FOUND,
        )

    from accounts.models import VolunteerApplication
    has_approved_application = VolunteerApplication.objects.filter(
        user=user,
        status="approved",
        is_verified=False,
    ).exists()
    if not has_approved_application:
        return Response(
            {"detail": "An approved volunteer application is required."},
            status=status.HTTP_403_FORBIDDEN,
        )

    with transaction.atomic():
        profile = VolunteerProfile.objects.select_for_update().get(pk=profile.pk)
        now = timezone.now()
        window_started = profile.pin_resend_window_started_at
        if window_started is None or now - window_started >= timedelta(hours=1):
            profile.pin_resend_count = 0
            profile.pin_resend_window_started_at = now

        if profile.pin_resend_count >= 3:
            return Response(
                {"detail": "Too many PIN resend requests. Please try again later."},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        profile.pin_resend_count += 1
        update_fields = [
            "pin_resend_count",
            "pin_resend_window_started_at",
            "updated_at",
        ]

        if profile.pin_locked_until and profile.pin_locked_until > now:
            # A resend after lockout rotates the PIN instead of recycling it.
            profile.verification_pin = None
            profile.pin_expires_at = None
            profile.pin_failed_attempts = 0
            profile.pin_locked_until = None
            update_fields.extend([
                "verification_pin",
                "pin_expires_at",
                "pin_failed_attempts",
                "pin_locked_until",
            ])

        profile.save(update_fields=update_fields)
        pin = get_or_create_pin(profile)

    send_aidora_email(
        subject="Aidora Verification PIN",
        message=f"Your verification PIN is: {pin}",
        recipient=user.email,
    )
    return Response(
        {"detail": "Verification PIN sent successfully."},
        status=status.HTTP_200_OK,
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
@throttle_classes([VolunteerPINVerificationThrottle])
def verify_pin(request):
    user = request.user
    if user.role != "volunteer":
        return Response(
            {"detail": "Only volunteer accounts can verify a PIN."},
            status=status.HTTP_403_FORBIDDEN,
        )

    input_pin = request.data.get("pin")
    if input_pin is None:
        return Response(
            {"detail": "PIN is required."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    profile = getattr(user, "volunteer_profile", None)
    if profile is None:
        return Response(
            {"detail": "Volunteer profile not found."},
            status=status.HTTP_404_NOT_FOUND,
        )

    from accounts.models import VolunteerApplication

    with transaction.atomic():
        # Lock in the same order as organization approval: application first,
        # then volunteer profile. This avoids lock-order inversions.
        application = VolunteerApplication.objects.select_for_update().filter(
            user=user,
            status="approved",
            is_verified=False,
        ).select_related("organization").order_by("-id").first()
        if application is None:
            return Response(
                {"detail": "An approved volunteer application is required."},
                status=status.HTTP_403_FORBIDDEN,
            )

        profile = VolunteerProfile.objects.select_for_update().get(pk=profile.pk)
        now = timezone.now()

        if profile.pin_locked_until and profile.pin_locked_until > now:
            return Response(
                {"detail": "PIN verification is temporarily locked. Request a new PIN."},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        pin_valid = (
            bool(profile.verification_pin)
            and profile.pin_expires_at is not None
            and profile.pin_expires_at > now
            and secrets.compare_digest(
                str(profile.verification_pin),
                str(input_pin),
            )
        )
        if not pin_valid:
            profile.pin_failed_attempts += 1
            if profile.pin_failed_attempts >= 5:
                profile.pin_locked_until = (
                    profile.pin_expires_at
                    if profile.pin_expires_at and profile.pin_expires_at > now
                    else now + timezone.timedelta(minutes=10)
                )
            profile.save(
                update_fields=[
                    "pin_failed_attempts",
                    "pin_locked_until",
                    "updated_at",
                ]
            )
            if profile.pin_failed_attempts >= 5:
                return Response(
                    {"detail": "PIN verification is locked. Request a new PIN."},
                    status=status.HTTP_429_TOO_MANY_REQUESTS,
                )
            return Response(
                {"detail": "Invalid or expired PIN."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        application.is_verified = True
        application.save(update_fields=["is_verified"])

        profile.profile_completed = True
        profile.organization = application.organization
        profile.verification_pin = None
        profile.pin_expires_at = None
        profile.pin_failed_attempts = 0
        profile.pin_locked_until = None
        profile.save(
            update_fields=[
                "profile_completed",
                "organization",
                "verification_pin",
                "pin_expires_at",
                "pin_failed_attempts",
                "pin_locked_until",
                "updated_at",
            ]
        )

    return Response(
        {"detail": "PIN verified successfully and organisation assigned."},
        status=status.HTTP_200_OK,
    )

from rest_framework.exceptions import NotFound
class VolunteerApplicationDetailView(RetrieveAPIView):
    serializer_class = VolunteerApplicationReadOnlySerializer
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["volunteer"]

    def get_object(self):
        try:
            return VolunteerApplication.objects.get(
                user=self.request.user,
                organization_id=self.kwargs['id']
            )
        except VolunteerApplication.DoesNotExist:
            raise NotFound("No application found for this organization.")


from .serializers import VolunteerQRSerializer
import uuid
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@permission_classes([IsRole])
def volunteer_qr(request, volunteer_id):

    try:
        profile = VolunteerProfile.objects.get(id=volunteer_id)
    except VolunteerProfile.DoesNotExist:
        return Response({"error": "Volunteer not found"}, status=404)

    # Only the profile owner (or staff) may retrieve the QR.
    if not request.user.is_staff and profile.user.id != request.user.id:
        return Response({"error": "You are not allowed to view this QR."}, status=403)

    if not profile.profile_completed:
        return Response(
            {"error": "Volunteer PIN verification is required before QR access."},
            status=403,
        )

    # توليد QR نصي إذا مش موجود
    if not profile.qr_code:
        # استخدم full_name أو username كاحتياط
        name = profile.full_name 
        profile.qr_code = f"@{name.replace(' ', '')[:50]}|{uuid.uuid4().hex}"
        profile.save()

    serializer = VolunteerQRSerializer(profile)
    return Response(serializer.data)
volunteer_qr.allowed_roles = ["volunteer"]


from django.db.models import Count
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@permission_classes([IsRole])
def volunteer_profile_view(request):
    profile = VolunteerProfile.objects.filter(
        user=request.user
    ).annotate(
        tasks_count=Count('tasks')  # ✅ هون الصح
    ).first()

    if not profile:
        return Response({"error": "Profile not found"}, status=404)

    serializer = VolunteerProfileViewSerializer(profile)
    return Response(serializer.data)
volunteer_profile_view.allowed_roles = ["volunteer"]


from rest_framework.views import APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

class UploadProfileImageAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        user = request.user
        serializer = ProfileImageUploadSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=400)

        image = serializer.validated_data["profile_image"]

        # Resolve only the authenticated user's own profile.
        try:
            if user.role == "volunteer":
                profile = user.volunteer_profile
            elif user.role == "refugee":
                profile = user.refugee_profile
            else:
                return Response({"error": "Invalid role"}, status=400)
        except (VolunteerProfile.DoesNotExist, RefugeeProfile.DoesNotExist):
            return Response({"error": "Profile not found"}, status=404)

        # Keep the previous image until the replacement has been saved.
        old_image = profile.profile_image
        profile.profile_image = image
        profile.save(update_fields=["profile_image", "updated_at"])

        if old_image:
            old_image.delete(save=False)

        return Response({
            "message": "Profile image updated successfully",
            "profile_image": request.build_absolute_uri(profile.profile_image.url)
        })

    def delete(self, request):
        user = request.user

        # 🔹 تحديد البروفايل حسب الدور + حماية
        try:
            if user.role == "volunteer":
                profile = user.volunteer_profile

            elif user.role == "refugee":
                profile = user.refugee_profile

            else:
                return Response({"error": "Invalid role"}, status=400)

        except:
            return Response({"error": "Profile not found"}, status=404)

        # 🔥 حذف الصورة إذا موجودة
        if profile.profile_image:
            profile.profile_image.delete(save=False)
            profile.save()
            return Response({"message": "Profile image deleted successfully"}, status=200)
        
        return Response({"error": "No image to delete"}, status=400)
    
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.core.mail import send_mail
from .serializers import ForgotPasswordSerializer
@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):

    serializer = ForgotPasswordSerializer(
        data=request.data
    )

    if serializer.is_valid():

        email = serializer.validated_data['email']

        try:
            user = User.objects.get(email=email)

        except User.DoesNotExist:
            # Same response as success: do not reveal which emails exist.
            return Response(
                {"message": "Reset password link sent successfully"},
                status=status.HTTP_200_OK
            )

        # ✅ توليد uid
        uid = urlsafe_base64_encode(
            force_bytes(user.id)
        )

        # ✅ توليد token
        token = PasswordResetTokenGenerator().make_token(user)

        # ✅ رابط إعادة تعيين كلمة المرور
        reset_link = (
            f"aidora://reset-password/"
            f"{uid}/{token}/"
        )

        # ✅ إرسال الإيميل بالخلفية
        def _send_email():

            try:

                send_aidora_email(
                    subject="Reset Your Password",
                    message=(
                        "Hello,\n\n"
                        "Click the link below to reset your password:\n\n"
                        f"{reset_link}\n\n"
                        "If you did not request this, ignore this email."
                    ),
                    recipient=email,
                )

            except Exception:
                logger.exception("Failed to send password reset email")

        Thread(target=_send_email).start()

        return Response(
            {
                "message": "Reset password link sent successfully"
            },
            status=status.HTTP_200_OK
        )

    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )

from django.utils.http import urlsafe_base64_decode

from django.contrib.auth.tokens import (
    PasswordResetTokenGenerator
)

from .serializers import ResetPasswordSerializer


@api_view(['Patch'])
@permission_classes([AllowAny])
def reset_password(request):

    serializer = ResetPasswordSerializer(
        data=request.data
    )

    if serializer.is_valid():

        uid = serializer.validated_data['uid']

        token = serializer.validated_data['token']

        new_password = serializer.validated_data[
            'new_password'
        ]

        try:

            user_id = urlsafe_base64_decode(
                uid
            ).decode()

            user = User.objects.get(id=user_id)

        except Exception:

            return Response(
                {"error": "Invalid uid"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ✅ تحقق من صلاحية التوكن
        if not PasswordResetTokenGenerator().check_token(
            user,
            token
        ):

            return Response(
                {"error": "Invalid or expired token"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Change the password and revoke all outstanding refresh tokens atomically.
        with transaction.atomic():
            user.set_password(new_password)
            user.save(update_fields=["password"])

            for outstanding_token in OutstandingToken.objects.filter(user=user):
                BlacklistedToken.objects.get_or_create(token=outstanding_token)

        return Response(
            {
                "message": "Password reset successfully"
            },
            status=status.HTTP_200_OK
        )

    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )
#شهد
from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import RefugeeProfile
from .serializers import RefugeeProfileSerializer
from .models import Notification
from .serializers import NotificationSerializer

class RefugeeProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]
    def get(self, request):
        # مؤقت للاختبار
        #refugee = RefugeeProfile.objects.first()
        
        refugee = request.user.refugee_profile
        serializer = RefugeeProfileSerializer(refugee, context={"request": request})
        return Response(serializer.data)

from django.contrib.auth import get_user_model
#User = get_user_model()

class NotificationListAPIView(APIView):
    permission_classes = [IsAuthenticated]
    permission_classes = [IsRole]
    allowed_roles = ["refugee"]

    def get(self, request):

        notifications = Notification.objects.filter(
            user=request.user
        ).order_by('-created_at')

        # 🔥 خلي كل الإشعارات مقروءة
        notifications.update(is_read=True)

        serializer = NotificationSerializer(
            notifications,
            many=True
        )

        return Response({
            "notifications": serializer.data
        })