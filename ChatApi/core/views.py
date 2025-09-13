from rest_framework import viewsets
from .models import User
from .serializers import *


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
# accounts/views.py
from rest_framework import generics
from .serializers import RegisterSerializer
# from django.contrib.auth.models import User

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
