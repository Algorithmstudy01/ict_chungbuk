# ict/serializers.py
from rest_framework import serializers
from .models import Userlist

# class UserSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Userlist
#         fields = ['username', 'nickname', 'password', 'location', 'email']
#         extra_kwargs = {
#             'password': {'write_only': True},
#         }

#     def validate_email(self, value):
#         if Userlist.objects.filter(email=value).exists():
#             raise serializers.ValidationError("Email is already in use.")
#         return value

#     def create(self, validated_data):
#         user = Userlist(
#             nickname=validated_data['nickname'],
#             username=validated_data['username'],
#             location=validated_data['location'],
#             email=validated_data['email']
#         )
#         user.set_password(validated_data['password'])
#         user.save()
#         return user
    
# #     # serializers.py
# # from rest_framework import serializers
# # from .models import Userlist

# # class UserlistSerializer(serializers.ModelSerializer):
# #     class Meta:
# #         model = Userlist
# #         fields = ['username', 'nickname', 'password', 'location', 'email']

# #     def create(self, validated_data):
# #         # In production, make sure to hash the password before saving
# #         return Userlist.objects.create(**validated_data)

from rest_framework import serializers
from .models import Userlist

class UserlistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userlist
        fields = ['username', 'nickname', 'password', 'location', 'email']

    def create(self, validated_data):
        # Hash the password before saving it (important for production)
        return Userlist.objects.create(**validated_data)
