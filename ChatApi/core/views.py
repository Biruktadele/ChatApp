from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import User
from .serializers import UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    @action(detail=False, methods=['get', 'put', 'patch', 'delete'])
    def me(self, request):
        user = User.objects.get(id=request.user.id)

        if request.method == 'GET':
            serializer = UserSerializer(user)
            return Response(serializer.data)

        if request.method == 'PUT':
            serializer = UserSerializer(user, data=request.data)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)
        
        if request.method == 'PATCH':
            serializer = UserSerializer(user, data=request.data, partial=True)  # Add partial=True
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)

        if request.method == 'DELETE':
            user.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
from rest_framework import generics
from .serializers import RegisterSerializer
# from django.contrib.auth.models import User

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer