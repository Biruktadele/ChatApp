import socketio
import time

# Standard Python-SocketIO client
sio = socketio.Client()

# --- Configuration ---
# Replace with your actual data for testing
USER_ID = 1  # The ID of the user sending the message
CHAT_ID = 1  # The ID of the chat to join
SERVER_URL = "http://0.0.0.0:8001/"  # Your Django server address

@sio.event
def connect():
    """Called when the client successfully connects to the server."""
    print(f"Successfully connected to the server with sid: {sio.sid}")
    
    # Step 1: Join the chat room
    print(f"Attempting to join chat {CHAT_ID} as user {USER_ID}...")
    sio.emit('join', {'user_id': USER_ID, 'chat_id': CHAT_ID})

@sio.event
def connect_error(data):
    """Called if the connection to the server fails."""
    print("Connection failed!")

@sio.event
def disconnect():
    """Called when the client is disconnected from the server."""
    print("Disconnected from the server.")

@sio.event
def message(data):
    """
    Listens for 'message' events from the server.
    This is where we receive new chat messages.
    """
    print("\n--- New Message Received ---")
    print(f"  Sender: {data.get('sender_username')} (ID: {data.get('sender_id')})")
    print(f"  Chat ID: {data.get('chat_id')}")
    print(f"  Content: '{data.get('content')}'")
    print(f"  Timestamp: {data.get('created_at')}")
    print("--------------------------\n")

def run_test():
    """Main function to run the test client."""
    try:
        # Connect to the server
        sio.connect(SERVER_URL, socketio_path='/socket.io/')
        
        # Wait a moment for the 'join' event to be processed
        time.sleep(1)
        
        # Step 2: Send a message to the chat
        message_to_send = "Hello, this is a test message from the client!"
        print(f"Sending message: '{message_to_send}'")
        sio.emit('send_message', {'message': message_to_send})
        
        # Keep the client running for a few seconds to receive messages
        time.sleep(3)
        
    except socketio.exceptions.ConnectionError as e:
        print(f"Connection Error: Could not connect to the server at {SERVER_URL}.")
        print("Please ensure your Django server is running.")
        
    finally:
        # Disconnect the client
        if sio.connected:
            sio.disconnect()

if __name__ == '__main__':
    print("Starting Socket.IO test client...")
    run_test()
