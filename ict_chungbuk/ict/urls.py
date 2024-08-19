from django.urls import path
from .views import predict

from . import views
from .views import register_user
from .views import login_view
from .views import find_password


urlpatterns = [
    path('predict/', views.predict, name='predict'),
    path('register/', views.register_user, name='register_user'),
    path('login/', views.login_view, name='login'),
    path('find_user_id/', views.find_user_id, name='find_user_id'), 
    path('find_password/', find_password, name='find_password'), # Correctly configured
]


