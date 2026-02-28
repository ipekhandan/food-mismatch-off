from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    OFF_API_BASE_URL: str = "https://world.openfoodfacts.org"
    OFF_USER_AGENT: str = "FoodMismatchApp/1.0"
    ROBOFLOW_API_KEY: str = ""
    ROBOFLOW_MODEL_ID: str = "fruit-sugar-detection-ye7hb/1"

    class Config:
        env_file = ".env"

settings = Settings()
