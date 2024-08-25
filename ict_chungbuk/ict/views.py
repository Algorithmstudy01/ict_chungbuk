import json
import numpy as np
import tensorflow as tf
from PIL import Image
from django.http import JsonResponse
from .models import Userlist, Record
from .serializers import UserlistSerializer
from django.contrib.auth import authenticate
from django.urls import path
from django.http import HttpResponse
from django.shortcuts import render
import requests
from django.http import HttpResponseNotAllowed, JsonResponse
from django.contrib.auth import authenticate, login
from django.middleware.csrf import get_token
from django.views.decorators.csrf import csrf_exempt
import json
from django.db.models import F
from django.contrib.auth.hashers import make_password



import pytesseract
from django.shortcuts import render, redirect
from django.contrib import messages
from django import forms
from .models import Userlist
from django.urls import path
# ict/views.py


import torch
import torchvision.transforms as transforms
from PIL import Image
from rest_framework.decorators import api_view
import pytesseract

import os
import json
import torch
import torchvision.transforms as transforms
from PIL import Image
import pytesseract
from django.shortcuts import render
from django.http import JsonResponse
from django.conf import settings
from .models import Userlist
import torch
import torchvision
from django.conf import settings
from PIL import Image
import torchvision.transforms as transforms
import json
import os

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import api_view
import torch
import torchvision.transforms as T
from PIL import Image
import os
import json
import csv

import os
import csv
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view
from PIL import Image
import torchvision.transforms as T
import torch
import torchvision

def get_model(num_classes):
    from torchvision.models.detection import FasterRCNN
    from torchvision.models.mobilenetv3 import mobilenet_v3_large
    from torchvision.models.detection.anchor_utils import AnchorGenerator

    backbone = mobilenet_v3_large(pretrained=True).features
    backbone.out_channels = 960

    anchor_generator = AnchorGenerator(
        sizes=((32, 64, 128, 256, 512),),
        aspect_ratios=((0.5, 1.0, 2.0),) * 5
    )

    roi_pooler = torchvision.ops.MultiScaleRoIAlign(
        featmap_names=['0'], output_size=7, sampling_ratio=2
    )

    model = FasterRCNN(
        backbone,
        num_classes=num_classes,
        rpn_anchor_generator=anchor_generator,
        box_roi_pool=roi_pooler
    )
    
    return model

def find_pill_info_from_csv(predicted_category_id, csv_path):
    with open(csv_path, mode='r', encoding='utf-8-sig') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if int(row['category_id']) == predicted_category_id:
                return {
                    "제품명": row["제품명"],
                    "품목기준코드": row["품목기준코드"],
                    "제조/수입사": row["제조/수입사"],
                    "이 약의 효능은 무엇입니까?": row["이 약의 효능은 무엇입니까?"],
                    "이 약은 어떻게 사용합니까?": row["이 약은 어떻게 사용합니까?"],
                    "이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?": row["이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?"],
                    "이 약의 사용상 주의사항은 무엇입니까?": row["이 약의 사용상 주의사항은 무엇입니까?"],
                    "이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?": row["이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?"],
                    "이 약은 어떤 이상반응이 나타날 수 있습니까?": row["이 약은 어떤 이상반응이 나타날 수 있습니까?"],
                    "이 약은 어떻게 보관해야 합니까?": row["이 약은 어떻게 보관해야 합니까?"]
                }
    return {}

