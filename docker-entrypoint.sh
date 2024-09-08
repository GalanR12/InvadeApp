#!/bin/bash

# allow CSRF for HTTP requests (example: "https://invadeapp.azurewebsites.net")
export CSRF_TRUSTED_ORIGINS_PATH=https://invadeapp.azurewebsites.net

# collect static files
python manage.py collectstatic

# database settings
python manage.py makemigrations invade_app
python manage.py migrate

# run application
python manage.py runserver 0.0.0.0:8000
