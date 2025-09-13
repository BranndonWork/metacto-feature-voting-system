# iOS App Setup with Xcode

## ✅ **Directory Structure Cleaned & Ready**

The mobile directory structure has been cleaned up and prepared for Xcode project creation:

```
feature-voting-system/
├── mobile/              ← Create Xcode project HERE
│   └── README.md
├── ios-source-files/    ← Pre-built SwiftUI code to copy over
│   ├── App.swift
│   ├── Info.plist
│   ├── Models/
│   │   └── User.swift
│   ├── Services/
│   │   └── AuthService.swift
│   └── Views/
│       ├── AuthenticationView.swift
│       └── DashboardView.swift
└── backend/             ← Django API running on Docker
```

---

## 📱 **Xcode Project Setup Instructions**

### Step 1: Create New Xcode Project
1. **Open Xcode**
2. **File → New → Project**
3. **Choose**: iOS → App
4. **Configure Project**:
   - **Product Name**: `FeatureVoting`
   - **Bundle Identifier**: `com.example.featurevoting`
   - **Language**: `Swift`
   - **Interface**: `SwiftUI`
   - **Use Core Data**: `No`
   - **Include Tests**: `Yes` (optional)

### Step 2: Save Location
- **Save to**: `feature-voting-system/mobile/`
- This will create: `feature-voting-system/mobile/FeatureVoting/`

### Step 3: Replace Generated Files
Once Xcode creates the project, replace the generated files:

```bash
# Navigate to the project
cd feature-voting-system/

# Copy our pre-built SwiftUI files over the generated ones
cp ios-source-files/App.swift mobile/FeatureVoting/FeatureVoting/
cp ios-source-files/Info.plist mobile/FeatureVoting/FeatureVoting/
cp -r ios-source-files/Models mobile/FeatureVoting/FeatureVoting/
cp -r ios-source-files/Services mobile/FeatureVoting/FeatureVoting/
cp -r ios-source-files/Views mobile/FeatureVoting/FeatureVoting/
```

### Step 4: Add Files to Xcode Project
1. In Xcode, **right-click** on the `FeatureVoting` group
2. **Add Files to "FeatureVoting"**
3. Select the `Models`, `Services`, and `Views` folders
4. Ensure **"Add to target"** is checked for `FeatureVoting`

### Step 5: Build & Run
1. **Select target**: iPhone 15 Pro Simulator
2. **Press**: ⌘+R (or Product → Run)
3. **Test the app**: Registration → Login → Logout flow

---

## 🔧 **Troubleshooting**

### If Build Fails:
- Check that all files are added to the target
- Verify iOS Deployment Target is set to 16.0 or later
- Clean build folder: Product → Clean Build Folder

### If Network Requests Fail:
- Ensure Django backend is running: `docker-compose up -d`
- Check backend is accessible at: http://127.0.0.1:8000/api/features/
- Verify iOS Simulator can access localhost (should work by default)

---

## 🎯 **Expected Workflow**

1. **Launch iOS app** in simulator
2. **Tap "Sign Up"** → Enter username, email, password
3. **Registration succeeds** → Navigate to dashboard
4. **Tap "Logout"** → Return to login screen
5. **Tap "Sign In"** → Enter same credentials
6. **Login succeeds** → Navigate to dashboard
7. **Dashboard shows**: Welcome message + user info

---

## 📁 **Final Project Structure**

After setup, you'll have:
```
feature-voting-system/
├── mobile/
│   └── FeatureVoting/           ← Xcode project
│       ├── FeatureVoting.xcodeproj
│       └── FeatureVoting/       ← App source code
│           ├── App.swift
│           ├── Info.plist
│           ├── Models/
│           ├── Services/
│           └── Views/
├── ios-source-files/            ← Can delete after setup
└── backend/                     ← Django API
```

**Ready to create the Xcode project! The mobile/ directory is clean and prepared.**