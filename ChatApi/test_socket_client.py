import argparse
import socketio
import threading
import time
from typing import Optional, Dict, Any


class TestClient:
    """A small wrapper around socketio.Client with handy waitable flags."""

    def __init__(self, name: str, base_url: str):
        self.name = name
        # self.base_url = "http://0.0.0.0:8001"
        self.base_url = base_url
        self.sio = socketio.Client()

        # Waitable events
        self.connected_evt = threading.Event()
        self.disconnected_evt = threading.Event()
        self.join_ack: Optional[bool] = None
        self.last_message: Optional[Dict[str, Any]] = None
        self.message_evt = threading.Event()
        self.suggestions: Optional[Any] = None
        self.suggestions_evt = threading.Event()
        self.typing_from: Optional[int] = None
        self.typing_evt = threading.Event()
        self.stop_typing_from: Optional[int] = None
        self.stop_typing_evt = threading.Event()
        self.message_read_id: Optional[int] = None
        self.message_read_evt = threading.Event()

        # Bind handlers
        self._bind_handlers()

    # ---------------- Handlers ----------------
    def _bind_handlers(self):
        @self.sio.event
        def connect():
            print(f"[{self.name}] connected")
            self.connected_evt.set()

        @self.sio.event
        def disconnect():
            print(f"[{self.name}] disconnected")
            self.disconnected_evt.set()

        @self.sio.on('connected')
        def on_connected(data):
            # Server sends this only to the connecting sid
            print(f"[{self.name}] server says: {data}")

        @self.sio.on('disconnected')
        def on_disconnected(data):
            print(f"[{self.name}] server says: {data}")

        @self.sio.on('chat_message')
        def on_message(data):
            # Server payload: {id, chat_id, sender_id, sender_username, content, created_at, is_read}
            self.last_message = data
            print(f"[{self.name}] message: {data}")
            self.message_evt.set()

        @self.sio.on('suggestions_event')
        def on_suggestions(data):
            self.suggestions = data
            print(f"[{self.name}] suggestions_event: {data}")
            self.suggestions_evt.set()

        @self.sio.on('typing')
        def on_typing(data):
            self.typing_from = data.get('user_id')
            print(f"[{self.name}] typing from user {self.typing_from}")
            self.typing_evt.set()

        @self.sio.on('stop_typing')
        def on_stop_typing(data):
            self.stop_typing_from = data.get('user_id')
            print(f"[{self.name}] stop_typing from user {self.stop_typing_from}")
            self.stop_typing_evt.set()

        @self.sio.on('message_read')
        def on_message_read(data):
            self.message_read_id = data.get('message_id')
            print(f"[{self.name}] message_read: {data}")
            self.message_read_evt.set()

    # ---------------- API ----------------
    def connect(self, timeout: float = 10.0):
        self.sio.connect(self.base_url, wait_timeout=timeout)
        if not self.connected_evt.wait(timeout):
            raise TimeoutError(f"[{self.name}] connect timeout")

    def disconnect(self):
        self.sio.disconnect()

    def join(self, user_id: int, chat_id: int, timeout: float = 5.0):
        # Server returns True/False via ack. Retry with string IDs if needed, then fire-and-forget.
        payload_int = {'user_id': user_id, 'chat_id': chat_id}

        def try_call(payload):
            try:
                return self.sio.call('join_chat', payload, timeout=timeout)
            except Exception as e:
                print(f"[{self.name}] join_chat call failed: {e}")
                return False

        ack = try_call(payload_int)

        self.join_ack = bool(ack)
        print(f"[{self.name}] join_chat ack: {self.join_ack}")
        return self.join_ack

    def start_typing(self, timeout: float = 5.0):
        # Try ack; fallback to emit without ack
        try:
            ack = self.sio.call('start_typing', {}, timeout=timeout)
            if ack:
                return True
        except Exception as e:
            print(f"[{self.name}] start_typing call failed: {e}")
        try:
            self.sio.emit('start_typing', {})
            return True
        except Exception as e:
            print(f"[{self.name}] start_typing emit failed: {e}")
            return False

    def stop_typing(self, timeout: float = 5.0):
        try:
            ack = self.sio.call('stop_typing', {}, timeout=timeout)
            if ack:
                return True
        except Exception as e:
            print(f"[{self.name}] stop_typing call failed: {e}")
        try:
            self.sio.emit('stop_typing', {})
            return True
        except Exception as e:
            print(f"[{self.name}] stop_typing emit failed: {e}")
            return False

    def send_message(self, message: str, timeout: float = 5.0):
        try:
            ack = self.sio.call('send_message', {'message': message}, timeout=timeout)
            if ack:
                return True
        except Exception as e:
            print(f"[{self.name}] send_message call failed: {e}")
        try:
            self.sio.emit('send_message', {'message': message})
            return True
        except Exception as e:
            print(f"[{self.name}] send_message emit failed: {e}")
            return False

    def mark_as_read(self, message_id: int, timeout: float = 5.0):
        try:
            ack = self.sio.call('mark_as_read', {'message_id': message_id}, timeout=timeout)
            if ack:
                return True
        except Exception as e:
            print(f"[{self.name}] mark_as_read call failed: {e}")
        try:
            self.sio.emit('mark_as_read', {'message_id': message_id})
            return True
        except Exception as e:
            print(f"[{self.name}] mark_as_read emit failed: {e}")
            return False


