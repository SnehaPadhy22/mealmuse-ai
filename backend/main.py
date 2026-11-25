
import logging

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, field_validator
from dotenv import load_dotenv

from services.gemini_service import generate_recipe


load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


app = FastAPI(
    title="MealMuse AI",
    description="AI-powered recipe and meal planning API",
    version="1.0.0"
)


# Development configuration.
# Restrict allowed origins before production deployment.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


class RecipeRequest(BaseModel):

    ingredients: list[str] = Field(
        min_length=1,
        max_length=20,
        description="List of available ingredients"
    )

    dietary_preference: str = Field(
        default="No preference",
        max_length=50
    )

    cooking_time: int = Field(
        default=30,
        ge=5,
        le=180
    )

    meal_type: str = Field(
        default="Any",
        max_length=30
    )

    @field_validator("ingredients")
    @classmethod
    def validate_ingredients(cls, ingredients):
        cleaned = [
            ingredient.strip()
            for ingredient in ingredients
            if ingredient and ingredient.strip()
        ]

        if not cleaned:
            raise ValueError(
                "Please provide at least one valid ingredient."
            )

        # Remove duplicate ingredients.
        return list(dict.fromkeys(cleaned))

    @field_validator("dietary_preference", "meal_type")
    @classmethod
    def validate_text_fields(cls, value):
        value = value.strip()

        if not value:
            raise ValueError("This field cannot be empty.")

        return value


@app.get("/")
def home():
    return {
        "message": "Welcome to MealMuse AI",
        "application": "MealMuse AI",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "application": "MealMuse AI"
    }


@app.post("/generate-recipe")
def create_recipe(request: RecipeRequest):

    try:
        recipe = generate_recipe(
            ingredients=request.ingredients,
            dietary_preference=request.dietary_preference,
            cooking_time=request.cooking_time,
            meal_type=request.meal_type
        )

        return {
            "success": True,
            "recipe": recipe
        }

    except Exception:
        # Keep technical details in server logs,
        # not in the response sent to the mobile app.
        logger.exception("Recipe generation failed.")

        raise HTTPException(
            status_code=502,
            detail="Recipe generation failed. Please try again."
        )
