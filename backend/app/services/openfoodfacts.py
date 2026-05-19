import httpx

async def fetch_product_by_barcode(barcode: str) -> dict:
    url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
    async with httpx.AsyncClient(timeout=15) as client:
        response = await client.get(url)
    response.raise_for_status()
    data = response.json()

    if data.get("status") != 1:
        return {
            "found": False,
            "barcode": barcode,
            "message": "Ürün OpenFoodFacts veri tabanında bulunamadı.",
            "needs_photo_analysis": True,
        }

    product = data.get("product", {}) or {}
    ingredients_text = (
        product.get("ingredients_text_tr")
        or product.get("ingredients_text")
        or product.get("ingredients_text_en")
        or ""
    )
    product_name = product.get("product_name_tr") or product.get("product_name") or ""
    brand = product.get("brands") or ""
    image_url = product.get("image_url") or product.get("image_front_url") or ""
    additives_tags = product.get("additives_tags", []) or []

    return {
        "found": True,
        "barcode": barcode,
        "product_name": product_name or "Barkodlu Ürün",
        "brand": brand,
        "ingredients_text": ingredients_text,
        "image_url": image_url,
        "additives": additives_tags,
        "data_source": "OpenFoodFacts",
        "needs_photo_analysis": len(ingredients_text.strip()) < 30,
    }
