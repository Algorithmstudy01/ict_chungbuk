from django.contrib import admin
from .models import Userlist
from .models import FamilyMember
from .models import Alarm

# Register your models here.
admin.site.register(Userlist)
admin.site.register(FamilyMember)
admin.site.register(Alarm)
