from rest_framework import viewsets
from .models import Chat, Message
from .serializers import ChatSerializer, MessageSerializer , intiatChatSerializer , sendMessageSerializer
from django.db.models import Q



class ChatViewSet(viewsets.ModelViewSet):

    queryset = Chat.objects.all()

    def get_queryset(self):
        return Chat.objects.filter(Q(user1_id=self.request.user) | Q(user2_id=self.request.user))
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return intiatChatSerializer
        return ChatSerializer

class MessageViewSet(viewsets.ModelViewSet):
    serializer_class = MessageSerializer # Default serializer for other actions (list, retrieve)
    
    def get_queryset(self):
        # Filter messages by the chat_pk from the URL
        chat_pk = self.kwargs['chat_pk']
        return Message.objects.filter(chat_id=chat_pk).order_by('created_at') # Assuming a timestamp field for ordering

    def get_serializer_class(self):
        # Use sendMessageSerializer for POST requests
        if self.action == 'create': # Use 'create' action instead of 'POST' method
            return sendMessageSerializer
        return MessageSerializer

    def get_serializer_context(self):
        """
        Add request and chat_pk to the serializer context.
        """
        context = super().get_serializer_context() # Get default context
        context.update({
            'request': self.request, # Pass the request object
            'chat_id': self.kwargs['chat_pk'] # Pass the chat_pk
        })
        return context