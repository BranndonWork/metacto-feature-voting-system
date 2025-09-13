from django.urls import path
from . import views

urlpatterns = [
    # Features endpoints (plural for collections)
    path('features/', views.FeatureListView.as_view(), name='feature-list'),

    # Feature endpoints (singular for individual resources)
    path('feature/', views.FeatureCreateView.as_view(), name='feature-create'),
    path('feature/<uuid:pk>/', views.FeatureDetailView.as_view(), name='feature-detail'),

    # Voting endpoints
    path('feature/<uuid:pk>/vote/', views.FeatureVoteView.as_view(), name='feature-vote'),
    path('feature/<uuid:pk>/voters/', views.FeatureVotersView.as_view(), name='feature-voters'),
]