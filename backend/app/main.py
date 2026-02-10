from fastapi import FastAPI, HTTPException
from app.services.off_client import fetch_product
from app.services.scoring import analyze_mismatch

app = FastAPI(title="Food Mismatch (OFF-only)", version="0.3.0")

@app.get("/")
def root():
    return {"message": "Food Mismatch API is running. Go to /docs"}

@app.get("/health")
def health():
    return {"ok": True, "source": "openfoodfacts"}

def _core_product(product: dict) -> dict:
    # OFF'den gelen ham product içinden analiz için gerekli minimum alanlar
    return {
        "product_name": product.get("product_name"),
        "ingredients_text": product.get("ingredients_text"),
        "additives_tags": product.get("additives_tags") or [],
        # sağlık risk için
        "nutriments": product.get("nutriments") or {},
        "nutriscore_grade": product.get("nutriscore_grade"),
        "nova_group": product.get("nova_group"),
        "allergens": product.get("allergens"),
        "allergens_tags": product.get("allergens_tags") or [],
        # görsel/link (Flutter’da göstermek istersen)
        "image_url": product.get("image_url"),
        "brands": product.get("brands"),
        "quantity": product.get("quantity"),
    }

@app.get("/product/{barcode}")
async def get_product(barcode: str):
    try:
        product = await fetch_product(barcode)
        return _core_product(product)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

@app.get("/analyze/{barcode}")
async def analyze(barcode: str):
    """
    Fetch product from OpenFoodFacts and return mismatch analysis (v1).
    Health risk will be added in the next step.
    """
    try:
        product = await fetch_product(barcode)
        core = _core_product(product)
        analysis = analyze_mismatch(core)
        return {"barcode": barcode, "product": core, "analysis": analysis}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
