from rest_framework.throttling import UserRateThrottle


class VolunteerPINVerificationThrottle(UserRateThrottle):
    scope = "volunteer_pin_verify"


class VolunteerPINResendThrottle(UserRateThrottle):
    scope = "volunteer_pin_resend"
