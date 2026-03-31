from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.db.database import get_db
from app.services.food_facts_service import OpenFoodFactsService
from app.services.trust_score_service import TrustScoreService
from app.services.yolo_service import YoloService

router = APIRouter(prefix="/analyze", tags=["analyze"])

yolo_service = YoloService()


class AnalyzeRequest(BaseModel):
    ocr_text: str
    image_base64: str | None = None


class AnalyzeResponse(BaseModel):
    trust_score: int
    verdict: str
    detected_claims: list[str]
    actual_ingredients: list[str]
    matched: list[str]
    unmatched: list[str]
    product_name: str | None
    image_url: str | None


@router.post("", response_model=AnalyzeResponse)
async def analyze(request: AnalyzeRequest, db: AsyncSession = Depends(get_db)):
    ocr_text = request.ocr_text
    off_service = OpenFoodFactsService(db)
    trust_service = TrustScoreService()

    product_name = None
    actual_ingredients = []
    image_url = None
    detected_claims = []

    # 1. OCR metninden tüm satırları al, her birini dene
    def is_valid(s):
        s = s.strip()
        if len(s) < 5: return False
        if s.replace("%","").replace(".","").replace(" ","").isdigit(): return False
        if len(s.split()) < 2: return False
        if all(not c.isalpha() for c in s): return False
        return True
    lines = [l.strip() for l in ocr_text.split("\n") if is_valid(l)]
    print(f"[OCR RAW] {repr(ocr_text)}")
    print(f"[OCR LINES] {lines}")
    
    for line in lines:
        product = await off_service.search_by_name(line)
        if product and product.ingredients:
            product_name = product.name
            actual_ingredients = product.ingredients or []
            image_url = product.image_url
            print(f"[OFF] Ürün bulundu: {product_name} ('{line}' ile)")
            break

    # 2. YOLO ile görseldeki meyve/sebzeleri tespit et
    if request.image_base64:
        yolo_result = yolo_service.detect_fruits(request.image_base64)
        detected_claims = yolo_result["detected_claims"]
        print(f"[YOLO] Tespit: {detected_claims}")

    # 3. Güven skoru hesapla
    score_result = trust_service.calculate(
        ocr_text=ocr_text,
        actual_ingredients=actual_ingredients,
    )

    # YOLO tespitlerini güven skoruna dahil et
    if detected_claims:
        ingredients_text = " ".join(actual_ingredients).lower()
        matched = [c for c in detected_claims if c in ingredients_text]
        unmatched = [c for c in detected_claims if c not in ingredients_text]

        yolo_ratio = len(matched) / len(detected_claims) if detected_claims else 1.0
        combined = int((score_result["trust_score"] + yolo_ratio * 100) / 2)
        score_result["trust_score"] = combined
        score_result["matched"].extend(matched)
        score_result["unmatched"].extend(unmatched)

        if score_result["trust_score"] >= 80:
            score_result["verdict"] = "✅ Güvenilir"
        elif score_result["trust_score"] >= 50:
            score_result["verdict"] = "⚠️ Şüpheli"
        else:
            score_result["verdict"] = "❌ Yanıltıcı"

    return AnalyzeResponse(
        trust_score=score_result["trust_score"],
        verdict=score_result["verdict"],
        detected_claims=detected_claims,
        actual_ingredients=actual_ingredients,
        matched=score_result["matched"],
        unmatched=score_result["unmatched"],
        product_name=product_name,
        image_url=image_url,
    )
