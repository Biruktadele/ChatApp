from rest_framework import serializers
from .models import Chat, Message
from django.contrib.auth import get_user_model

User = get_user_model()

class ChatSerializer(serializers.ModelSerializer):
    """
    Serializer for listing existing chats.
    """
    class Meta:
        model = Chat
        fields = ['id', 'user1_id', 'user2_id', 'last_message', 'updated_at']

class intiatChatSerializer(serializers.ModelSerializer):
    """
    Serializer for creating a new chat.
    """
    user2_id = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())

    class Meta:
        model = Chat
        fields = ['user2_id']

    def create(self, validated_data):
        user1 = self.context['request'].user
        user2 = validated_data['user2_id']
        # Simple check to prevent duplicate chats
        chat = Chat.objects.filter(user1_id=user1, user2_id=user2).first()
        if not chat:
            chat = Chat.objects.filter(user1_id=user2, user2_id=user1).first()
        if not chat:
            chat = Chat.objects.create(user1_id=user1, **validated_data)
        return chat

class MessageSerializer(serializers.ModelSerializer):
    """
    Serializer for listing messages.
    """
    class Meta:
        model = Message
        fields = ['id', 'chat_id', 'sender_id', 'content', 'created_at']

class sendMessageSerializer(serializers.ModelSerializer):
    """
    Serializer for sending a new message.
    """
    class Meta:
        model = Message
        fields = ['content']

    def create(self, validated_data):
        sender = self.context['request'].user
        chat_id = self.context['chat_id']
        
        message = Message.objects.create(
            sender_id=sender,
            chat_id_id=chat_id,
            **validated_data
        )
        return message