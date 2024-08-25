from django.contrib import admin
from .models import Userlist
from .models import FamilyMember
from .models import Alarm
from .models import FavoritePill
from .models import Record

from .models import Sear
# Register your models here.
admin.site.register(Userlist)
admin.site.register(FamilyMember)
admin.site.register(Alarm)
admin.site.register(FavoritePill)
admin.site.register(Sear)
admin.site.register(Record)