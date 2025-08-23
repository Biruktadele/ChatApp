# # core/consumers.py

# import json
# from channels.generic.websocket import AsyncWebsocketConsumer
# from channels.db import database_sync_to_async # To interact with Django ORM safely
# from django.contrib.auth import get_user_model
# from .models import Chat, Message

# User = get_user_model()

# class ChatConsumer(AsyncWebsocketConsumer):
#     async def connect(self):
#         # Extract chat_pk from the URL
#         self.chat_pk = self.scope['url_route']['kwargs']['chat_pk']
#         self.chat_group_name = f'chat_{self.chat_pk}'

#         # Add channel to the group
#         await self.channel_layer.group_add(
#             self.chat_group_name,
#             self.channel_name
#         )
#         await self.accept()

#     async def disconnect(self, close_code):
#         # Remove channel from the group when disconnecting
#         await self.channel_layer.group_discard(
#             self.chat_group_name,
#             self.channel_name
#         )

#     # Receive message from WebSocket
#     async def receive(self, text_data):
#         text_data_json = json.loads(text_data)
#         message_content = text_data_json.get('message')

#         if not message_content:
#             return # Ignore if no message content

#         # --- Save the message to the database ---
#         # You need to fetch the sender and chat instances safely in async context
#         try:
#             # Fetch chat instance (we already have its pk)
#             chat_instance = await self.get_chat(self.chat_pk)
#             # Fetch sender instance from the scope (authenticated user)
#             sender_instance = await self.get_sender()

#             if not chat_instance or not sender_instance:
#                 return # Cannot proceed if instances not found

#             # Create and save the message using the correct field names
#             new_message = await self.create_message(chat_instance, sender_instance, message_content)
#         except Exception as e:
#             print(f"Error saving message: {e}") # Log the error
#             return # Exit if there was an error saving

#         # Send message to the chat group
#         await self.channel_layer.group_send(
#             self.chat_group_name,
#             {
#                 'type': 'chat_message', # This type will map to a method in this consumer
#                 'message': { # Structure the message as you want to send to the frontend
#                     'id': new_message.id,
#                     'sender': str(new_message.sender_id), # Get sender's username
#                     'content': new_message.content,
#                     'created_at': new_message.created_at.isoformat(),
#                     'chat_id': int(self.chat_pk)
#                 }
#             }
#         )

#     # Receive message from room group (broadcasted messages)
#     async def chat_message(self, event):
#         # Send message to WebSocket
#         await self.send(text_data=json.dumps(event['message']))

#     # --- Async helper methods for database operations ---
#     # Use @database_sync_to_async to make synchronous Django ORM calls async

#     @database_sync_to_async
#     def get_chat(self, chat_pk):
#         try:
#             return Chat.objects.get(pk=chat_pk)
#         except Chat.DoesNotExist:
#             return None

#     @database_sync_to_async
#     def get_sender(self):
#         # self.scope['user'] is populated by Django Channels' authentication middleware
#         user = self.scope['user']
#         if user and user.is_authenticated:
#             return user
#         return None

#     @database_sync_to_async
#     def create_message(self, chat_instance, sender_instance, content):
#         # Use the correct field names from your Message model
#         message = Message.objects.create(
#             chat_id=chat_instance,
#             sender_id=sender_instance,
#             content=content
#         )
#         return message