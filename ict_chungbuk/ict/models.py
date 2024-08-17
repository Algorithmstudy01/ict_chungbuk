# ict/models.py
from django.db import models


class Userlist(models.Model):
    username = models.CharField(max_length=100, unique=True)
    nickname = models.CharField(null=False, max_length=30)
    password = models.CharField(max_length=100)  # Ensure this is hashed in production
    location = models.CharField(max_length=255)
    email = models.EmailField(unique=True)

