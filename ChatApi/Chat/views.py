from rest_framework import viewsets
from .models import *
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
from django.shortcuts import render, redirect
# from .models import Room, Message

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        chat_id = request.POST.get('chat_id') # Removed .lower()

        if username and chat_id:
            request.session['username'] = username
            request.session['chat_id'] = chat_id

            # Create chat if it doesn't exist
            Chat.objects.get_or_create(id=chat_id)

            return redirect('chat', chatid=chat_id) # Ensure your URL name is 'chat' and it takes 'chatid'

    return render(request, 'login.html')


def chat_view(request, chatid):
    username = request.session.get('username')
    if not username:
        return redirect('login')
    
    messages = []
    try:
        # Use Chat model, not Room
        chat_instance = Chat.objects.get(id=chatid)
        # Order by 'created_at', not 'timestamp'
        messages = Message.objects.filter(chat_id=chat_instance).order_by('-created_at')[:50]
    except Chat.DoesNotExist: # Catch Chat.DoesNotExist
        # You might want to handle this case, e.g., show an error
        pass
    
    # Format messages for template
    formatted_messages = []
    for message in messages:
        # Check if sender exists to determine if it's a system message
        is_system_msg = message.sender_id is None
        
        formatted_messages.append({
            # Use sender's username if it exists, otherwise 'System'
            'username': 'System' if is_system_msg else message.sender_id.username,
            'content': message.content,
            'timestamp': message.created_at,
            'is_system': is_system_msg,
            'is_current_user': False if is_system_msg else message.sender_id.username == username,
        })
    
    context = {
        'chat_id': chatid,
        'username': username,
        'messages': list(reversed(formatted_messages))  # Show oldest first
    }
    return render(request, 'chat.html', context)