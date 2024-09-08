from django.urls import path
from django.contrib import admin
from . import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('add/', views.add_invade, name="add_invade"),
    path('', views.index, name="index"),
]