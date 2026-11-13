# Firebase Integrated Todo-List App (iOS / SwiftUI)
**Mobile Computing Lab Assignment**

---

## 👨‍🎓 Student Submission Information
- **Student Name:** [Your Full Name]
- **Student ID:** [Your Student ID]
- **Course Title:** Mobile Computing Lab
- **Course Code:** [e.g. CSE-4xx / EEE-4xx]
- **Submission Date:** November 2026

---

## 📱 Project Overview
A fully functional, modern iOS Todo-List application built using **SwiftUI** and **MVVM architecture**, integrated with **Firebase Authentication** and **Cloud Firestore**. 

Each user can securely register, log in, and manage their tasks in real-time. Tasks are isolated per user so every user only sees and modifies their own data.

---

## ✨ Features Checklist
- [x] **Firebase Authentication**:
  - Email & Password Registration with validation (password min length & match check).
  - Secure Sign In & Sign Out with confirmation dialog.
  - Persistent login state using Firebase Auth state listener.
- [x] **Task Structure**:
  - Title & detailed Description for each task.
  - Timestamp (formatted creation date & time).
  - Completion status toggle.
- [x] **Full CRUD Operations**:
  - **Create**: Add new task with title and multi-line description.
  - **Read**: Real-time synchronization via Firestore Snapshot Listener.
  - **Update**: Edit existing task title, description, or toggle completion state with a single tap.
  - **Delete**: Swipe-to-delete or remove via edit menu.
- [x] **Extra UX Features**:
  - **Status Filter**: View All, Pending, or Completed tasks using segmented control.
  - **Live Search**: Real-time search by task title or description keywords.
  - **Modern UI**: Clean SwiftUI cards, SF Symbols, custom empty-state screens, and loading indicators.

---

## 🏗️ Architecture & Project Structure
The project follows the **MVVM (Model - View - ViewModel)** design pattern:

```
FirebaseTodoListApp/
│
├── FirebaseTodoListApp.xcodeproj   # Ready-to-open Xcode Project (with SPM Firebase SDK)
├── Assets.xcassets                 # AppIcon & AccentColor asset catalog
├── FirebaseTodoListApp.swift       # App Entry point (FirebaseApp.configure())
├── GoogleService-Info.plist        # Firebase Configuration File (replace with yours)
├── firestore.rules                 # Cloud Firestore Security Rules
│
├── Models/
│   └── TodoItem.swift              # Codable & Identifiable Todo model
│
├── Services/
│   ├── AuthService.swift           # Firebase Auth wrapper (login, register, signout)
│   └── FirestoreService.swift      # Cloud Firestore CRUD & snapshot listener
│
├── ViewModels/
│   ├── AuthViewModel.swift         # Auth logic, validation & loading states
│   └── TodoViewModel.swift         # Todo business logic, filter, search & CRUD handlers
│
└── Views/
    ├── ContentView.swift           # Root navigation router (Auth vs Todo list)
    ├── Auth/
    │   ├── LoginView.swift         # Sign In screen
    │   └── RegisterView.swift      # Sign Up screen
    └── Todo/
        ├── TodoListView.swift      # Main dashboard with tasks, filter, and search
        ├── TodoRowView.swift       # Single task row with toggle button
        └── AddEditTodoView.swift   # Sheet modal for creating and updating tasks
```

---

## 🚀 Setup & Execution Guide (Xcode / Mac / VMWare)

### Step 1: Firebase Project Setup
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and give it a name (e.g. `TodoList-LabAssignment`).
3. Under **Build > Authentication**:
   - Click **Get Started** and enable the **Email/Password** sign-in provider.
4. Under **Build > Firestore Database**:
   - Click **Create Database** (Start in **Test Mode** or use the rules from `firestore.rules`).
   - Copy the rules from `firestore.rules` into the **Rules** tab and click **Publish**.
5. Add an **iOS App** in Project Settings:
   - Enter Bundle Identifier: `com.student.FirebaseTodoListApp` (or match what you set in Xcode).
   - Download the generated `GoogleService-Info.plist` file.

---

### Step 2: Open and Configure in Xcode
1. Copy the `FirebaseTodoListApp` folder to your Mac / Lab PC / VMware macOS.
2. Double-click **`FirebaseTodoListApp.xcodeproj`** to open it directly in **Xcode**.
3. Xcode will automatically resolve the **Firebase iOS SDK** Swift Package (`FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore` from `https://github.com/firebase/firebase-ios-sdk.git`).
   - If it doesn't start automatically, click **File > Packages > Resolve Package Versions**.
4. Replace the placeholder **`GoogleService-Info.plist`** in the project root with the real `GoogleService-Info.plist` you downloaded from Firebase Console.
5. Select the `FirebaseTodoListApp` target > **Signing & Capabilities** and verify the **Bundle Identifier** matches your Firebase iOS App (`com.student.FirebaseTodoListApp`).

---

### Step 3: Run the App
1. Select an iPhone Simulator (e.g., **iPhone 15 Pro** or **iPhone 16**).
2. Press **Cmd + R** or click the **Play** button to build and run.
3. Register a test account, add a task, edit, search, toggle status, and delete to verify CRUD operations.

---

### Step 4: Push to GitHub for Lab Submission
Run the following terminal commands inside the project directory:

```bash
# Initialize git repository
git init

# Add all project files
git add .

# Initial commit
git commit -m "feat: complete Firebase integrated Todo list app for Mobile Computing lab"

# Create a new repository on GitHub (e.g. mobile-computing-firebase-todo)
# Set your remote origin
git remote add origin https://github.com/<your-username>/<your-repo-name>.git

# Push to main branch
git branch -M main
git push -u origin main
```

Copy your repository URL (e.g. `https://github.com/your-username/mobile-computing-firebase-todo`) and submit it to the assignment submission form!

---

## 🔒 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/todos/{todoId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 💡 Quick Viva / Defense Preparation Questions
1. **Why use MVVM?**
   - Separation of concerns: Views handle UI, ViewModels handle state and business logic, Services handle data fetching/Firebase.
2. **How does real-time sync work?**
   - Firestore's `addSnapshotListener` listens for real-time document change events and updates `@Published var todos`, automatically refreshing SwiftUI views.
3. **How is user data kept isolated?**
   - Every task is stored under the subcollection path `users/{userId}/todos/{todoId}`, enforced by Firestore security rules.
