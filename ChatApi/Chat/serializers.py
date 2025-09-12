from rest_framework import serializers
from .models import Chat, Message
from typing import Optional

class ChatSerializer(serializers.ModelSerializer):
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    last_message_time = serializers.SerializerMethodField()
    
    def get_last_message(self, obj):
        last_msg = obj.messages.last()
        return last_msg.content if last_msg else None
    

    def get_unread_count(self, obj) -> int:
        return obj.messages.filter(is_read=False).count()
    
    def get_last_message_time(self, obj) -> Optional[str]:
        last_msg = obj.messages.last()
        return last_msg.created_at.strftime('%Y-%m-%d %H:%M') if last_msg else None
    
    class Meta:
        model = Chat
        fields = ['id', 'user1_id', 'user2_id', 'last_message', 'unread_count', 'last_message_time']
    
   
class intiatChatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chat
        fields = ['id' , 'user1_id' , 'user2_id']
        read_only_fields = ['id' , 'user1_id']
    def create(self, validated_data):
        last_chat = ""
        user1_id = self.context['request'].user
        user2_id = validated_data.pop('user2_id')
        user1_id , user2_id = sorted([user1_id , user2_id] , key = lambda u: u.id)

        try:
            chat = Chat.objects.get(user1_id=user1_id, user2_id=user2_id)
            return chat
        except Chat.DoesNotExist:
            return Chat.objects.create(user1_id=user1_id, user2_id=user2_id)



class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = '__all__'


class sendMessageSerializer(serializers.ModelSerializer):
    content = serializers.CharField()

    class Meta:
        model = Message
        fields = ['content']

    def create(self, validated_data):
        chat_pk = self.context['chat_id']

        try:
            chat_instance = Chat.objects.get(pk=chat_pk)
        except Chat.DoesNotExist:
            raise serializers.ValidationError({"chat": "Chat with this ID does not exist."})

        sender_instance = self.context['request'].user

        content = validated_data['content']

        return Message.objects.create(
            chat_id=chat_instance,     
            sender_id=sender_instance, 
            content=content
        )