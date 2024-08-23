
from django.db import models
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import make_password, check_password

class Userlist(models.Model):
    id = models.CharField(primary_key=True, unique=True, max_length=50)
    nickname = models.CharField(null=False, max_length=30)
    password = models.CharField(max_length=100)  # Ensure this is hashed in production
    location = models.CharField(max_length=255)
    email = models.EmailField(unique=True)



class FamilyMember(models.Model):

    user = models.ForeignKey(Userlist, on_delete=models.CASCADE, related_name='family_members')
    name = models.CharField(max_length=100)
    relationship = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)

from django.db import models

class Alarm(models.Model):
    user_id = models.CharField(max_length=100)
    time = models.CharField(max_length=10)  # 시간 형식에 따라 조정
    days = models.JSONField()  # 선택된 요일을 저장

    def __str__(self):
        return f"Alarm for {self.user_id} at {self.time}"



class FavoritePill(models.Model):
    user = models.ForeignKey(Userlist, on_delete=models.CASCADE)
    pill_code = models.CharField(max_length=100)
    pill_name = models.CharField(max_length=100)

    def __str__(self):
        return self.pill_name
