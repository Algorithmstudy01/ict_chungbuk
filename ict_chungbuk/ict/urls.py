from django.urls import path
from .views import predict
from . import views
from django.urls import path




from .views import  create_alarm, list_alarms,UpdateAlarmView

urlpatterns = [
    path('predict/', views.predict, name='predict'),
    path('user_info/<str:user_id>/', views.user_info, name='get_user_info'),
    path('login_view/', views.login_view, name='login_view'),
    path('register/', views.register_user, name='register_user'),
    path('find_user_id/', views.find_user_id, name='find_user_id'),
    path('change_password/', views.change_password, name='change_password'),
    path('find_password/', views.find_password, name='find_password'),
    path('addfamilymember/<str:user_id>/', views.add_family_member, name='add_family_member'),
    path('alarms/update/<int:pk>/', UpdateAlarmView.as_view(), name='update_alarm'),
    path('alarms/create/', create_alarm, name='create_alarm'),
    path('alarms/<str:user_id>/', list_alarms, name='list_alarms'),
    path('favorites/add/', views.add_favorite, name='add_favorite'),
    path('favorites/remove/', views.remove_favorite, name='remove_favorite'),
    path('favorites/<str:user_id>/', views.FavoritesView.as_view(), name='favorites-list'),
    ]
