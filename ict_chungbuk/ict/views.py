import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array, load_img
from PIL import Image
from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Userlist
from .serializers import UserlistSerializer
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth import authenticate


import pytesseract
from django.shortcuts import render, redirect
from django.contrib import messages
from django import forms
from .models import Userlist
from django.urls import path
# ict/views.py



# 모델 로딩
model = tf.keras.models.load_model('/Users/seon/Desktop/pill_identification_porject/models/model.keras')

# 레이블 맵 로딩
label_map_path = '/Users/seon/Desktop/pill_identification_porject/models/label_map.json'
with open(label_map_path, 'r') as f:
    label_map = json.load(f)
reverse_label_map = {v: k for k, v in label_map.items()}

def preprocess_image(image):
    image = Image.open(image)
    image = image.convert('RGB')
    image = image.resize((150, 150))
    img_array = img_to_array(image) / 255.0
    img_array = np.expand_dims(img_array, axis=0)  # 배치 차원 추가
    return img_array

def extract_text_from_image(image):
    image = Image.open(image)
    text = pytesseract.image_to_string(image)
    return text.strip()

@api_view(['POST'])
def predict(request):
    if 'file' not in request.FILES:
        return JsonResponse({'error': 'No file provided'}, status=400)

    image_file = request.FILES['file']
    image_array = preprocess_image(image_file)
    text = extract_text_from_image(image_file)

    try:
        predictions = model.predict(image_array)
        predicted_class = np.argmax(predictions, axis=1)[0]
        predicted_label = reverse_label_map.get(predicted_class, 'Unknown')
        confidence = np.max(predictions)

        if predicted_label != 'Unknown':
            pill_name, company_name, class_no = predicted_label.split('_')
        else:
            pill_name, company_name, class_no = 'Unknown', 'Unknown', 'Unknown'

        return JsonResponse({
            'prediction': predicted_label,
            'confidence': float(confidence),
            'extracted_text': text,
            'pill_name': pill_name,
            'company_name': company_name,
            'class_no': class_no
        })
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)
    


@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        # Get data from request
        username = request.data.get('username', '')
        nickname = request.data.get('nickname', '')
        password = request.data.get('password', '')
        location = request.data.get('location', '')
        email = request.data.get('email', '')

        # Validate fields
        if not username or not nickname or not password or not location or not email:
            return Response({'message': 'All fields are required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Check for duplicates
        if Userlist.objects.filter(nickname=nickname).exists():
            return Response({'message': '이미 사용중인 닉네임입니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
        if Userlist.objects.filter(username=username).exists():
            return Response({'message': '이미 사용중인 아이디입니다.'}, status=status.HTTP_400_BAD_REQUEST)

        if Userlist.objects.filter(email=email).exists():
            return Response({'message': '가입된 이메일이 존재합니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Serialize and save data
        serializer = UserlistSerializer(data={
            'username': username,
            'nickname': nickname,
            'password': password,
            'location': location,
            'email': email
        })

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
# views.py

from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from .models import Userlist
import json

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')

            print(f"Received login request: Username={username}, Password={password}")

            # 사용자 모델에서 해당 ID로 사용자 찾기
            try:
                user = Userlist.objects.get(username=username)
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
