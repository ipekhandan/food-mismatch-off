from fastapi import FastAPI, HTTPException
from app.services.off_client import fetch_product

app = FastAPI(title="Food Mismatch (OFF-only)", version="0.1.0")

@app.get("/health")
def health():
    return {"ok": True, "source": "openfoodfacts"}

@app.get("/product/{barcode}")
async def get_product(barcode: str):
    try:
        product = await fetch_product(barcode)
        return {
            "product_name": product.get("product_name"),
            "ingredients_text": product.get("ingredients_text"),
            "additives_tags": product.get("additives_tags"),
        }
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
