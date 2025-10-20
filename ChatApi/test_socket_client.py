import socketio
import time

# Standard Python client for testing
sio = socketio.Client()

# --- Test Configuration ---
BASE_URL = 'http://localhost:8000'
TEST_ROOM = 'test-room'
TEST_USERNAME = 'test-user'
TEST_MESSAGE = 'Hello from the test client!'

# --- Event Handlers ---
@sio.event
def connect():
    print("Connection established")
    print(f"Joining room: {TEST_ROOM} as {TEST_USERNAME}")
    sio.emit('join', {'room': TEST_ROOM, 'username': TEST_USERNAME})

@sio.event
def disconnect():
    print("Disconnected from server")

@sio.event
def message(data):
    """Handles incoming messages from the server."""
    username = data.get('username')
    msg = data.get('message')
    timestamp = data.get('timestamp')
    
    print(f"[{timestamp}] {username}: {msg}")

    # --- Test Assertions ---
    # Check for the welcome message
    if username == 'System' and 'has joined the room' in msg:
        print("\n[SUCCESS] Join event successful. Server sent welcome message.")
        print("Now sending a test message...")
        sio.emit('send_message', {'message': TEST_MESSAGE})

    # Check for the broadcasted message from our test user
    elif username == TEST_USERNAME and msg == TEST_MESSAGE:
        print(f"\n[SUCCESS] send_message event successful. Server broadcasted the message.")
        print("Now disconnecting...")
        sio.disconnect()

# --- Main Execution ---
if __name__ == '__main__':
    try:
        print(f"Connecting to server at {BASE_URL}...")
        sio.connect(BASE_URL)
        sio.wait()
    except socketio.exceptions.ConnectionError as e:
        print(f"\n[ERROR] Connection failed: {e}")
        print("Please make sure your Django server is running.")
    except Exception as e:
        print(f"\n[ERROR] An unexpected error occurred: {e}")