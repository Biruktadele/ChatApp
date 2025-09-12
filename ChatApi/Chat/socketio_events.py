import socketio
from datetime import datetime, timezone
from asgiref.sync import sync_to_async

from core.models import User

from .models import *

sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')

# Store connected clients
connected_clients = {}

# Create async-compatible ORM operations
get_chat = sync_to_async(Chat.objects.get, thread_sensitive=True)
get_user = sync_to_async(User.objects.get, thread_sensitive=True)
create_message = sync_to_async(Message.objects.create, thread_sensitive=True)

@sio.event
async def connect(sid, environ):
    print(f"Client connected: {sid}")

@sio.event
async def disconnect(sid):
    print(f"Client disconnected: {sid}")
    if sid in connected_clients:
        del connected_clients[sid]

async def save_and_broadcast_message(chat_id, user_id, content):
    """Saves a message to the database and broadcasts it to the chat room."""
    try:
        # Get chat and user objects from the database using the async wrappers
        chat = await get_chat(id=chat_id)
        user = await get_user(id=user_id)

        # Create the message
        msg = await create_message(
            chat_id=chat,
            sender_id=user,
            content=content
        )
        
        # Prepare the message payload to be sent to clients
        message_payload = {
            'id': msg.id,
            'chat_id': msg.chat_id.id,
            'sender_id': msg.sender_id.id,
            'sender_username': msg.sender_id.username,
            'content': msg.content,
            'created_at': msg.created_at.isoformat(),
            'is_read': msg.is_read,
        }
        
        # Broadcast the message to the room (which is the chat_id)
        await sio.emit('message', message_payload, room=str(chat.id))

    except Chat.DoesNotExist:
        print(f"Error: Could not send message. Chat with id {chat_id} not found.")
    except User.DoesNotExist:
        print(f"Error: Could not send message. User with id {user_id} not found.")
    except Exception as e:
        print(f"An unexpected error occurred while saving/broadcasting message: {e}")



@sio.event
async def join(sid, data):
    user_id = data.get('user_id')
    chat_id = data.get('chat_id')
    
    if not user_id or not chat_id:
        return False
    
    # Store user session
    connected_clients[sid] = {'user_id': user_id, 'chat_id': chat_id}

    # Join the room use
    await sio.enter_room(sid, str(chat_id))


@sio.event
async def send_message(sid, data):
    if sid not in connected_clients:
        print(f"Error: Unauthenticated user with sid {sid} tried to send a message.")
        return False
    
    session_data = connected_clients[sid]
    message = data.get('message')
    
    if not message:
        return False
    
    # Save and broadcast message
    await save_and_broadcast_message(
        chat_id=session_data['chat_id'],
        user_id=session_data['user_id'],
        content=message
    )
    return True