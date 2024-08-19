from django.urls import path
from .views import predict
from . import views






urlpatterns = [
    path('predict/', views.predict, name='predict'),
    
    path('register/', views.register_user, name='register_user'), 
    path('user_info/<str', views.user_info, name='get_user_info'),
    path('login_view/', views.login_view, name='login_view'),
   path('user_info/<str:user_id>/', views.user_info, name='get_user_info'),
   


    path('change_password/', views.change_password, name='change_password'),
   

    path('find_password/', views.find_password, name='find_password'),
 # Correctly configured
]






