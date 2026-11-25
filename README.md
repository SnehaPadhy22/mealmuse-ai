
@'
# MealMuse AI 🍽️

MealMuse AI is an AI-powered recipe and meal-planning mobile application built using Flutter and Python. It integrates Google's Gemini API to provide AI-assisted recipe discovery and cooking assistance.

## Features

- AI-powered recipe discovery and cooking assistance.
- Recipe details and browsing.
- Save and manage favourite recipes.
- Weekly meal planning.
- Grocery list management.
- Local data storage and management.
- Python backend with Gemini API integration.

## Technology Stack

### Frontend
- Flutter
- Dart
- Material UI

### Backend
- Python
- REST API
- Google Gemini API

### Database and Storage
- SQLite
- Local application storage

## Project Structure

```text
MealMuse_AI/
├── android/
├── assets/
│   └── images/
├── backend/
│   ├── services/
│   ├── main.py
│   ├── requirements.txt
│   └── .env.example
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## Getting Started

### Flutter Application

1. Install Flutter and configure the Android development environment.
2. Clone this repository.
3. Navigate to the project directory.
4. Install dependencies:

```bash
flutter pub get
```

5. Run the application:

```bash
flutter run
```

### Python Backend

1. Navigate to the backend directory.
2. Install the dependencies:

```bash
pip install -r requirements.txt
```

3. Configure the required environment variables using `.env.example`.
4. Follow the backend-specific instructions in `backend/README.md`.

**Note:** Never upload API keys, passwords, or `.env` files to GitHub.

## Author

Sneha Padhy

Developed as an independent project.
'@ | Set-Content -Path README.md -Encoding UTF8
