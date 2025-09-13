from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APITestCase
from rest_framework import status


class UserAuthenticationTest(APITestCase):
    def test_user_registration_success(self):
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123'
        }
        response = self.client.post('/api/auth/register/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('tokens', response.data)
        self.assertIn('user', response.data)

    def test_user_registration_password_mismatch(self):
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'differentpass'
        }
        response = self.client.post('/api/auth/register/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_registration_duplicate_username(self):
        # Create first user
        User.objects.create_user(username='testuser', password='pass123')

        # Try to create user with same username
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123'
        }
        response = self.client.post('/api/auth/register/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_login_success(self):
        # Create user
        user = User.objects.create_user(username='testuser', password='testpass123')

        # Login
        data = {
            'username': 'testuser',
            'password': 'testpass123'
        }
        response = self.client.post('/api/auth/login/', data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)
        self.assertIn('user', response.data)

    def test_user_login_invalid_credentials(self):
        # Create user
        user = User.objects.create_user(username='testuser', password='testpass123')

        # Login with wrong password
        data = {
            'username': 'testuser',
            'password': 'wrongpass'
        }
        response = self.client.post('/api/auth/login/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_login_missing_credentials(self):
        # Login without password
        data = {
            'username': 'testuser'
        }
        response = self.client.post('/api/auth/login/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_jwt_token_structure(self):
        # Register user and check token structure
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123'
        }
        response = self.client.post('/api/auth/register/', data)

        tokens = response.data['tokens']
        self.assertIn('access', tokens)
        self.assertIn('refresh', tokens)
        self.assertIsInstance(tokens['access'], str)
        self.assertIsInstance(tokens['refresh'], str)
