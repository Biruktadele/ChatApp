# ChatApi: Real-Time Django Chat Application

This project is a robust real-time chat application built with a powerful backend stack featuring Django, Django REST Framework, and Socket.IO. It provides a RESTful API for managing chats and messages, and a WebSocket interface for instant, bidirectional communication.

## Core Features

*   **Real-Time Messaging**: Utilizes `python-socketio` and `uvicorn` to handle persistent WebSocket connections for instant message delivery.
*   **RESTful API**: A comprehensive API built with Django REST Framework to manage users, chats, and message history.
*   **Asynchronous Backend**: Built on an ASGI framework (`uvicorn`) to handle a high number of concurrent connections efficiently.
*   **User Authentication**: Secure endpoints using Django's session authentication.
*   **Scalable Database**: Uses PostgreSQL for reliable and scalable data storage.
*   **Separation of Concerns**: Cleanly separates API logic (views, serializers) from real-time event handling (`socketio_events.py`).

## Technology Stack

*   **Backend**: Python, Django, Django REST Framework
*   **Real-Time Communication**: `python-socketio`
*   **ASGI Server**: Uvicorn
*   **Database**: PostgreSQL
*   **Authentication**: Django Session Authentication

---

## Project Architecture

The application is designed with a clear separation between the traditional HTTP request/response cycle and the real-time WebSocket communication.

1.  **Django & DRF (HTTP Layer)**:
    *   Handles user authentication, API requests (`GET`, `POST`, etc.), and serving initial HTML templates.
    *   The `ChatViewSet` and `MessageViewSet` provide endpoints to list chat history, create new chats, and fetch user data.
    *   All data is serialized into JSON for consumption by any client.

2.  **Socket.IO & Uvicorn (WebSocket Layer)**:
    *   Uvicorn runs the application as an ASGI server, which can handle both HTTP and WebSocket protocols.
    *   The `socketio_events.py` file defines all real-time event handlers (`connect`, `join`, `send_message`, etc.).
    *   When a client sends a message, it emits a `send_message` event. The server receives it, saves the message to the PostgreSQL database, and then broadcasts it to all clients in the same chat room.

---

## Setup and Installation

Follow these steps to get the project running on your local machine for development and testing.

### 1. Prerequisites

*   Python 3.10+
*   PostgreSQL installed and running.
*   A virtual environment tool (like `venv` or `virtualenvwrapper`).

### 2. Clone the Repository

```bash
git clone <your-repository-url>
cd ChatApi
```

### 3. Set Up the Environment

Create and activate a Python virtual environment.

```bash
# Create the virtual environment
python -m venv venv

# Activate it (on Linux/macOS)
source venv/bin/activate
```

### 4. Install Dependencies

Install all required Python packages.

```bash
pip install django djangorestframework psycopg2-binary python-socketio "uvicorn[standard]" django-cors-headers
```

### 5. Configure the Database

1.  Open your PostgreSQL client (`psql`) and create the database and user.

    ```sql
    CREATE DATABASE chatapp;
    CREATE USER postgres WITH PASSWORD '1234';
    ALTER ROLE postgres SET client_encoding TO 'utf8';
    ALTER ROLE postgres SET default_transaction_isolation TO 'read committed';
    ALTER ROLE postgres SET timezone TO 'UTC';
    GRANT ALL PRIVILEGES ON DATABASE chatapp TO postgres;
    ```

2.  Ensure your `ChatApi/settings.py` file has the correct database credentials.

### 6. Run Database Migrations

Apply the database schema and create all necessary tables.

```bash
python manage.py makemigrations
python manage.py migrate
```

### 7. Create a Superuser

This allows you to log in to the Django admin and the DRF browsable API.

```bash
python manage.py createsuperuser
```
Follow the prompts to set your username (e.g., `biruk`) and password (e.g., `1`).

---

## Running the Application

To run the development server, use Uvicorn to serve your ASGI application.

```bash
uvicorn ChatApi.asgi:application --host 0.0.0.0 --port 8001 --reload
```

*   `--host 0.0.0.0`: Makes the server accessible on your local network.
*   `--port 8001`: Runs the server on port 8001.
*   `--reload`: Automatically restarts the server when you make code changes.

You can now access the application at **http://0.0.0.0:8001/**.

---

## API Endpoints

The following REST endpoints are available. You must be authenticated to access them.

| Method | Endpoint              | Description                               |
| :----- | :-------------------- | :---------------------------------------- |
| `GET`  | `/api/chats/`         | Lists all chats for the logged-in user.   |
| `POST` | `/api/chats/`         | Creates a new chat with another user.     |
| `GET`  | `/api/messages/`      | Lists all messages in a specific chat.    |
| `POST` | `/api/messages/`      | Creates a new message in a specific chat. |

---

## Real-Time Socket.IO Events

The client should connect to the Socket.IO server and use the following events.

### Client to Server Events

*   **`join`**: Subscribes the client to a specific chat room.
    *   **Payload**: `{ "username": "your_username", "chat_id": "the_chat_id" }`

*   **`send_message`**: Sends a new message to the server.
    *   **Payload**: `{ "message": "Hello world!", "sender_id": "your_user_id" }`

### Server to Client Events

*   **`message`**: Broadcasts a new message to all clients in a room.
    *   **Payload**: `{ "username": "sender_username", "message": "Hello world!", "timestamp": "iso_timestamp" }`

---

## How to Test the Application

You can test the backend functionality without a complete frontend.

### 1. Testing the REST API with `curl`

Use `curl` to make authenticated requests to your API.

```bash
# Log in as 'biruk' and list all chats
curl -u biruk:1 http://0.0.0.0:8001/api/chats/
```

### 2. Testing Socket.IO with a Python Client

Create a file named `test_client.py` in your project root and use it to simulate a client.

```python
# test_client.py
import socketio
import time

sio = socketio.Client()

@sio.event
def connect():
    print("✅ Connection established!")
    print("Joining chat room 1 as 'biruk'...")
    sio.emit('join', {'username': 'biruk', 'chat_id': '1'})

@sio.event
def message(data):
    print(f"📩 MESSAGE RECEIVED: {data}")

# Connect to the server
sio.connect('http://localhost:8001')
time.sleep(2)

# Send a test message
print("🚀 Sending a test message...")
sio.emit('send_message', {'message': 'Testing from client script!', 'sender_id': '1'})

# Wait to receive messages
sio.wait()
```

Run this script from a **separate terminal** while your server is running:
```bash
python test_client.py
```
You will see log output in both the server and client terminals, confirming that your real-time backend is working correctly.