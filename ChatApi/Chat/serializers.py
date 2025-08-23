from rest_framework import serializers
from .models import Chat, Message

class ChatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chat
        fields = '__all__'

class intiatChatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chat
        fields = '__all__'
    def create(self, validated_data):
        user1_id = validated_data.pop('user1_id')
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