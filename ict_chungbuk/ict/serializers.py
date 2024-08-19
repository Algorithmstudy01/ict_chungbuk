from rest_framework import serializers
from .models import Userlist


class UserlistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userlist
        fields = ('id', 'nickname','password','location', 'email')

# serializers.py


