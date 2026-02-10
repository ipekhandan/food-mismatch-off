import httpx

OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v0/product/{barcode}.json"

async def fetch_product(barcode: str) -> dict:
    url = OFF_PRODUCT_URL.format(barcode=barcode)
    async with httpx.AsyncClient(timeout=20.0) as client:
        r = await client.get(url)
        r.raise_for_status()
        data = r.json()

    if data.get("status") != 1:
        raise ValueError("Product not found in OpenFoodFacts")

    return data.get("product", {})
