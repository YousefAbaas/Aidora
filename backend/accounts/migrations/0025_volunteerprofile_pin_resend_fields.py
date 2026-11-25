from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0024_user_otp_protection_fields"),
    ]

    operations = [
        migrations.AddField(
            model_name="volunteerprofile",
            name="pin_resend_count",
            field=models.PositiveSmallIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="volunteerprofile",
            name="pin_resend_window_started_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
