# your_project/urls.py

from Chat import views
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from core.views import RegisterView

# General URLs for your project, including API and potentially your frontend if it's Django-based
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('Chat.urls')),
    path("accounts/", include("allauth.urls")),
    path("api/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path('api/signup/', RegisterView.as_view(), name='signup')
    # path('', views.login_view, name='login'),
    # path('chat/<int:chatid>/', views.chat_view, name='chat'),
]
# if settings.DEBUG:
#     urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)