# Firebase Flutter Notification App

| Name                     | NRP        | Class                              |
| ------------------------ | ---------- | ---------------------------------- |
| Ainun Nadhifah Syamsiyah | 5025221053 | Pemrograman Perangkat Bergerak (C) |

## Overview

A Flutter application that demonstrates integration between Firebase Authentication, Firestore, and local notifications. The app provides a complete authentication flow with user management and a notes system, enhanced with real-time notifications.

You can view the application demo video [here](https://youtu.be/cCjFELIln7Q).

## Features

### Authentication

- Email/Password authentication using Firebase Auth
- User registration and login
- Password reset functionality
- Secure session management
- Welcome notifications upon successful login
- Logout notifications

### Notes Management

- Create, read, update, and delete notes
- Real-time synchronization with Firestore
- Automatic notifications for note actions:
  - Note creation
  - Note updates
  - Note deletion

### Notifications

- Local notifications using Awesome Notifications
- Custom notification channels
- Notification permissions handling
- Interactive notifications with payload support
- Notification actions and navigation

## Technical Implementation

### Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Data classes for User and Notes
- **Views**: Flutter widgets for UI components
- **ViewModels**: Business logic and state management using Provider

### Key Components

#### Authentication (`lib/viewmodels/auth_viewmodel.dart`)

- Manages user authentication state
- Handles sign-in, sign-up, and sign-out operations
- Integrates with Firebase Auth
- Manages welcome notifications

#### Notes Management (`lib/viewmodels/notes_viewmodel.dart`)

- CRUD operations for notes
- Real-time data synchronization
- Notification integration for note actions
- Error handling and state management

#### Notification Service (`lib/services/notification.dart`)

- Initializes and configures Awesome Notifications
- Manages notification channels and permissions
- Handles notification creation and actions
- Provides a clean API for notification management

#### Firestore Service (`lib/services/firestore.dart`)

- Manages Firestore database operations
- Provides real-time data streams
- Handles CRUD operations for notes

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase project
- Android Studio / VS Code
- Git

### Setup

1. Clone the repository
2. Create a Firebase project and add your configuration
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Dependencies

- `firebase_core`: Firebase core functionality
- `firebase_auth`: Firebase Authentication
- `cloud_firestore`: Firestore database
- `awesome_notifications`: Local notifications
- `provider`: State management
- `flutter`: UI framework

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── user.dart            # User model
│   └── note.dart            # Note model
├── services/
│   ├── firestore.dart       # Firestore service
│   └── notification.dart    # Notification service
├── viewmodels/
│   ├── auth_viewmodel.dart  # Authentication logic
│   └── notes_viewmodel.dart # Notes management logic
└── views/
    ├── login_page.dart      # Login screen
    ├── register_page.dart   # Registration screen
    ├── home_page.dart       # Main app screen
    ├── notes_page.dart      # Notes management screen
    └── account_page.dart    # User account screen
```
