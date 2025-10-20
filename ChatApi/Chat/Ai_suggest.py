from google import genai
import django
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ChatApi.settings")
django.setup()
from dotenv import load_dotenv

from Chat.models import *
from core.models import *

load_dotenv()  
def generate_smart_replies(chat_id, user_id):
    client = genai.Client(api_key=os.getenv("GOOGLE_API_KEY"))
    convo = Message.objects.order_by('-id')[:10][::-1]  # Get last 10 messages, oldest to newest

    context = ""
    for message in convo:
        context += f"{message.sender_id.username} ({getattr(message.sender_id, 'gender', 'unknown')}): {message.content}\n"

    # Get user gender (assuming user_id is a User object or pk)

    user = User.objects.get(pk=user_id) if not hasattr(user_id, 'gender') else user_id
    user_gender = getattr(user, 'gender', 'unknown')

    # Optionally, get the gender of the person to reply to (last message sender)
    reply_to_gender = getattr(convo[-1].sender_id, 'gender', 'unknown') if convo else 'unknown'

    if user_gender != reply_to_gender:
        prompt = (
            f"Here is the recent chat history:\n{context}\n"
            f"My gender is {user_gender}. The person I want to reply to is {reply_to_gender}. "
            "If our genders are different, suggest 3 playful, lighthearted, and flirty replies I could say. "
            "If our genders are the same, suggest 3 friendly or formal replies. "
            "Reply in JSON format with keys suggestion1, suggestion2, suggestion3."
        )
    else:
        prompt = (
            f"Here is the recent chat history:\n{context}\n"
            f"My gender is {user_gender}. The person I want to reply to is {reply_to_gender}. "
            "Suggest 3 friendly or formal replies I could say. "
            "Reply in JSON format with keys suggestion1, suggestion2, suggestion3."
        )

    try:
        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents=prompt
        )
        return response.text
    except Exception as e:
        response = {
            "suggestion1": "hi",
            "suggestion2": "how u doin",
            "suggestion3": "u there?",
        }
        return response
