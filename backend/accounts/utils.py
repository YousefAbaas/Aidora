import logging
import random
from random import randint

import requests
from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone

logger = logging.getLogger(__name__)

def send_aidora_email(*, subject, message, recipient, sender_name="Aidora"):
    """
    Send a transactional email through Brevo's HTTPS API.

    Falls back to Django's SMTP backend when BREVO_API_KEY is not configured,
    which keeps local development working.
    """
    api_key = getattr(settings, "BREVO_API_KEY", None)
    sender_email = getattr(
        settings,
        "BREVO_FROM_EMAIL",
        getattr(settings, "EMAIL_HOST_USER", None),
    )

    if not api_key:
        send_mail(
            subject=subject,
            message=message,
            from_email=f"Aidora <{sender_email}>",
            recipient_list=[recipient],
            fail_silently=False,
        )
        return

    if not sender_email:
        raise RuntimeError("BREVO_FROM_EMAIL is not configured")
    logger.info(
    "Brevo config: key_present=%s key_length=%s sender=%s",
    bool(api_key),
    len(api_key) if api_key else 0,
    sender_email,
    )
    response = requests.post(
        "https://api.brevo.com/v3/smtp/email",
        headers={
            "accept": "application/json",
            "api-key": api_key,
            "content-type": "application/json",
        },
        json={
            "sender": {
                "name": sender_name,
                "email": sender_email,
            },
            "to": [
                {
                    "email": recipient,
                }
            ],
            "subject": subject,
            "textContent": message,
        },
        timeout=15,
    )

    if not response.ok:
        logger.error(
            "Brevo email failed: status=%s body=%s",
            response.status_code,
            response.text[:500],
        )
        response.raise_for_status()

    logger.info(
        "Brevo email sent successfully: recipient=%s subject=%s",
        recipient,
        subject,
    )

def generate_otp():
    return str(random.randint(100000, 999999))


def get_or_create_pin(volunteer_profile):
    now = timezone.now()
    if volunteer_profile.verification_pin and volunteer_profile.pin_expires_at > now:
        return volunteer_profile.verification_pin
    else:
        pin = f"{randint(1000, 9999)}"
        volunteer_profile.verification_pin = pin
        volunteer_profile.pin_expires_at = now + timezone.timedelta(minutes=10)
        volunteer_profile.save()
        return pin

def send_verification_pin(volunteer_profile):
    """
    دالة مشتركة لإرسال PIN، تستخدم من أي signal
    """
    pin = get_or_create_pin(volunteer_profile)

    send_aidora_email(
        subject="Approval Verification PIN",
        message=f"Your Approval PIN is: {pin}",
        recipient=volunteer_profile.user.email,
    )