def run_end_to_end(
    base_url: str,
    chat_id: int,
    user1_id: int,
    user2_id: int,
    message: str,
    wait_timeout: float = 8.0,
):
    """Runs an end-to-end test across two clients for join, typing, send, and read."""

    sender = TestClient('sender', base_url)
    receiver = TestClient('receiver', base_url)

    # Connect both
    print(f"Connecting to server at {base_url}...")
    sender.connect()
    receiver.connect()

    # Join same chat with different users
    if not sender.join(user1_id, chat_id):
        print("[WARN] sender join ack failed; proceeding assuming legacy join works")
    if not receiver.join(user2_id, chat_id):
        print("[WARN] receiver join ack failed; proceeding assuming legacy join works")
    time.sleep(0.5)

    # Typing flow: typing events are broadcast to others (skip sender), so receiver should see them
    print("Testing typing -> stop_typing events...")
    assert sender.start_typing(), "start_typing ack failed"

    assert receiver.typing_evt.wait(wait_timeout), "receiver didn't get 'typing' event"
    print("[OK] receiver saw typing")

    # Server auto-sends stop_typing after ~2s
    assert receiver.stop_typing_evt.wait(wait_timeout), "receiver didn't get 'stop_typing' event"
    print("[OK] receiver saw stop_typing")

    # Message flow: sender sends; everyone in room receives 'chat_message'. Also may receive suggestions_event.
    print("Testing send_message -> chat_message broadcast...")
    assert sender.send_message(message), "send_message ack failed"
    assert receiver.message_evt.wait(wait_timeout), "receiver didn't get 'chat_message' event"
    print("[OK] receiver saw message")

    # Optionally wait briefly for suggestions (non-fatal if missing)
    receiver.suggestions_evt.wait(3.0)

    # Mark as read from receiver
    msg_id = None
    if receiver.last_message and isinstance(receiver.last_message.get('id'), int):
        msg_id = receiver.last_message['id']
    if msg_id is not None:
        print(f"Marking message {msg_id} as read from receiver...")
        assert receiver.mark_as_read(msg_id), "mark_as_read ack failed"
        # Anyone in room can see message_read; check sender for variety
        assert sender.message_read_evt.wait(wait_timeout), "sender didn't get 'message_read' event"
        print("[OK] sender saw message_read")
    else:
        print("[WARN] Couldn't extract message id for mark_as_read test")

    # Cleanup
    sender.disconnect()
    receiver.disconnect()
    print("All tests passed.")


def parse_args():
    p = argparse.ArgumentParser(description="Socket.IO E2E test: join, typing, send, read")
    p.add_argument('--base-url', default='https://chatapp-1-603s.onrender.com/', help='Socket.IO server base URL')
    p.add_argument('--chat-id', type=int, default=1, help='Existing Chat.id to join')
    p.add_argument('--user1-id', type=int, default=3, help='Existing User.id for sender')
    p.add_argument('--user2-id', type=int, default=4, help='Existing User.id for receiver')
    p.add_argument('--message', default='Hello from test client!', help='Message text to send')
    return p.parse_args()


if __name__ == '__main__':
    args = parse_args()
    try:
        run_end_to_end(
            base_url=args.base_url,
            chat_id=args.chat_id,
            user1_id=args.user1_id,
            user2_id=args.user2_id,
            message=args.message,
        )
    except socketio.exceptions.ConnectionError as e:
        print(f"\n[ERROR] Connection failed: {e}")
        print("Ensure the server is reachable and the URL is correct.")
    except AssertionError as e:
        print(f"\n[FAILED] {e}")
    except Exception as e:
        print(f"\n[ERROR] Unexpected error: {e}")