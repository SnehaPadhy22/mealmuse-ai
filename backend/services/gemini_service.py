
import os
import json

from google import genai
from google.genai import types


def validate_recipe(recipe):
    """Validate the structure of the AI-generated recipe."""

    if not isinstance(recipe, dict):
        raise ValueError("AI returned an invalid recipe.")

    required_fields = [
        "recipe_name",
        "description",
        "preparation_time",
        "cooking_time",
        "servings",
        "ingredients",
        "instructions"
    ]

    for field in required_fields:
        if field not in recipe:
            raise ValueError(
                f"AI response is missing the {field} field."
            )

    text_fields = [
        "recipe_name",
        "description",
        "preparation_time",
        "cooking_time"
    ]

    for field in text_fields:
        if (
            not isinstance(recipe[field], str)
            or not recipe[field].strip()
        ):
            raise ValueError(f"Invalid {field}.")

    if (
        not isinstance(recipe["servings"], int)
        or isinstance(recipe["servings"], bool)
        or recipe["servings"] < 1
    ):
        raise ValueError("Invalid serving information.")

    if (
        not isinstance(recipe["ingredients"], list)
        or not recipe["ingredients"]
    ):
        raise ValueError("Invalid recipe ingredients.")

    for ingredient in recipe["ingredients"]:
        if not isinstance(ingredient, dict):
            raise ValueError("Invalid ingredient information.")

        name = ingredient.get("name")
        quantity = ingredient.get("quantity")

        if (
            not isinstance(name, str)
            or not name.strip()
            or not isinstance(quantity, str)
            or not quantity.strip()
        ):
            raise ValueError("Invalid ingredient information.")

    if (
        not isinstance(recipe["instructions"], list)
        or not recipe["instructions"]
    ):
        raise ValueError("Invalid cooking instructions.")

    if not all(
        isinstance(step, str) and step.strip()
        for step in recipe["instructions"]
    ):
        raise ValueError("Invalid cooking instruction steps.")

    return recipe


def generate_recipe(
    ingredients,
    dietary_preference,
    cooking_time,
    meal_type
):
    if not ingredients:
        raise ValueError("Please provide at least one ingredient.")

    cleaned_ingredients = [
        item.strip()
        for item in ingredients
        if isinstance(item, str) and item.strip()
    ]

    if not cleaned_ingredients:
        raise ValueError("Please provide valid ingredients.")

    api_key = os.getenv("GEMINI_API_KEY", "").strip()

    if not api_key:
        raise ValueError("Gemini API key is missing.")

    model_name = os.getenv(
        "GEMINI_MODEL",
        "gemini-2.5-flash"
    ).strip()

    if not model_name:
        raise ValueError("Gemini model configuration is missing.")

    client = genai.Client(api_key=api_key)

    prompt = f"""
You are MealMuse AI, a professional cooking assistant.

Generate one practical and easy-to-follow recipe using:

Ingredients: {cleaned_ingredients}
Dietary preference: {dietary_preference}
Maximum total cooking time: {cooking_time} minutes
Meal type: {meal_type}

Requirements:
1. Use the available ingredients wherever possible.
2. Respect the selected dietary preference.
3. Keep the total preparation and cooking time within
   the requested maximum time.
4. Provide realistic ingredient quantities.
5. Give clear, numbered cooking instructions.
6. Do not suggest ingredients that conflict with the
   dietary preference.

Return a valid JSON object with exactly these fields:

{{
    "recipe_name": "Recipe name",
    "description": "Short description",
    "preparation_time": "10 minutes",
    "cooking_time": "15 minutes",
    "servings": 2,
    "ingredients": [
        {{
            "name": "Ingredient",
            "quantity": "Amount"
        }}
    ],
    "instructions": [
        "Step 1",
        "Step 2"
    ]
}}

Return only valid JSON.
Do not include Markdown formatting or explanations.
"""

    response = client.models.generate_content(
        model=model_name,
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            temperature=0.7
        )
    )

    response_text = response.text

    if not response_text or not response_text.strip():
        raise ValueError("AI returned an empty response.")

    try:
        recipe = json.loads(response_text)
    except json.JSONDecodeError:
        raise ValueError("AI returned an invalid recipe format.")

    return validate_recipe(recipe)
