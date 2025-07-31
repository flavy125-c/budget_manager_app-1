# 💸 Budget Manager App

A mobile application built with **Flutter** and **Firebase** that helps users manage their daily and monthly expenses. The app supports user authentication, adding/viewing/editing expenses, setting category-based budgets, and getting visual summaries of monthly spending.

---

## ✨ Features

- ✅ **User Registration and Login** (with Firebase Authentication)
- ✅ **Add Expenses** by category, date, and amount
- ✅ **View Expense History** with ability to edit/delete
- ✅ **Budget Warning System** when you exceed your set budget per category
- ✅ **Monthly Summary** by categories
- ✅ **Real-time Updates** using Firebase Cloud Firestore
- ✅ **Responsive UI** for Android/Web
- ✅ **Success/Error Notifications** after every action

---

## 🛠️ Tech Stack

| Tool/Tech         | Usage                          |
|------------------|---------------------------------|
| Flutter           | Cross-platform app UI           |
| Firebase Auth     | User login & registration       |
| Firebase Firestore| Cloud NoSQL database            |
| Provider (optional) | State management              |

---

## 🧪 How to Run the App Locally

### 🔧 Prerequisites
- Flutter SDK installed
- A Firebase project created
- VS Code / Android Studio

### 🔌 Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Email/Password Authentication**
4. Create Firestore DB (start in test mode)
5. Add Web or Android app:
   - Copy the `firebaseOptions` to your `main.dart`

### 🧬 Clone & Run
```bash
git clone https://github.com/your-username/budget-manager.git
cd budget-manager
flutter pub get
flutter run


*folder structure*

lib/
│
├── screens/
│   ├── add_expense_screen.dart
│   ├── view_expenses_screen.dart
│   ├── summary_screen.dart
│   ├── home_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── widgets/
│       └── auth_wrapper.dart
├── main.dart



## 🙋 About Me

**Name:** Flavian Simon  
**Email:** up2249816@example.com  
**GitHub:** [flavy125-c]


