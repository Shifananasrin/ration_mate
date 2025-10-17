from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),  
 ] # 👈 make sure this line exis
from django.urls import path, include  # include is needed for app URLs

urlpatterns = [
    path('admin/', admin.site.urls),         # Admin panel
    path('api/', include('api.urls')),       # Your API app URLs
]
