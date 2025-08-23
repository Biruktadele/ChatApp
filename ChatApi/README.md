# Chat Application

A real-time chat application built with Django, Django REST Framework, and WebSockets.

## Features

### Authentication
- User registration with email/password
- Google OAuth2 login
- Password reset functionality
- User profile management

### Chats
- One-to-one chat between users
- Chat list with last message preview
- Delete chat functionality

### Messages
- Send and receive messages
- Update and delete messages
- Message read status

## Prerequisites

- Python 3.8+
- PostgreSQL
- Cloudinary account (for file storage)
- Google OAuth2 credentials

## Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/biruktadel/ChatApp.git
cd ChatApp/ChatApi
```

### 2. Create and activate virtual environment
```bash
python -m venv venv
# On Windows
.\venv\Scripts\activate
# On Unix or MacOS
source venv/bin/activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Environment Variables
Create a `.env` file in the project root with the following variables:
```
SECRET_KEY=your-secret-key
DEBUG=True
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=localhost
DB_PORT=5432

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Google OAuth2
GOOGLE_OAUTH2_CLIENT_ID=your_client_id
GOOGLE_OAUTH2_CLIENT_SECRET=your_client_secret
```

### 5. Database Setup
1. Create a PostgreSQL database
2. Run migrations:
```bash
python manage.py migrate
```

### 6. Create Superuser
```bash
python manage.py createsuperuser
```

### 7. Run the Development Server
```bash
python manage.py runserver
```

## API Endpoints

### Authentication
- `POST /api/auth/register/` - Register a new user
- `POST /api/auth/login/` - Login with email/password
- `POST /api/auth/logout/` - Logout
- `POST /api/auth/password/reset/` - Request password reset
- `POST /api/auth/password/reset/confirm/` - Confirm password reset
- `GET /api/auth/google/` - Google OAuth2 login

### Users
- `GET /api/users/` - List all users (admin only)
- `GET /api/users/me/` - Get current user profile
- `PUT /api/users/me/` - Update current user profile
- `GET /api/users/{id}/` - Get user details

### Chats
- `GET /api/chats/` - List user's chats
- `POST /api/chats/` - Create a new chat
- `GET /api/chats/{chat_id}/` - Get chat details
- `DELETE /api/chats/{chat_id}/` - Delete a chat

### Messages
- `GET /api/chats/{chat_id}/messages/` - Get chat messages
- `POST /api/chats/{chat_id}/messages/` - Send a message
- `PUT /api/chats/{chat_id}/messages/{message_id}/` - Update a message
- `DELETE /api/chats/{chat_id}/messages/{message_id}/` - Delete a message


## Environment
- Python 3.8+
- Django 4.2
- Django REST Framework 3.14
- Django Channels 4.0
- PostgreSQL 13+
- Cloudinary for file storage

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details
