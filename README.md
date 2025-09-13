# Feature Voting System

A complete full-stack feature voting application built for the MetaCTO Tech Lead interview challenge. Users can post feature requests and vote on others' suggestions.

## 🚀 Quick Start

### Prerequisites
- macOS with Xcode installed (for iOS app)
- Docker & Docker Compose

### Setup (One Command)
```bash
docker-compose up -d
```

### Run iOS App
1. Open Xcode
2. Open `mobile/FeatureVoting/FeatureVoting.xcodeproj`
3. Build & Run (`Cmd + R`)

## 📱 Features Complete

### Core Functionality ✅
- User registration and login
- Post new feature requests
- Upvote/downvote features
- Real-time vote counts
- Feature author permissions (delete own features)
- Soft deletion (features marked as deleted, not removed)

### Mobile UX ✅
- Pull-to-refresh
- Visual vote feedback (green upvote, red downvote)
- Auto-upvote new features by creator
- Authentication on-demand (browse without login)
- Enter key form submission
- Trash icon for feature deletion

## 🔧 API Endpoints

```
POST /api/auth/register/     - User registration
POST /api/auth/login/        - Login (returns JWT)

GET  /api/features/          - List all active features
POST /api/feature/           - Create feature
DELETE /api/feature/{id}/    - Delete own feature (soft delete)

POST /api/feature/{id}/vote/ - Vote on feature
```

## 🏗️ Architecture

- **Backend**: Django REST Framework with JWT authentication
- **Database**: SQLite with soft deletion support
- **Mobile**: iOS app with SwiftUI
- **Deployment**: Docker Compose

## 🧪 Testing

### Backend Tests (19 comprehensive tests passing)
```bash
cd backend
python manage.py test
```

### Manual Testing Completed ✅
- Full authentication flow (register, login, logout)
- Feature creation with auto-upvote
- Vote visualization with color feedback
- Delete functionality with permissions
- Pull-to-refresh with task cancellation handling
- Error handling for network issues

## 📁 Project Structure

```
feature-voting-system/
├── backend/                 # Django REST API
│   ├── features/           # Core voting logic with soft deletion
│   ├── config/             # Django settings
│   └── requirements.txt
├── mobile/FeatureVoting/   # iOS SwiftUI app
│   ├── Models/             # Data models (User, Feature, Author)
│   ├── Services/           # API communication (AuthService, FeatureService)
│   └── Views/              # SwiftUI screens (MainView, FeatureListView, etc)
├── docker-compose.yml      # One-command deployment
├── .env                    # Environment config (dev values with warnings)
├── prompts.txt            # Complete AI development audit trail (40 prompts)
└── IMPLEMENTATION.md      # Detailed technical plan
```

## 🔒 Environment Variables

The included `.env` file contains development values with security warnings:
```bash
# WARNING: These are development values only - never use in production!
SECRET_KEY=dev-feature-voting-system-key-change-in-production-2025
DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
```

## 🎯 Interview Challenge Completed

This project demonstrates:
- **AI-Assisted Development**: Complete audit trail in `prompts.txt` (40 prompts)
- **Full-Stack Engineering**: Django backend + native iOS frontend
- **System Design**: RESTful API, JWT auth, proper data modeling
- **DevOps**: Docker containerization for easy deployment
- **Testing**: Comprehensive test suite covering models and APIs
- **Mobile Development**: SwiftUI with modern iOS patterns
- **Problem Solving**: Handled multiple technical challenges and edge cases

## ⚡ Key Technical Features

### Backend
- JWT authentication with token refresh
- Vote toggle logic (same vote removes, different changes)
- Soft deletion with status filtering
- Input validation and security checks
- Comprehensive test coverage (19 tests)

### iOS App
- SwiftUI with proper MVVM architecture
- Pull-to-refresh functionality
- Task cancellation for network requests
- Visual vote feedback with color coding
- Authentication on-demand UX pattern
- Auto-upvote for feature creators

---

**Built with ❤️ and AI assistance for MetaCTO interview challenge**
**Development Time**: ~2.5 hours
**Status**: Complete and functional POC