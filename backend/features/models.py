from django.db import models
from django.contrib.auth.models import User
import uuid


class Feature(models.Model):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('deleted', 'Deleted'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200)
    description = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='features')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title

    @property
    def upvote_count(self):
        return self.votes.filter(vote_type='upvote').count()

    @property
    def downvote_count(self):
        return self.votes.filter(vote_type='downvote').count()

    @property
    def total_score(self):
        return self.upvote_count - self.downvote_count


class Vote(models.Model):
    VOTE_CHOICES = [
        ('upvote', 'Upvote'),
        ('downvote', 'Downvote'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='votes')
    feature = models.ForeignKey(Feature, on_delete=models.CASCADE, related_name='votes')
    vote_type = models.CharField(max_length=10, choices=VOTE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'feature')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.vote_type} - {self.feature.title}"
