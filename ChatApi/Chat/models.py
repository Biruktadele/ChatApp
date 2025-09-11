from django.db import models
from django.utils import timezone

# Create your models here.

class Chat(models.Model):
    user1_id = models.ForeignKey('core.User', on_delete=models.CASCADE, related_name='user1_chats')
    user2_id = models.ForeignKey('core.User', on_delete=models.CASCADE, related_name='user2_chats')
    last_message = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Chat between {self.user1_id} and {self.user2_id}"
class Message(models.Model):
    chat_id = models.ForeignKey('Chat', on_delete=models.CASCADE, related_name='messages')
    sender_id = models.ForeignKey('core.User', on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        recipient = self.chat_id.user1_id if self.sender_id == self.chat_id.user2_id else self.chat_id.user2_id
        return f"Message {self.id} from {self.sender_id} to {recipient}"
    

# class Room(models.Model):
#     name = models.CharField(max_length=100, unique=True)
#     created_at = models.DateTimeField(auto_now_add=True)

#     def __str__(self):
#         return self.name

# class Message(models.Model):
#     room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='messages')
#     username = models.CharField(max_length=100)
#     content = models.TextField()
#     timestamp = models.DateTimeField(default=timezone.now)

#     class Meta:
#         ordering = ['timestamp']

#     def __str__(self):
#         return f"{self.username} in {self.room.name}: {self.content[:20]}"
