from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0023_volunteerprofile_pin_lockout_fields"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="otp_failed_attempts",
            field=models.PositiveSmallIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="user",
            name="otp_locked_until",
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="user",
            name="otp_resend_count",
            field=models.PositiveSmallIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="user",
            name="otp_resend_window_started_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
