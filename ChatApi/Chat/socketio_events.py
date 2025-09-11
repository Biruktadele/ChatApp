import socketio
from datetime import datetime, timezone
from asgiref.sync import sync_to_async
from django.contrib.auth import get_user_model

from .models import Chat, Message

sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')

# Store connected clients
connected_clients = {}

# Create async-compatible ORM operations
get_chat = sync_to_async(Chat.objects.get, thread_sensitive=True)
get_user = sync_to_async(get_user_model().objects.get, thread_sensitive=True)
create_message = sync_to_async(Message.objects.create, thread_sensitive=True)

@sio.event
async def connect(sid, environ):
    print(f"Client connected: {sid}")

@sio.event
async def disconnect(sid):
    print(f"Client disconnected: {sid}")
    if sid in connected_clients:
        chat_id = connected_clients[sid]['chat_id']
        username = connected_clients[sid]['username']
        
        # Broadcast a system message that the user has left
        await save_and_broadcast_message(
            chat_id=chat_id,
            message=f'{username} has left the chat'
        )
        
        del connected_clients[sid]

async def save_and_broadcast_message(chat_id, message, sender_id=None):
    """
    Saves a message to the database and broadcasts it to the chat.
    If sender_id is None, it's treated as a system message.
    """
    try:
        chat_obj = await get_chat(id=chat_id)
        sender_obj = None
        username = 'System'

        # If it's a user message, get the user object
        if sender_id:
            sender_obj = await get_user(id=sender_id)
            username = sender_obj.username

        # Save the message to the database
        msg = await create_message(
            chat_id=chat_obj,
            sender_id=sender_obj,  # This will be the User object or None
            content=message
        )
        
        # Broadcast the message to the room
        await sio.emit('message', {
            'username': username,
            'message': msg.content,
            'timestamp': msg.created_at.isoformat()
        }, room=f"chat_{chat_id}")

    except Exception as e:
        print(f"Error in save_and_broadcast_message: {e}")


@sio.event
async def join(sid, data):
    username = data.get('username')
    chat_id = data.get('chat_id')
    
    if not username or not chat_id:
        return False
    
    connected_clients[sid] = {'username': username, 'chat_id': chat_id}
    await sio.enter_room(sid, f"chat_{chat_id}")
    
    # Broadcast a system message that the user has joined
    await save_and_broadcast_message(
        chat_id=chat_id,
        message=f'{username} has joined the chat'
    )

@sio.event
async def send_message(sid, data):
    if sid not in connected_clients:
        return False
    
    user_session = connected_clients[sid]
    message_content = data.get('message')
    sender_id = data.get('sender_id')
    
    if not message_content or not sender_id:
        return False
    
    # Save and broadcast the user's message
    await save_and_broadcast_message(
        chat_id=user_session['chat_id'],
        message=message_content,
        sender_id=sender_id  # Pass the sender_id
    )