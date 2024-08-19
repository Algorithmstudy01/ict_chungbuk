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


import torch
import torchvision.transforms as transforms
from PIL import Image
from rest_framework.decorators import api_view
from rest_framework.response import Response
import pytesseract

import os
import json
import torch
import torchvision.transforms as transforms
from PIL import Image
import pytesseract
from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.conf import settings
from .models import Userlist
import torch
import torchvision
from django.conf import settings
from rest_framework.response import Response
from rest_framework.decorators import api_view
from PIL import Image
import torchvision.transforms as transforms
import json
import os

# Define the Faster R-CNN model class
def get_model(num_classes):
    from torchvision.models.detection import FasterRCNN
    from torchvision.models.mobilenetv3 import mobilenet_v3_large
    from torchvision.models.detection.anchor_utils import AnchorGenerator

    # MobileNetV3 based backbone
    backbone = mobilenet_v3_large(pretrained=True).features
    backbone.out_channels = 960

    # Anchor generator
    anchor_generator = AnchorGenerator(
        sizes=((32, 64, 128, 256, 512),),
        aspect_ratios=((0.5, 1.0, 2.0),) * 5
    )

    # ROI Align
    roi_pooler = torchvision.ops.MultiScaleRoIAlign(
        featmap_names=['0'], output_size=7, sampling_ratio=2
    )

    # Faster R-CNN model
    model = FasterRCNN(
        backbone,
        num_classes=num_classes,
        rpn_anchor_generator=anchor_generator,
        box_roi_pool=roi_pooler
    )

    return model

# Load the model
def load_model():
    model = get_model(num_classes=60)
    model_path = settings.MODEL_PATH  # Use Django settings for model path
    try:
        model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
        model.eval()
    except RuntimeError as e:
        print(f"Error loading state dict: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    return model

model = load_model()

# Preprocess image
def preprocess_image(image):
    image = Image.open(image).convert("RGB")
    transform = transforms.Compose([
        transforms.ToTensor(),
    ])
    img_tensor = transform(image).unsqueeze(0)
    return img_tensor

# Find pill information
def find_pill_info(predicted_category_id, root_dir):
    for folder_name in os.listdir(root_dir):
        folder_path = os.path.join(root_dir, folder_name)
        if os.path.isdir(folder_path):
            for file_name in os.listdir(folder_path):
                if file_name.endswith('.json'):
                    json_path = os.path.join(folder_path, file_name)
                    with open(json_path, 'r') as f:
                        data = json.load(f)
                        if any(cat['id'] == predicted_category_id for cat in data['categories']):
                            pill_info = {
                                "code": data['images'][0].get('drug_N', 'N/A'),
                                "name": data['images'][0].get('dl_name', 'N/A'),
                                "image_path": os.path.join(folder_path, data['images'][0].get('file_name'))
                            }
                            return pill_info
    return None

# Predict view function
@api_view(['POST'])
def predict(request):
    if 'file' not in request.FILES:
        return Response({'error': 'No file provided'}, status=400)
    
    image_file = request.FILES['file']
    
    try:
        # Preprocess image
        image_tensor = preprocess_image(image_file)
        
        # Make prediction
        with torch.no_grad():
            outputs = model(image_tensor)
            pred_scores = outputs[0]['scores'].cpu().numpy()
            pred_labels = outputs[0]['labels'].cpu().numpy()

            # Filter results
            threshold = 0.1
            pred_labels = pred_labels[pred_scores >= threshold]
            pred_scores = pred_scores[pred_scores >= threshold]

            if len(pred_labels) == 0:
                return Response({'error': 'No predictions above the threshold'}, status=404)

            # Get the most confident prediction
            max_score_idx = pred_scores.argmax()
            predicted_category_id = pred_labels[max_score_idx]
            confidence = float(pred_scores[max_score_idx])

        # Find pill information based on the predicted class
        root_dir = settings.DATA_ROOT_DIR
        pill_info = find_pill_info(predicted_category_id, root_dir)
        
        if pill_info:
            return Response({
                'pill_info': pill_info,
                'confidence': confidence,
            })
        else:
            return Response({'error': 'Pill information not found'}, status=404)
    
    except Exception as e:
        print(f"Exception occurred: {str(e)}")
        return Response({'error': str(e)}, status=500)


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


from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Userlist  # Assuming this is your user model
from .serializers import UserlistSerializer  # Your serializer
@api_view(['POST'])
def find_user_id(request):
    if request.method == 'POST':
        email = request.data.get('email', None)
        if email:
            try:
                user = Userlist.objects.get(email=email)
                serializer = UserlistSerializer(user)
                return Response({"username": serializer.data['username']}, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "이메일을 입력해주세요."}, status=400)

# 비밀번호 찾기from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist  # Adjust according to your user model
from .serializers import UserlistSerializer  # Adjust according to your serializer

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist  # Adjust according to your user model
from .serializers import UserlistSerializer  # Adjust according to your serializer

@api_view(['POST'])
def find_password(request):
    username = request.data.get('username', None)
    email = request.data.get('email', None)

    if not username or not email:
        return Response({"message": "아이디와 이메일을 입력해주세요."}, status=400)

    try:
        user = Userlist.objects.get(username=username, email=email)
        return Response({"password": user.password}, status=200)
    except Userlist.DoesNotExist:
        return Response({"message": "일치하는 사용자가 없습니다."}, status=400)

# 비밀번호 업데이트 
@api_view(['PUT'])
def update_password(request):
    if request.method == 'PUT':
        user_id = request.data.get('id', None)
        new_password = request.data.get('password', None)
        if user_id and new_password:
            try:
                user = Userlist.objects.get(id=user_id)
                user.password = new_password
                user.save()
                return Response({"message": "비밀번호가 성공적으로 업데이트되었습니다."}, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "ID와 새로운 비밀번호를 모두 제공해주세요."}, status=400)
