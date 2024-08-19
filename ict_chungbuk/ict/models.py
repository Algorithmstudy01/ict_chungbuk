from django.db import models
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import make_password, check_password

class Userlist(models.Model):
    id = models.CharField(primary_key=True, unique=True, max_length=50)
    nickname = models.CharField(null=False, max_length=30)
    password = models.CharField(max_length=100)  # Ensure this is hashed in production
    location = models.CharField(max_length=255)
    email = models.EmailField(unique=True)


