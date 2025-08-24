# your_project/urls.py

from django.contrib import admin
from django.urls import path, include


# General URLs for your project, including API and potentially your frontend if it's Django-based
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('Chat.urls')),
]
