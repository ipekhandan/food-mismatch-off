from fastapi import FastAPI, HTTPException, Depends
from contextlib import asynccontextmanager
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.db.database import create_tables, get_db
from app.services.food_facts_service import OpenFoodFactsService
from app.routers import analyze

@asynccontextmanager
async def lifespan(app: FastAPI):
    await create_tables()
    yield

app = FastAPI(title="Food Mismatch API", version="0.1.0", lifespan=lifespan)

app.include_router(analyze.router)

class ProductResponse(BaseModel):
    barcode: str
    name: str | None
    brands: str | None
    image_url: str | None
    ingredients: list[str]
    ingredients_text: str | None
    categories: list[str]

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/product/{barcode}", response_model=ProductResponse)
async def get_product(barcode: str, db: AsyncSession = Depends(get_db)):
    service = OpenFoodFactsService(db)
    product = await service.get_product(barcode)
    if not product:
        raise HTTPException(status_code=404, detail="Ürün bulunamadı.")
    return ProductResponse(
        barcode=product.barcode,
        name=product.name,
        brands=product.brands,
        image_url=product.image_url,
        ingredients=product.ingredients or [],
        ingredients_text=product.ingredients_text,
        categories=product.categories or [],
    )
