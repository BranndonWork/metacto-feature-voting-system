from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Feature, Vote


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username')


class FeatureSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    upvote_count = serializers.ReadOnlyField()
    downvote_count = serializers.ReadOnlyField()
    total_score = serializers.ReadOnlyField()
    user_vote = serializers.SerializerMethodField()

    class Meta:
        model = Feature
        fields = ('id', 'title', 'description', 'author', 'created_at',
                 'updated_at', 'upvote_count', 'downvote_count', 'total_score', 'user_vote')
        read_only_fields = ('id', 'created_at', 'updated_at')

    def validate_description(self, value):
        """Limit description length to prevent abuse"""
        if len(value) > 1000:
            raise serializers.ValidationError("Description cannot exceed 1000 characters")
        return value

    def get_user_vote(self, obj):
        """Return the current user's vote on this feature, if any"""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                vote = Vote.objects.get(user=request.user, feature=obj)
                return vote.vote_type
            except Vote.DoesNotExist:
                return None
        return None

    def create(self, validated_data):
        validated_data['author'] = self.context['request'].user
        feature = super().create(validated_data)

        # Automatically upvote the feature by its creator
        from .models import Vote
        Vote.objects.create(
            user=self.context['request'].user,
            feature=feature,
            vote_type='upvote'
        )

        return feature


class FeatureListSerializer(serializers.ModelSerializer):
    """Simplified serializer for feature lists"""
    author = UserSerializer(read_only=True)
    upvote_count = serializers.ReadOnlyField()
    downvote_count = serializers.ReadOnlyField()
    total_score = serializers.ReadOnlyField()
    user_vote = serializers.SerializerMethodField()

    class Meta:
        model = Feature
        fields = ('id', 'title', 'description', 'author', 'created_at', 'upvote_count',
                 'downvote_count', 'total_score', 'user_vote')

    def get_user_vote(self, obj):
        """Return the current user's vote on this feature, if any"""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                vote = Vote.objects.get(user=request.user, feature=obj)
                return vote.vote_type
            except Vote.DoesNotExist:
                return None
        return None


class VoteSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    feature = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Vote
        fields = ('id', 'user', 'feature', 'vote_type', 'created_at')
        read_only_fields = ('id', 'created_at')

    def validate_vote_type(self, value):
        if value not in ['upvote', 'downvote']:
            raise serializers.ValidationError("Vote type must be 'upvote' or 'downvote'")
        return value


class VoteActionSerializer(serializers.Serializer):
    """Serializer for vote toggle actions"""
    vote_type = serializers.ChoiceField(choices=['upvote', 'downvote'])

    def validate_vote_type(self, value):
        if value not in ['upvote', 'downvote']:
            raise serializers.ValidationError("Vote type must be 'upvote' or 'downvote'")
        return value