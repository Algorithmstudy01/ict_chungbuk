from django.urls import path
from .views import predict

from . import views
from .views import register_user
from .views import login_view




urlpatterns = [
    path('predict/', predict, name='predict'),
   
    path('register/', register_user, name='register_user'),
    path('login/', login_view, name='login'),


]


