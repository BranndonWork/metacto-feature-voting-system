#!/bin/bash

echo "Running migrations..."
python manage.py migrate

echo "Creating superuser if it does not exist..."
python manage.py shell -c "
from django.contrib.auth.models import User
from decouple import config
username = config('DJANGO_SUPERUSER_USERNAME', default='admin')
email = config('DJANGO_SUPERUSER_EMAIL', default='admin@example.com')
password = config('DJANGO_SUPERUSER_PASSWORD', default='admin123')
if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password)
    print(f'Superuser {username} created successfully')
else:
    print(f'Superuser {username} already exists')
"

echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000