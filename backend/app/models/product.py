from datetime import datetime
from sqlalchemy import String, DateTime, JSON, Text
from sqlalchemy.orm import Mapped, mapped_column
from app.db.database import Base

class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    barcode: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    name: Mapped[str | None] = mapped_column(String(255))
    brands: Mapped[str | None] = mapped_column(String(255))
    image_url: Mapped[str | None] = mapped_column(Text)
    ingredients: Mapped[list | None] = mapped_column(JSON)
    ingredients_text: Mapped[str | None] = mapped_column(Text)
    categories: Mapped[list | None] = mapped_column(JSON)
    raw_data: Mapped[dict | None] = mapped_column(JSON)
    cached_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
