from django.test import TestCase

# Create your tests here.
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from django.contrib.auth import get_user_model

User = get_user_model()

class ChatAPITests(APITestCase):
    def setUp(self):
        # This method runs before each test.
        # We create two users to test with.
        self.user1 = User.objects.create_user(username='user1', password='password123')
        self.user2 = User.objects.create_user(username='user2', password='password123')

    def test_list_chats_requires_login(self):
        """
        Ensure unauthenticated users cannot access the chat list.
        """
        url = reverse('chat-list') # 'chat-list' is the default name for the ViewSet list view
        response = self.client.get(url)
        # We expect a 401 Unauthorized error because we are not logged in
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_authenticated_user_can_list_chats(self):
        """
        Ensure a logged-in user can successfully access the chat list.
        """
        # Log the test client in as user1
        self.client.login(username='user1', password='password123')
        
        url = reverse('chat-list')
        response = self.client.get(url)
        
        # We expect a 200 OK success response
        self.assertEqual(response.status_code, status.HTTP_200_OK)