from rest_framework import status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.generics import ListAPIView, CreateAPIView, RetrieveUpdateDestroyAPIView
from django.shortcuts import get_object_or_404
from .models import Feature, Vote
from .serializers import (FeatureSerializer, FeatureListSerializer,
                         VoteSerializer, VoteActionSerializer)


class FeatureListView(ListAPIView):
    """List all features with pagination, sorted by score"""
    queryset = Feature.objects.all().order_by('-id')  # Most recent first, can be changed to score
    serializer_class = FeatureListSerializer
    permission_classes = [permissions.AllowAny]  # Allow public access to view features

    def get_queryset(self):
        queryset = Feature.objects.filter(status='active')

        # Optional: Sort by different criteria (with input validation)
        sort_by = self.request.query_params.get('sort', 'recent')
        if sort_by == 'score':
            # Note: This is not efficiently sortable in DB, would need denormalized score field
            # For now, use Python sorting (not ideal for large datasets)
            # Limit to prevent DoS on large datasets
            features = list(queryset[:100])  # Limit for performance
            features.sort(key=lambda f: f.total_score, reverse=True)
            return features
        elif sort_by == 'recent':
            return queryset.order_by('-created_at')
        else:
            # Default to recent for any invalid sort parameter
            return queryset.order_by('-created_at')


class FeatureCreateView(CreateAPIView):
    """Create a new feature"""
    queryset = Feature.objects.all()
    serializer_class = FeatureSerializer
    permission_classes = [permissions.IsAuthenticated]


class FeatureDetailView(RetrieveUpdateDestroyAPIView):
    """Get, update, or delete a specific feature"""
    queryset = Feature.objects.all()
    serializer_class = FeatureSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        """Allow anyone to view, only authors to update/delete"""
        if self.request.method == 'GET':
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    def perform_destroy(self, instance):
        """Soft delete - only allow authors to delete their own features"""
        if instance.author != self.request.user:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You can only delete your own features.")

        # Soft delete by changing status instead of actually deleting
        instance.status = 'deleted'
        instance.save()

    def update(self, request, *args, **kwargs):
        feature = self.get_object()
        if feature.author != request.user:
            return Response({'error': 'You can only edit your own features'},
                          status=status.HTTP_403_FORBIDDEN)
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        feature = self.get_object()
        if feature.author != request.user:
            return Response({'error': 'You can only delete your own features'},
                          status=status.HTTP_403_FORBIDDEN)
        return super().destroy(request, *args, **kwargs)


class FeatureVoteView(APIView):
    """Handle voting on features"""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        """Toggle or change vote on a feature"""
        feature = get_object_or_404(Feature, pk=pk)
        serializer = VoteActionSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        vote_type = serializer.validated_data['vote_type']
        user = request.user

        try:
            # Check if user has already voted
            existing_vote = Vote.objects.get(user=user, feature=feature)

            if existing_vote.vote_type == vote_type:
                # Same vote type - remove the vote (toggle off)
                existing_vote.delete()
                return Response({
                    'message': f'{vote_type.capitalize()} removed',
                    'action': 'removed',
                    'vote_type': vote_type
                })
            else:
                # Different vote type - change the vote
                existing_vote.vote_type = vote_type
                existing_vote.save()
                return Response({
                    'message': f'Vote changed to {vote_type}',
                    'action': 'changed',
                    'vote_type': vote_type
                })

        except Vote.DoesNotExist:
            # No existing vote - create new vote
            Vote.objects.create(user=user, feature=feature, vote_type=vote_type)
            return Response({
                'message': f'{vote_type.capitalize()} added',
                'action': 'added',
                'vote_type': vote_type
            }, status=status.HTTP_201_CREATED)

    def delete(self, request, pk):
        """Remove user's vote from a feature"""
        feature = get_object_or_404(Feature, pk=pk)
        user = request.user

        try:
            vote = Vote.objects.get(user=user, feature=feature)
            vote_type = vote.vote_type
            vote.delete()
            return Response({
                'message': f'{vote_type.capitalize()} removed',
                'action': 'removed',
                'vote_type': vote_type
            })
        except Vote.DoesNotExist:
            return Response({
                'error': 'You have not voted on this feature'
            }, status=status.HTTP_400_BAD_REQUEST)


class FeatureVotersView(APIView):
    """List users who voted on a feature"""
    permission_classes = [permissions.AllowAny]

    def get(self, request, pk):
        feature = get_object_or_404(Feature, pk=pk)
        votes = Vote.objects.filter(feature=feature)
        serializer = VoteSerializer(votes, many=True)
        return Response({
            'feature_id': str(feature.id),
            'feature_title': feature.title,
            'votes': serializer.data,
            'total_votes': votes.count(),
            'upvotes': votes.filter(vote_type='upvote').count(),
            'downvotes': votes.filter(vote_type='downvote').count()
        })
