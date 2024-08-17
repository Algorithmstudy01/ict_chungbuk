from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('ict.urls')),  # 'ict'는 앱 이름입니다.
]
