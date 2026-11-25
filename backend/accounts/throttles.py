from rest_framework.throttling import AnonRateThrottle, UserRateThrottle


class VolunteerPINVerificationThrottle(UserRateThrottle):
    scope = "volunteer_pin_verify"


class VolunteerPINResendThrottle(UserRateThrottle):
    scope = "volunteer_pin_resend"


class OTPVerificationThrottle(AnonRateThrottle):
    scope = "otp_verify"


class OTPResendThrottle(AnonRateThrottle):
    scope = "otp_resend"
