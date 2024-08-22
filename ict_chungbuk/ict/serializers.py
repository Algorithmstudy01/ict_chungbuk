from rest_framework import serializers
from .models import Userlist


class UserlistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userlist
        fields = ('id', 'nickname','password','location', 'email')

# # serializers.py

from rest_framework import serializers
from .models import FamilyMember

class FamilyMemberSerializer(serializers.ModelSerializer):
    class Meta:
        model = FamilyMember
        fields = ['name', 'relationship', 'phone_number', 'address']


from rest_framework import serializers
from .models import Alarm

class AlarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alarm
        fields = ['id', 'user_id', 'time', 'days']
