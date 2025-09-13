# FeatureVoting iOS App

## Overview
Simple iOS SwiftUI app for testing authentication with the Django backend.

## Features
- ✅ User Registration
- ✅ User Login
- ✅ JWT Token Management
- ✅ Logout Functionality
- ✅ Persistent Authentication State

## Project Structure
```
FeatureVoting/
├── FeatureVoting/
│   ├── App.swift              # Main app entry point
│   ├── Models/
│   │   └── User.swift         # User, Auth models
│   ├── Services/
│   │   └── AuthService.swift  # API communication
│   ├── Views/
│   │   ├── AuthenticationView.swift  # Login/Register forms
│   │   └── DashboardView.swift       # Post-login dashboard
│   └── Info.plist            # App configuration
└── README.md
```

## Setup Instructions

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0 or later
- Django backend running on http://127.0.0.1:8000

### Installation
1. Open Xcode
2. Choose "Create a new Xcode project"
3. Select "iOS" > "App"
4. Configure project:
   - Product Name: `FeatureVoting`
   - Bundle Identifier: `com.example.featurevoting`
   - Language: `Swift`
   - Interface: `SwiftUI`
   - Use Core Data: `No`
5. Replace the generated files with the files in this directory

### Configuration
The app is configured to connect to the Django backend at:
- Base URL: `http://127.0.0.1:8000/api/auth`

To change the backend URL, modify `baseURL` in `Services/AuthService.swift`.

## Testing Guide

### 1. Start the Django Backend
```bash
cd ../backend
source ../.venv/bin/activate
python manage.py runserver 8000
```

### 2. Build and Run iOS App
- Open the project in Xcode
- Select iOS Simulator (iPhone 14 or later)
- Press ⌘+R to build and run

### 3. Test Authentication Flow

#### Registration Test:
1. Tap "Don't have an account? Sign up"
2. Enter:
   - Username: `iosuser`
   - Email: `ios@example.com`
   - Password: `iospass123`
   - Confirm Password: `iospass123`
3. Tap "Sign Up"
4. Should navigate to dashboard showing welcome message

#### Login Test:
1. Logout from dashboard
2. Enter same credentials on login form
3. Tap "Sign In"
4. Should navigate back to dashboard

#### Error Handling Test:
1. Try registering with existing username
2. Try logging in with wrong password
3. Should display appropriate error messages

## App Transport Security
The app is configured to allow HTTP connections to localhost for development. In production, ensure the backend uses HTTPS.

## Next Steps
- Add feature voting UI components
- Implement feature CRUD operations
- Add proper error handling and loading states
- Add unit tests for authentication flow

## Troubleshooting

### Connection Issues
- Ensure Django server is running on port 8000
- Check iOS Simulator can access localhost (should work by default)
- Verify CORS is configured in Django settings

### Authentication Issues
- Check Django logs for API errors
- Verify JSON request/response format matches models
- Ensure JWT tokens are being generated correctly