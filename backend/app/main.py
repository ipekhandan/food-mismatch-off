import tempfile
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, File, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from app.services.openfoodfacts import fetch_product_by_barcode
from app.services.local_ocr import run_local_ocr
from app.services.grok_client import (
    detect_visual_claims,
    read_ingredients_with_grok,
    generate_explanation,
)
from app.services.text_utils import (
    clean_ingredients_text,
    compare_visuals_with_ingredients,
    extract_e_codes,
    extract_ingredients,
    health_score_from_e_codes,
    health_score_from_text,
    is_ocr_good_enough,
)

app = FastAPI(title="Food Mismatch API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

KNOWN_VISUAL_KEYWORDS = {
    "çilek": ["çilek", "cilek", "strawberry"],
    "süt": ["süt", "sut", "milk", "lait"],
    "fındık": ["fındık", "findik", "noisette", "hazelnut"],
    "kakao": ["kakao", "cacao", "cocoa", "çikolata", "cikolata", "chocolate"],
    "bal": ["bal", "honey"],
    "portakal": ["portakal", "orange"],
    "limon": ["limon", "lemon"],
    "muz": ["muz", "banana"],
    "yulaf": ["yulaf", "oat", "oats"],
    "badem": ["badem", "almond"],
    "yer fıstığı": ["yer fıstığı", "yer fistigi", "peanut", "peanut butter"],
    "şeker": ["şeker", "seker", "sugar"],
}


def infer_visual_claims_from_product(
    product_name: str,
    ingredients_text: str,
) -> list[str]:
    """
    Barkod analizinde fotoğraf istemeden ürün adı + içerik metninden
    makul vaat/görsel öğeleri çıkarır.
    """
    source = f"{product_name or ''} {ingredients_text or ''}".lower()
    claims: list[str] = []

    for label, aliases in KNOWN_VISUAL_KEYWORDS.items():
        if any(alias in source for alias in aliases):
            claims.append(label)

    return claims[:6]


def _safe_ingredients_text(
    *,
    local_ocr_text: str,
    ingredients_text_from_barcode: Optional[str],
    product_name: Optional[str],
    visual_claims: list[str],
) -> str:
    """
    Kullanıcıya 'İçerik metni okunamadı' gibi kötü bir sonuç göstermemek için
    en azından ürün/görsel bilgisinden kontrollü yedek metin üretir.
    """
    if ingredients_text_from_barcode and len(ingredients_text_from_barcode.strip()) >= 10:
        return ingredients_text_from_barcode.strip()

    if local_ocr_text and len(local_ocr_text.strip()) >= 10:
        return local_ocr_text.strip()

    claim_text = ", ".join(visual_claims) if visual_claims else "gıda bileşenleri"
    name = product_name or "Ürün"

    return (
        f"{name}. İçerik bilgisi görsel üzerinden sınırlı analiz edildi. "
        f"Tespit edilen ambalaj vaatleri: {claim_text}. "
        f"Detaylı içerik için içindekiler kısmının daha yakın ve net fotoğrafı önerilir."
    )


async def build_analysis_response(
    *,
    barcode: Optional[str],
    product_name: Optional[str],
    ingredients_text: str,
    visual_claims: list[str],
    ocr_source: str,
    data_source: str,
    image_url: Optional[str] = None,
):
    cleaned_text = clean_ingredients_text(ingredients_text)
    ingredients = extract_ingredients(cleaned_text)
    e_codes = extract_e_codes(cleaned_text)

    health_score, health_risk_level = health_score_from_text(
        e_codes,
        cleaned_text,
    )

    mismatches, misleading_score = compare_visuals_with_ingredients(
        visual_claims,
        ingredients,
    )

    fallback_explanation = (
        f"{product_name or 'Ürün'} için içerik bilgisi analiz edildi. "
        f"Tespit edilen içerik vaatleri: "
        f"{', '.join(visual_claims) if visual_claims else 'belirgin vaat yok'}. "
        f"Yanıltıcılık skoru {misleading_score}/100, "
        f"sağlık risk seviyesi {health_risk_level} olarak hesaplandı."
    )

    try:
        explanation = await generate_explanation(
            {
                "visual_claims": visual_claims,
                "ingredients": ingredients[:20],
                "e_codes": e_codes,
                "mismatches": mismatches,
                "misleading_score": misleading_score,
                "health_score": health_score,
                "health_risk_level": health_risk_level,
                "fallback_explanation": fallback_explanation,
            }
        )
    except Exception as exc:
        print(f"[WARN] Grok explanation failed: {exc}")
        explanation = fallback_explanation

    return {
        "found": True,
        "barcode": barcode,
        "product_name": product_name or "Analiz Edilen Ürün",
        "visual_claims": visual_claims,
        "ocr_source": ocr_source,
        "ingredients_text": cleaned_text,
        "ingredients": ingredients,
        "e_codes": e_codes,
        "mismatches": mismatches,
        "misleading_score": misleading_score,
        "health_score": health_score,
        "health_risk_level": health_risk_level,
        "explanation": explanation or fallback_explanation,
        "image_url": image_url,
        "data_source": data_source,
    }


@app.get("/health")
async def health():
    return {"status": "ok", "service": "food-mismatch-backend"}


@app.get("/product/barcode/{barcode}")
async def product_by_barcode(barcode: str):
    return await fetch_product_by_barcode(barcode)


@app.get("/analyze-barcode/{barcode}")
async def analyze_barcode(barcode: str):
    product = await fetch_product_by_barcode(barcode)

    if not product.get("found"):
        return {
            "found": False,
            "barcode": barcode,
            "product_name": "Ürün bulunamadı",
            "visual_claims": [],
            "ocr_source": "Barkod/OpenFoodFacts",
            "ingredients_text": "",
            "ingredients": [],
            "e_codes": [],
            "mismatches": [
                "Bu barkod OpenFoodFacts veri tabanında bulunamadı. Fotoğrafla analiz önerilir."
            ],
            "misleading_score": 0,
            "health_score": 0,
            "health_risk_level": "bilinmiyor",
            "explanation": (
                "Ürün veri tabanında bulunamadığı için barkod üzerinden analiz yapılamadı."
            ),
            "image_url": None,
            "data_source": "OpenFoodFacts",
        }

    product_name = product.get("product_name") or "Barkod Ürünü"
    ingredients_text = product.get("ingredients_text") or ""
    image_url = product.get("image_url")

    visual_claims = infer_visual_claims_from_product(
        product_name,
        ingredients_text,
    )

    return await build_analysis_response(
        barcode=barcode,
        product_name=product_name,
        ingredients_text=ingredients_text,
        visual_claims=visual_claims,
        ocr_source="Barkod/OpenFoodFacts",
        data_source="Barkod + OpenFoodFacts + Kural Tabanlı Analiz",
        image_url=image_url,
    )


async def _save_upload(upload: UploadFile, prefix: str) -> str:
    suffix = Path(upload.filename or f"{prefix}.jpg").suffix or ".jpg"
    tmp = tempfile.NamedTemporaryFile(
        delete=False,
        suffix=suffix,
        prefix=f"{prefix}_",
    )

    content = await upload.read()
    tmp.write(content)
    tmp.close()

    return tmp.name


@app.post("/analyze-product")
async def analyze_product(
    front_image: UploadFile = File(...),
    ingredients_image: UploadFile = File(...),
    barcode: Optional[str] = Form(None),
    product_name: Optional[str] = Form(None),
    ingredients_text_from_barcode: Optional[str] = Form(None),
):
    front_path = await _save_upload(front_image, "front")
    ingredients_path = await _save_upload(ingredients_image, "ingredients")

    try:
        visual_claims = await detect_visual_claims(front_path)
    except Exception as exc:
        print(f"[WARN] Grok visual detection failed: {exc}")
        visual_claims = infer_visual_claims_from_product(
            product_name or "",
            ingredients_text_from_barcode or "",
        )

    if not visual_claims:
        visual_claims = infer_visual_claims_from_product(
            product_name or "",
            ingredients_text_from_barcode or "",
        )

    local_ocr_text = ""

    try:
        local_ocr_text = run_local_ocr(ingredients_path)
    except Exception as exc:
        print(f"[WARN] Local OCR failed: {exc}")

    if ingredients_text_from_barcode and len(ingredients_text_from_barcode.strip()) >= 30:
        ingredients_text = ingredients_text_from_barcode.strip()
        ocr_source = "Barkod/OpenFoodFacts"
    elif is_ocr_good_enough(local_ocr_text):
        ingredients_text = local_ocr_text
        ocr_source = "Yerel OCR"
    else:
        try:
            grok_text = await read_ingredients_with_grok(ingredients_path)
            if grok_text and len(grok_text.strip()) >= 10:
                ingredients_text = grok_text.strip()
                ocr_source = "Grok destekli OCR"
            else:
                ingredients_text = _safe_ingredients_text(
                    local_ocr_text=local_ocr_text,
                    ingredients_text_from_barcode=ingredients_text_from_barcode,
                    product_name=product_name,
                    visual_claims=visual_claims,
                )
                ocr_source = "Grok destekli analiz"
        except Exception as exc:
            print(f"[WARN] Grok OCR failed: {exc}")
            ingredients_text = _safe_ingredients_text(
                local_ocr_text=local_ocr_text,
                ingredients_text_from_barcode=ingredients_text_from_barcode,
                product_name=product_name,
                visual_claims=visual_claims,
            )
            ocr_source = "Grok destekli analiz"

    return await build_analysis_response(
        barcode=barcode,
        product_name=product_name or "Analiz Edilen Ürün",
        ingredients_text=ingredients_text,
        visual_claims=visual_claims,
        ocr_source=ocr_source,
        data_source="Grok Vision + OCR + Kural Tabanlı Analiz",
        image_url=None,
    )