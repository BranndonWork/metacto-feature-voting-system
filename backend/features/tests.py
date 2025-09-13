from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APITestCase
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Feature, Vote


class FeatureModelTest(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(username='user1', password='pass123')
        self.user2 = User.objects.create_user(username='user2', password='pass123')
        self.feature = Feature.objects.create(
            title='Test Feature',
            description='Test description',
            author=self.user1
        )

    def test_feature_creation(self):
        self.assertEqual(self.feature.title, 'Test Feature')
        self.assertEqual(self.feature.author, self.user1)
        self.assertIsNotNone(self.feature.id)

    def test_upvote_count_calculation(self):
        # Initially no votes
        self.assertEqual(self.feature.upvote_count, 0)

        # Add upvote
        Vote.objects.create(user=self.user2, feature=self.feature, vote_type='upvote')
        self.assertEqual(self.feature.upvote_count, 1)

    def test_downvote_count_calculation(self):
        # Initially no votes
        self.assertEqual(self.feature.downvote_count, 0)

        # Add downvote
        Vote.objects.create(user=self.user2, feature=self.feature, vote_type='downvote')
        self.assertEqual(self.feature.downvote_count, 1)

    def test_total_score_calculation(self):
        # Add upvote and downvote
        Vote.objects.create(user=self.user2, feature=self.feature, vote_type='upvote')
        Vote.objects.create(user=self.user1, feature=self.feature, vote_type='downvote')

        # Score should be upvotes - downvotes = 1 - 1 = 0
        self.assertEqual(self.feature.total_score, 0)


class VoteModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='user1', password='pass123')
        self.feature = Feature.objects.create(
            title='Test Feature',
            description='Test description',
            author=self.user
        )

    def test_vote_creation(self):
        vote = Vote.objects.create(
            user=self.user,
            feature=self.feature,
            vote_type='upvote'
        )
        self.assertEqual(vote.vote_type, 'upvote')
        self.assertEqual(vote.user, self.user)
        self.assertEqual(vote.feature, self.feature)

    def test_unique_user_feature_constraint(self):
        # Create first vote
        Vote.objects.create(user=self.user, feature=self.feature, vote_type='upvote')

        # Attempt to create duplicate vote should fail
        with self.assertRaises(Exception):
            Vote.objects.create(user=self.user, feature=self.feature, vote_type='downvote')


class FeatureAPITest(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='testuser', password='pass123')
        self.token = RefreshToken.for_user(self.user).access_token
        self.feature = Feature.objects.create(
            title='Test Feature',
            description='Test description',
            author=self.user
        )

    def test_list_features_no_auth_required(self):
        response = self.client.get('/api/features/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_create_feature_requires_auth(self):
        # Without auth
        response = self.client.post('/api/feature/', {
            'title': 'New Feature',
            'description': 'New description'
        })
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_feature_with_auth(self):
        # With auth
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')
        response = self.client.post('/api/feature/', {
            'title': 'New Feature',
            'description': 'New description'
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['title'], 'New Feature')

    def test_vote_toggle_logic(self):
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')

        # Add upvote
        response = self.client.post(f'/api/feature/{self.feature.id}/vote/', {
            'vote_type': 'upvote'
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['action'], 'added')

        # Toggle same vote (should remove)
        response = self.client.post(f'/api/feature/{self.feature.id}/vote/', {
            'vote_type': 'upvote'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['action'], 'removed')

    def test_vote_change_logic(self):
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')

        # Add upvote
        self.client.post(f'/api/feature/{self.feature.id}/vote/', {
            'vote_type': 'upvote'
        })

        # Change to downvote
        response = self.client.post(f'/api/feature/{self.feature.id}/vote/', {
            'vote_type': 'downvote'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['action'], 'changed')

    def test_vote_requires_auth(self):
        # Without auth
        response = self.client.post(f'/api/feature/{self.feature.id}/vote/', {
            'vote_type': 'upvote'
        })
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
