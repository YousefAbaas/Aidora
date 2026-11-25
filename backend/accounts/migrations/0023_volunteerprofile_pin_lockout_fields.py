from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0022_user_otp_code_user_otp_expires_at"),
    ]

    operations = [
        migrations.AddField(
            model_name="volunteerprofile",
            name="pin_failed_attempts",
            field=models.PositiveSmallIntegerField(default=0),
        ),
        migrations.AddField(
            model_name="volunteerprofile",
            name="pin_locked_until",
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
