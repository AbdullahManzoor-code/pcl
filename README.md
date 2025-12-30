# Programming Learning App

A modern Flutter application for interactive programming learning, built with **GetX Clean Architecture**.

## 🚀 Features

### 1️⃣ Authentication

- **Login/Register**: Secure forms with validation.
- **Social Login**: Google and GitHub integration (Mock).
- **State Management**: `AuthController` handles efficient state changes.

### 2️⃣ Home Hub (Dashboard)

- **Stats Overview**: Track consecutive study days, hours, and courses.
- **Course Lists**: Separate sections for "Current Study" and "Recommended".
- **Daily Progress**: Visual progress bar for daily goals.

### 3️⃣ Learning Flow

- **Course Details**: View syllabus/topics for a specific course.
- **Topic Locking**: Topics unlock based on previous quiz scores (Server Logic).
- **Learning View**: Educational content and interactive quizzes.

### 4️⃣ Profile & Settings

- **Profile**: View user avatar and details.
- **Settings**: Placeholder for privacy and notification settings.

### 5️⃣ Mock API

- **Data Service**: Centralized `MockApiService` simulates backend responses for users, courses, and evaluation.

## 🏗️ Architecture

The project follows **GetX Clean Architecture**:

```
lib/
├── app/
│   ├── data/                 # Data Layer (Services, Models)
│   ├── modules/              # Feature modules (View, Controller, Binding)
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── course_details/
│   │   ├── learning/
│   │   ├── profile/
│   │   └── ...
│   ├── routes/               # Navigation management
│   └── core/                 # Shared resources (Theme, Utils)
└── main.dart                 # App Entry Point
```

## 🛠️ Tech Stack

- **Flutter**: UI Framework
- **GetX**: State Management, DI, Navigation
- **Google Fonts**: Typography

## 📦 How to Run

1. `flutter pub get`
2. `flutter run`
