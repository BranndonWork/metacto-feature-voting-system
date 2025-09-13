# Feature Voting System - Implementation Plan

## 📋 Project Overview
Build a Feature Voting System that allows users to post features and upvote/downvote others' features, demonstrating AI-assisted development capabilities aligned with MetaCTO's tech stack.

## 🎯 Key Requirements
- **Database**: SQLite (simplified from PostgreSQL)
- **Backend API**: Django REST Framework with JWT authentication
- **Mobile UI**: iOS app using SwiftUI (aligns with MetaCTO's tech)
- **Deployment**: Docker Compose for one-command startup
- **Time**: 90-150 minutes
- **Development**: Test-Driven Development (TDD) approach

## 🏗️ Architecture

### System Components
```
┌─────────────────┐     ┌──────────────────┐
│   iOS App       │────▶│  Django Backend  │
│   (SwiftUI)     │◀────│  (REST API)      │
└─────────────────┘     └──────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │  SQLite Database │
                        └──────────────────┘
```

### Tech Stack Selection
- **Backend**: Django (latest) + Django REST Framework (DRF)
- **Auth**: djangorestframework-simplejwt
- **Database**: SQLite (dev-friendly, no setup)
- **Mobile**: iOS with SwiftUI
- **Container**: Docker + Docker Compose
- **API**: RESTful with JSON responses
- **Config**: Environment variables via .env files

## 📁 Project Structure
```
feature-voting-system/
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── .env.example
│   ├── config/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── features/
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   └── tests.py
│   └── users/
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       └── tests.py
├── mobile/
│   └── FeatureVoting/
│       ├── FeatureVoting.xcodeproj
│       └── FeatureVoting/
│           ├── Models/
│           ├── Views/
│           ├── Services/
│           └── App.swift
├── docker-compose.yml
├── .env
├── README.md
├── IMPLEMENTATION.md
└── prompts.txt
```

## 💾 Database Schema

### Models
1. **User** (Django's built-in + custom fields)
   - id: UUID
   - username: String
   - email: String
   - created_at: DateTime

2. **Feature**
   - id: UUID
   - title: String (max 200)
   - description: Text
   - author: ForeignKey(User)
   - created_at: DateTime
   - updated_at: DateTime
   - Properties:
     - upvote_count: Count of upvotes via related Vote model
     - downvote_count: Count of downvotes via related Vote model
     - total_score: upvote_count - downvote_count

3. **Vote**
   - id: UUID
   - user: ForeignKey(User)
   - feature: ForeignKey(Feature)
   - vote_type: CharField (choices: 'upvote', 'downvote')
   - created_at: DateTime
   - updated_at: DateTime
   - unique_together: (user, feature)

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - Login (returns JWT tokens)
- `POST /api/auth/refresh/` - Refresh access token

### Features (Multiple)
- `GET /api/features/` - List all features (paginated, sorted by score)
- `GET /api/features/top/` - Top voted features
- `GET /api/features/recent/` - Recently added features

### Feature (Single)
- `POST /api/feature/` - Create new feature (auth required)
- `GET /api/feature/{id}/` - Get feature details
- `PUT /api/feature/{id}/` - Update own feature (auth required)
- `DELETE /api/feature/{id}/` - Delete own feature (auth required)

### Voting
- `POST /api/feature/{id}/vote/` - Vote on feature (auth required)
  - Body: `{"vote_type": "upvote|downvote"}`
  - Toggles vote if same type, changes if different type
- `DELETE /api/feature/{id}/vote/` - Remove vote (auth required)
- `GET /api/feature/{id}/voters/` - List users who voted

## 📱 Mobile App Features

### Core Screens
1. **Login/Register** - JWT auth flow
2. **Feature List** - Browse all features, sorted by score
3. **Add Feature** - Form to submit new feature
4. **Feature Detail** - View details, vote up/down

### UI Components
- SwiftUI native components
- Simple, functional design (no complex styling)
- Focus on UX flow over aesthetics
- Vote buttons with count display

## 🐳 Docker Configuration

### Environment Variables (.env)
```
DEBUG=True
SECRET_KEY=dev-secret-key-change-in-production
DATABASE_URL=sqlite:///db.sqlite3
DJANGO_HOST=0.0.0.0
DJANGO_PORT=8000
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@example.com
DJANGO_SUPERUSER_PASSWORD=admin123
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

### docker-compose.yml
```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "${DJANGO_PORT:-8000}:8000"
    volumes:
      - ./backend:/app
      - db_data:/app/db
    env_file:
      - .env
    environment:
      - PYTHONUNBUFFERED=1
volumes:
  db_data:
```

## 🚀 Implementation Steps

### Phase 1: Backend Setup (30 min)
1. **Initialize Django project** using `django-admin startproject`
2. **Create apps** using `python manage.py startapp features` and `python manage.py startapp users`
3. **Configure settings.py** to read from environment variables
4. **Set up requirements.txt** with latest Django, DRF, JWT, python-decouple
5. **Create initial migrations** using `python manage.py makemigrations`

### Phase 2: Test-Driven Development (45 min)
1. **Write model tests** for Feature, Vote relationships
2. **Write API endpoint tests** for authentication, CRUD operations
3. **Write vote logic tests** for upvote/downvote toggle behavior
4. **Implement models** to pass model tests
5. **Implement serializers and views** to pass API tests
6. **Implement vote logic** to pass voting tests

### Phase 3: API Development (30 min)
1. **Configure JWT authentication** in settings
2. **Set up URL routing** for feature vs features endpoints
3. **Add pagination and sorting** to features list
4. **Implement vote toggle logic** with proper state management
5. **Add CORS configuration** for mobile app communication

### Phase 4: Mobile App (45 min)
1. **Create Xcode project** using `xcodebuild` commands where possible
2. **Implement API service layer** with URLSession
3. **Build authentication flow** with JWT token management
4. **Create feature list view** with vote counts
5. **Add upvote/downvote functionality** with immediate UI feedback
6. **Implement add feature form** with validation

### Phase 5: Docker & Testing (30 min)
1. **Write Dockerfile** for Django backend
2. **Create docker-compose.yml** with environment variable support
3. **Add entrypoint script** for migrations and superuser creation
4. **Test full flow** end-to-end with `docker-compose up -d`
5. **Verify all tests pass** in containerized environment

### Phase 6: Documentation (15 min)
1. **Update README** with setup and API documentation
2. **Create .env.example** with all required variables
3. **Document known limitations** and future improvements
4. **Export and organize prompts** used during development

## 🎨 Key Design Decisions

### Why These Choices?
- **Django + DRF**: Aligns with MetaCTO's stack, rapid development
- **JWT over Sessions**: Stateless, mobile-friendly
- **SQLite**: Zero config for demo, easily swappable
- **SwiftUI**: Modern iOS framework MetaCTO uses
- **Docker Compose**: Single command startup as required
- **TDD Approach**: Ensures reliability and demonstrates testing skills
- **.env Configuration**: Production-ready environment management

### Vote System Design
- **Single Vote per User**: Users can upvote OR downvote, not both
- **Vote Toggle**: Clicking same vote type removes vote
- **Vote Change**: Clicking different vote type changes vote
- **Real-time Counts**: Vote counts calculated via database relationships
- **Score Calculation**: total_score = upvotes - downvotes

### API Design Decisions
- **Singular vs Plural**: `/api/feature/` for single operations, `/api/features/` for collections
- **Nested Voting**: Vote endpoints nested under feature for clarity
- **Pagination**: Features endpoint paginated for performance
- **Filtering**: Support for top/recent feature filtering

## ✅ Success Criteria
- [x] User can register and login via mobile app
- [x] User can post a new feature via mobile app
- [x] User can view all features with vote counts
- [x] User can upvote and downvote features
- [x] Vote counts update immediately in UI
- [x] Docker compose starts everything with `docker-compose up -d`
- [x] All tests pass in containerized environment
- [x] API fully documented and testable

## 🔍 Edge Cases to Handle
1. **Vote Conflicts**: Prevent multiple votes from same user
2. **Feature Deletion**: Handle vote cleanup when feature deleted
3. **JWT Expiry**: Auto-refresh tokens in mobile app
4. **Network Errors**: Retry logic and offline state handling
5. **Empty States**: Proper messaging when no features exist
6. **Vote Toggle Logic**: Ensure consistent state between client/server
7. **Race Conditions**: Handle concurrent vote submissions

## 🧪 Test Strategy

### Backend Tests
```python
# Example test structure
class FeatureModelTest(TestCase):
    def test_feature_upvote_count_calculation(self):
        # Test vote count properties work correctly
        pass

    def test_vote_toggle_logic(self):
        # Test vote state changes properly
        pass

class FeatureAPITest(APITestCase):
    def test_create_feature_requires_auth(self):
        # Test authentication requirements
        pass

    def test_vote_endpoint_toggle_behavior(self):
        # Test API vote toggle functionality
        pass
```

### Mobile Tests
- Unit tests for API service layer
- UI tests for voting flow
- Integration tests for auth flow

## 📝 Deliverables
1. **Working Django backend** with comprehensive API
2. **iOS app** with full voting functionality
3. **Docker setup** for single-command deployment
4. **Test suite** with >90% coverage
5. **Documentation** including API specs and setup guide
6. **Prompt audit trail** demonstrating AI collaboration process

## 🔧 Development Commands

### Project Setup
```bash
# Backend setup
django-admin startproject config backend
cd backend
python manage.py startapp features
python manage.py startapp users

# Dependencies
pip install django djangorestframework djangorestframework-simplejwt python-decouple django-cors-headers

# Database
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser

# Testing
python manage.py test
```

### Docker Commands
```bash
# Build and start
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Run tests in container
docker-compose exec backend python manage.py test
```

Ready to begin test-driven implementation starting with the Django backend setup and basic test cases.