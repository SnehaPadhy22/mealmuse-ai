
# MealMuse AI 🍽️

MealMuse AI is an AI-powered recipe application that helps users discover recipes based on the ingredients they have available.

## Features

- AI-powered recipe generation using Google Gemini.
- Generate recipes from available ingredients.
- View recipe details, ingredients and cooking instructions.
- Save and manage favourite recipes.
- Plan meals for different days.
- Create and manage grocery lists.

## Technology Stack

**Mobile Application**
- Flutter
- Dart
- SQLite

**Backend**
- Python
- FastAPI
- Google Gemini API
- Uvicorn

## Backend Architecture

The Flutter application communicates with the FastAPI backend through REST API endpoints. The backend connects to Google Gemini to generate recipes based on user-provided ingredients.

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | API home |
| GET | `/health` | Backend health check |
| POST | `/generate-recipe` | Generate AI recipes |

## Backend Setup

### 1. Clone the repository

```bash
git clone https://github.com/SnehaPadhy22/mealmuse-ai.git
cd mealmuse-ai
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

Activate it:

Windows:
```bash
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

Create a `.env` file in the backend root directory:

```env
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-3.5-flash
```

Never upload your actual API key to GitHub.

### 5. Start the backend

```bash
uvicorn main:app --reload
```

The backend will run locally at:

`http://127.0.0.1:8000`

API documentation:

`http://127.0.0.1:8000/docs`

## Live Backend

https://mealmuse-ai.onrender.com

## Project Status

The backend is deployed on Render, and the Flutter application has been tested on an Android device.

---

**Developed as an AI-powered recipe application project.**
