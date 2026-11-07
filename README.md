# Sentiment Journal 📔

A Flutter application that allows users to record their daily thoughts, analyze their emotions using AI, and track their emotional trends over time.

 Features

- **User Authentication:** Register and log in securely.
- **Personal Journal:** Create and manage daily journal entries.
- **AI Sentiment Analysis:** Analyze written entries using Google Gemini.
- **Emotion Tracking:** Identify positive, negative, and neutral sentiments.
- **Statistics Dashboard:** Visualize emotional trends and journal activity.
- **Cloud Integration:** Store and synchronize user data using Firebase.
- **Local Storage:** Support local data persistence.

##  Technologies Used

- **Frontend:** Flutter, Dart
- **State Management:** Riverpod
- **Backend Services:** Firebase Authentication, Cloud Firestore
- **AI Integration:** Google Gemini API
- **HTTP Requests:** HTTP package

##  Project Structure

```text
lib/
├── features/
│   ├── auth/
│   ├── journal/
│   ├── profile/
│   ├── shell/
│   └── stats/
├── models/
├── providers/
├── services/
├── widgets/
└── main.dart
```

##  Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- A Firebase project
- A Google Gemini API key

### Installation

1. Clone the repository:

```bash
git clone https://github.com/manel-hattab/sentiment_journal_flutter.git
```

2. Navigate to the project directory:

```bash
cd sentiment_journal_flutter
```

3. Install dependencies:

```bash
flutter pub get
```

4. Configure Firebase for your environment.

5. Configure your Gemini API key securely. Do not commit real API keys to GitHub.

6. Run the application:

```bash
flutter run
```


##  Author

**Manel Hattab**

Data Science Engineering Student

- GitHub: [manel-hattab](https://github.com/manel-hattab)

---

*Developed as a personal project to explore Flutter development, Firebase integration, and AI-powered sentiment analysis.*