import socketio
import asyncio  # ADDED
from datetime import datetime, timezone
from asgiref.sync import sync_to_async

from .Ai_suggest import generate_smart_replies
from core.models import User

from .models import *

sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')

# Store connected clients
connected_clients = {}

# Create async-compatible ORM operations
get_chat = sync_to_async(Chat.objects.get, thread_sensitive=True)
get_user = sync_to_async(User.objects.get, thread_sensitive=True)
create_message = sync_to_async(Message.objects.create, thread_sensitive=True)
# NEW: async wrapper for smart replies (if original is sync)
async_generate_replies = sync_to_async(generate_smart_replies, thread_sensitive=True)

@sio.event
async def connect(sid, environ):
    await sio.emit('connected', {'message': 'Connected'}, to=sid)
    print(f"Client connected: {sid}")

@sio.event
async def disconnect(sid):
    print(f"Client disconnected: {sid}")
    await sio.emit('disconnected', {'message': 'Disconnected'}, to=sid)
    if sid in connected_clients:
        del connected_clients[sid]

async def save_and_broadcast_message(chat_id, user_id, content , sid):
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
        try:
            suggestions = await async_generate_replies(chat_id, user_id)
            await sio.emit(
                'suggestions_event',
                {'suggestions': suggestions},
                room=str(chat.id)
                # skip_sid=sid
            )

            print('🏵️🛼🛼🛼🛼Sent suggestions_event: ' + suggestions+"")
        except Exception as e:
            print(f"❌❌❌Smart reply generation failed: {e}")
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
    connected_clients[sid] = {'user_id': user_id, 'chat_id': chat_id}
    await sio.enter_room(sid, str(chat_id))
    return True  # ADDED

@sio.event
async def send_message(sid, data):
    if sid not in connected_clients:
        print(f"Error: Unauthenticated user with sid {sid} tried to send a message.")
        return False
    session_data = connected_clients[sid]
    message = data.get('message')
    if not message:
        return False
    # Generate suggestions (non-blocking try). If it fails, continue sending message.
    
    # Save and broadcast message
    await save_and_broadcast_message(
        chat_id=session_data['chat_id'],
        user_id=session_data['user_id'],
        content=message,
        sid=sid
    )
    return True
@sio.event
async def mark_as_read(sid, data):
    if sid not in connected_clients:
        print(f"Error: Unauthenticated user with sid {sid} tried to mark message as read.")
        return False
    
    session_data = connected_clients[sid]
    message_id = data.get('message_id')
    chat_id = session_data['chat_id']
    
    if not message_id:
        return False
    
    try:
        message = await sync_to_async(Message.objects.get, thread_sensitive=True)(id=message_id, chat_id=chat_id)
        message.is_read = True
        await sync_to_async(message.save, thread_sensitive=True)()

        # Optionally, notify other clients in the room that the message has been read
        await sio.emit('message_read', {'message_id': message_id}, room=str(chat_id))
        
        return True
    except Message.DoesNotExist:
        print(f"Error: Message with id {message_id} not found in chat {chat_id}.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred while marking message as read: {e}")
        return False
@sio.event
async def start_typing(sid, data):
    if sid not in connected_clients:
        print(f"Error: Unauthenticated user with sid {sid} tried to start typing.")
        return False
    
    session_data = connected_clients[sid]
    chat_id = session_data['chat_id']
    user_id = session_data['user_id']
    
    # Broadcast typing event to other users in the chat room
    await sio.emit('typing', {'user_id': user_id}, room=str(chat_id) , skip_sid=sid)

    # Wait briefly then auto-stop typing (reduced from 60s)
    await asyncio.sleep(2)
    await sio.emit('stop_typing', {'user_id': user_id}, room=str(chat_id), skip_sid=sid)

    return True
@sio.event
async def stop_typing(sid, data):
    if sid not in connected_clients:
        print(f"Error: Unauthenticated user with sid {sid} tried to stop typing.")
        return False
    
    session_data = connected_clients[sid]
    chat_id = session_data['chat_id']
    user_id = session_data['user_id']
    
    # Broadcast stop typing event to other users in the chat room
    await sio.emit('stop_typing', {'user_id': user_id}, room=str(chat_id) , skip_sid=sid)
    return True
