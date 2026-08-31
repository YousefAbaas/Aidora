from django.contrib import admin
from .models import RefugeeProfile,User,VolunteerProfile,RefugeeFamilyMember,FamilyCategory
from .models import Notification

admin.site.register(Notification)
admin.site.register(RefugeeProfile)
admin.site.register(User)
admin.site.register(VolunteerProfile)
admin.site.register(FamilyCategory)
admin.site.register(RefugeeFamilyMember)