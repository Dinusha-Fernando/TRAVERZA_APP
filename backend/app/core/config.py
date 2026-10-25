
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # Application
    APP_NAME: str = "TRAVERZA"
    APP_ENV: str = "development"
    DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"
    SECRET_KEY: str = "default-insecure-secret-key-change-in-production-min32"
    CORS_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
    ]

    # Database (PostgreSQL + PostGIS)
    DATABASE_URL: str = Field(
        default="postgresql+asyncpg://traverza_user:traverza_password@localhost:5432/traverza_db"
    )
    DATABASE_SYNC_URL: str = Field(
        default="postgresql://traverza_user:traverza_password@localhost:5432/traverza_db"
    )

    # Redis & Background Tasks
    REDIS_URL: str = "redis://localhost:6379/0"
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/2"

    # S3 Storage (MinIO or AWS S3)
    S3_ENDPOINT_URL: str = "http://localhost:9000"
    S3_ACCESS_KEY: str = "minioadmin"
    S3_SECRET_KEY: str = "minioadmin"
    S3_BUCKET_DOCUMENTS: str = "traverza-documents-private"
    S3_BUCKET_MEDIA: str = "traverza-media-public"
    S3_REGION: str = "us-east-1"

    # Authentication & JWT
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Google OAuth
    GOOGLE_CLIENT_ID: str = "396524897339-e4gscl1i0r3oud7gpc88vbljbi6oaaet.apps.googleusercontent.com"

    # Pilot Constraints
    PILOT_CORRIDOR_NAME: str = "Colombo - Sigiriya - Kandy - Nuwara Eliya"
    DEFAULT_CURRENCY: str = "LKR"


settings = Settings()
