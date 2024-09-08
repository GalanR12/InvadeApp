from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('', include('invade_app.urls'))
]