@api_view(['POST'])
@csrf_exempt
def predict(request):
    if 'image' not in request.FILES:
        return JsonResponse({'error': 'No image file provided'}, status=400)

    image_file = request.FILES['image']
    image_path = '/tmp/temp_image.jpg'
    
    try:
        with open(image_path, 'wb') as f:
            for chunk in image_file.chunks():
                f.write(chunk)
        
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        num_classes = 54
        model = get_model(num_classes=num_classes)
        model.load_state_dict(torch.load('/Users/seon/Desktop/ict model/pill_detection_53_more.pth', map_location=device))
        model.to(device)
        
        image = Image.open(image_path).convert("RGB")
        transform = T.Compose([T.ToTensor()])
        image_tensor = transform(image).unsqueeze(0).to(device)
    except Exception as e:
        return JsonResponse({'error': f'Error loading model or processing image: {str(e)}'}, status=500)

    try:
        model.eval()
        with torch.no_grad():
            outputs = model(image_tensor)
        
        threshold = 0.5
        pred_scores = outputs[0]['scores'].cpu().numpy()
        pred_labels = outputs[0]['labels'].cpu().numpy()
        pred_labels = pred_labels[pred_scores >= threshold]
        pred_scores = pred_scores[pred_scores >= threshold]

        if len(pred_labels) == 0:
            return JsonResponse({'message': 'No predictions made'}, status=200)

        max_score_idx = pred_scores.argmax()
        predicted_category_id = pred_labels[max_score_idx]

        csv_path = '/Users/seon/Desktop/ict model/info.csv'

        pill_info_csv = find_pill_info_from_csv(predicted_category_id, csv_path)

       
        response_data = {
                'prediction_score': float(pred_scores[max_score_idx]),
                'product_name': pill_info_csv.get('제품명', 'Unknown'),
                'manufacturer': pill_info_csv.get('제조/수입사', 'Unknown'),
                'pill_code': pill_info_csv.get('품목기준코드', 'Unknown'),
                'efficacy': pill_info_csv.get('이 약의 효능은 무엇입니까?', 'No information'),
                'usage': pill_info_csv.get('이 약은 어떻게 사용합니까?', 'No information'),
                'precautions_before_use': pill_info_csv.get('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?', 'No information'),
                'usage_precautions': pill_info_csv.get('이 약의 사용상 주의사항은 무엇입니까?', 'No information'),
                'drug_food_interactions': pill_info_csv.get('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?', 'No information'),
                'side_effects': pill_info_csv.get('이 약은 어떤 이상반응이 나타날 수 있습니까?', 'No information'),
                'storage_instructions': pill_info_csv.get('이 약은 어떻게 보관해야 합니까?', 'No information'),
            }

           
    
    except Exception as e:
        return JsonResponse({'error': f'Error during prediction: {str(e)}'}, status=500)
    finally:
        if os.path.exists(image_path):
            os.remove(image_path)

    return JsonResponse(response_data, status=200)

