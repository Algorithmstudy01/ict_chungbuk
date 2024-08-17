from django.urls import path
from .views import predict
from django.urls import path
from . import views
# urls.py
from django.urls import path
from .views import register_user




urlpatterns = [
    path('predict/', predict, name='predict'),
   
    path('register/', register_user, name='register_user'),


]


