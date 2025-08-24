from rest_framework_nested import routers
from .views import ChatViewSet , MessageViewSet
from core.views import UserViewSet


router = routers.DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'chats', ChatViewSet)

nested_router = routers.NestedDefaultRouter(router, r'chats', lookup='chat')
nested_router.register(r'messages', MessageViewSet, basename='chat-messages')

urlpatterns = router.urls + nested_router.urls