from django.views.decorators.csrf import csrf_exempt

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Userlist
from .serializers import UserlistSerializer
# 회원가입
@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        # Extract data from request
        data = request.data
        nickname = data.get('nickname', '')
        id = data.get('id', '')
        password = data.get('password', '')
        location = data.get('location', '')
        email = data.get('email', '')

        # Validate input data
        if not all([nickname, id, password, location, email]):
            return Response({'message': '모든 필드를 입력해야 합니다.'}, status=status.HTTP_400_BAD_REQUEST)

        # Check for duplicates
        if Userlist.objects.filter(nickname=nickname).exists():
            return Response({'message': '이미 사용중인 닉네임입니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
        if Userlist.objects.filter(id=id).exists():
            return Response({'message': '이미 사용중인 아이디입니다.'}, status=status.HTTP_400_BAD_REQUEST)

        if Userlist.objects.filter(email=email).exists():
            return Response({'message': '가입된 이메일이 존재합니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Serialize and save data
        serializer = UserlistSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 로그인 로직
import json
from django.http import JsonResponse
from .models import Userlist
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate
from .models import Userlist

import json
from django.http import JsonResponse
from .models import Userlist

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            id = data.get('id')
            password = data.get('password')

            print(f"Received login request: ID={id}, Password={password}")

            # 사용자 모델에서 해당 ID로 사용자 찾기
            try:
                user = Userlist.objects.get(id=id)
            except Userlist.DoesNotExist:
                user = None

            # 사용자가 존재하고, 비밀번호가 일치하는지 확인
            if user is not None:
                if user.password == password:
                    # 인증 성공
                    return JsonResponse({'message': '로그인 성공'}, status=200)
                else:
                    # 인증 실패
                    return JsonResponse({'error': 'ID나 비밀번호가 일치하지 않습니다.'}, status=400)
            else:
                # 사용자가 존재하지 않음
                return JsonResponse({'error': 'ID나 비밀번호가 일치하지 않습니다.'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'error': '잘못된 JSON 형식입니다.'}, status=400)
        except Exception as e:
            print(f"Unexpected error: {e}")
            return JsonResponse({'error': '서버 오류가 발생했습니다.'}, status=500)
    else:
        return JsonResponse({'error': '잘못된 요청입니다.'}, status=400)

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist
from .serializers import UserlistSerializer

@api_view(['GET'])
def user_info(request, user_id):
    try:
        user = Userlist.objects.get(id=user_id)
        serializer = UserlistSerializer(user)
        return Response(serializer.data, status=200)
    except Userlist.DoesNotExist:
        return Response({"message": "사용자를 찾을 수 없음"}, status=404)

@api_view(['POST'])
def find_user_id(request):
    if request.method == 'POST':
        email = request.data.get('email', None)
        if email:
            try:
                user = Userlist.objects.get(email=email)
                serializer = UserlistSerializer(user)
                return JsonResponse({"id": serializer.data['id']}, status=200)
            except Userlist.DoesNotExist:
                return JsonResponse({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return JsonResponse({"message": "이메일을 입력해주세요."}, status=400)

# 비밀번호 찾기from rest_framework.decorators import api_view

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist  # Adjust according to your user model
from .serializers import UserlistSerializer  # Adjust according to your serializer

@api_view(['POST'])
def find_password(request):
    id = request.data.get('id', None)
    email = request.data.get('email', None)

    if not id or not email:
        return Response({"message": "아이디와 이메일을 입력해주세요."}, status=400)

    try:
        user = Userlist.objects.get(id=id, email=email)
        return Response({"password": user.password}, status=200)
    except Userlist.DoesNotExist:
        return Response({"message": "일치하는 사용자가 없습니다."}, status=400)




# 업데이트 비밀번호
@api_view(['POST'])
def change_password(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('id')
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')

        if user_id and current_password and new_password:
            try:
                # 사용자 확인
                user = Userlist.objects.get(id=user_id)
                user.password = new_password
                user.save()
                return Response({"message": "비밀번호가 성공적으로 업데이트되었습니다."}, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "ID와 새로운 비밀번호를 모두 제공해주세요."}, status=400)

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .serializers import FamilyMemberSerializer
from .models import Userlist, FamilyMember

@api_view(['POST'])
def add_family_member(request, user_id):
    try:
        user = Userlist.objects.get(id=user_id)
    except Userlist.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = FamilyMemberSerializer(data=request.data)
    if serializer.is_valid():
        family_member = serializer.save(user=user)
        return Response({'message': 'Family member added successfully'}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Alarm
from .serializers import AlarmSerializer
from django.http import JsonResponse

# 알람 생성
@api_view(['POST'])
def create_alarm(request):
    serializer = AlarmSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 특정 사용자의 알람 리스트 조회
@api_view(['GET'])
def list_alarms(request, user_id):
    alarms = Alarm.objects.filter(user_id=user_id)
    serializer = AlarmSerializer(alarms, many=True)
    return Response(serializer.data)

# 알람 수정
class UpdateAlarmView(APIView):
    def put(self, request, pk):
        try:
            alarm = Alarm.objects.get(pk=pk)
        except Alarm.DoesNotExist:
            return Response({'error': 'Alarm not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = AlarmSerializer(alarm, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 알람 삭제
class DeleteAlarmView(APIView):
    def delete(self, request, pk):
        try:
            alarm = Alarm.objects.get(pk=pk)
        except Alarm.DoesNotExist:
            return Response({'error': 'Alarm not found'}, status=status.HTTP_404_NOT_FOUND)

        alarm.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import FavoritePill
from .serializers import FavoritePillSerializer


@api_view(['POST'])
def add_favorite(request):
    user_id = request.data.get('user_id')
    pill_code = request.data.get('pill_code')
    pill_name = request.data.get('pill_name')

    if not user_id or not pill_code or not pill_name:
        return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = Userlist.objects.get(pk=user_id)
        favorite, created = FavoritePill.objects.get_or_create(user=user, pill_code=pill_code)
        if not created:
            return Response({'error': 'Favorite already exists'}, status=status.HTTP_400_BAD_REQUEST)
        favorite.pill_name = pill_name
        favorite.save()
        return Response({'message': 'Favorite added successfully'}, status=status.HTTP_201_CREATED)
    except Userlist.DoesNotExist:
        return Response({'error': 'User does not exist'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
def remove_favorite(request):
    user_id = request.data.get('user_id')
    pill_code = request.data.get('pill_code')

    if not user_id or not pill_code:
        return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = Userlist.objects.get(pk=user_id)
        favorite = FavoritePill.objects.filter(user=user, pill_code=pill_code)
        if favorite.exists():
            favorite.delete()
            return Response({'message': 'Favorite removed successfully'}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Favorite not found'}, status=status.HTTP_404_NOT_FOUND)
    except Userlist.DoesNotExist:
        return Response({'error': 'User does not exist'}, status=status.HTTP_404_NOT_FOUND)

# views.py
from django.http import JsonResponse
from .models import FavoritePill
from django.views import View

class FavoritesView(View):
    def get(self, request, user_id):
        favorites = FavoritePill.objects.filter(user_id=user_id).values('pill_code', 'pill_name')
        data = list(favorites)
        return JsonResponse(data, safe=False)

# views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET
from .models import Record

@csrf_exempt
@require_GET

def get_search_history(request, user_id):
    records = Record.objects.filter(user__id=user_id)
    data = list(records.values(
        'pill_code', 'pill_name', 'confidence', 'efficacy', 'manufacturer',
        'usage', 'precautions_before_use', 'usage_precautions', 'drug_food_interactions',
        'side_effects', 'storage_instructions', 'pill_image', 'pill_info'
    ))
    return JsonResponse({'results': data})



from django.http import JsonResponse
import json

def save_search_history(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            pill_info = data.get('pill_info')
            user_id = data.get('user_id')
            prediction_score = data.get('prediction_score')
            product_name = data.get('product_name')
            manufacturer = data.get('manufacturer')
            pill_code = data.get('pill_code')
            efficacy = data.get('efficacy')
            usage = data.get('usage')
            precautions_before_use = data.get('precautions_before_use')
            usage_precautions = data.get('usage_precautions')
            drug_food_interactions = data.get('drug_food_interactions')
            side_effects = data.get('side_effects')
            storage_instructions = data.get('storage_instructions')

            # Validate the received data
            if not all([user_id, prediction_score, product_name, manufacturer, pill_code]):
                return JsonResponse({'status': 'error', 'message': 'Missing required fields'}, status=400)

            # Fetch or create the User instance
            try:
                user_instance = Userlist.objects.get(pk=user_id)
            except Userist.DoesNotExist:
                return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)

            # Create a new Record entry
            record =  Record.objects.create(
                pill_code=pill_code,
                pill_name=product_name,
                confidence=prediction_score,
                efficacy=efficacy,
                manufacturer=manufacturer,
                usage=usage,
                precautions_before_use=precautions_before_use,
                usage_precautions=usage_precautions,
                drug_food_interactions=drug_food_interactions,
                side_effects=side_effects,
                storage_instructions=storage_instructions,
                pill_image='',  # Assuming you have an image URL or path; otherwise, leave it empty
                pill_info=pill_info,
                user=user_instance
            )
            print("Record created successfully")
            return JsonResponse({'status': 'success'})
        
        except json.JSONDecodeError:
            return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)
        
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
