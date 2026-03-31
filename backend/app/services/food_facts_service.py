import httpx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta
from app.models.product import Product
from app.config import settings

CACHE_TTL_DAYS = 7

class OpenFoodFactsService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.base_url = settings.OFF_API_BASE_URL
        self.headers = {"User-Agent": settings.OFF_USER_AGENT}

    async def get_product(self, barcode: str):
        cached = await self._get_from_db(barcode)
        if cached:
            if self._is_cache_valid(cached):
                return cached
            return await self._fetch_and_update(barcode, cached)
        return await self._fetch_and_save(barcode)

    async def _get_from_db(self, barcode: str):
        result = await self.db.execute(select(Product).where(Product.barcode == barcode))
        return result.scalar_one_or_none()

    async def _fetch_from_off(self, barcode: str):
        url = f"{self.base_url}/api/v2/product/{barcode}.json"
        async with httpx.AsyncClient(headers=self.headers, timeout=30.0) as client:
            try:
                r = await client.get(url)
                r.raise_for_status()
                data = r.json()
                return data.get("product") if data.get("status") == 1 else None
            except httpx.HTTPError:
                return None

    async def _fetch_and_save(self, barcode: str):
        raw = await self._fetch_from_off(barcode)
        if not raw:
            return None
        product = Product(barcode=barcode, **self._parse(raw))
        self.db.add(product)
        await self.db.flush()
        return product

    async def _fetch_and_update(self, barcode: str, existing: Product):
        raw = await self._fetch_from_off(barcode)
        if not raw:
            return existing
        for k, v in self._parse(raw).items():
            setattr(existing, k, v)
        await self.db.flush()
        return existing

    def _parse(self, raw: dict) -> dict:
        ingredients = [i.get("text","").lower() for i in raw.get("ingredients",[]) if isinstance(i,dict)]
        categories = [c.replace("en:","") for c in raw.get("categories_tags",[])]
        return {
            "name": raw.get("product_name") or raw.get("product_name_en"),
            "brands": raw.get("brands"),
            "image_url": raw.get("image_front_url") or raw.get("image_url"),
            "ingredients": ingredients,
            "ingredients_text": raw.get("ingredients_text"),
            "categories": categories,
            "raw_data": raw,
            "cached_at": datetime.utcnow(),
        }

    @staticmethod
    def _is_cache_valid(product: Product) -> bool:
        if not product.cached_at:
            return False
        return datetime.utcnow() - product.cached_at < timedelta(days=CACHE_TTL_DAYS)

    async def search_by_name(self, name: str):
        """OFF API'de ürün adıyla arama yapar."""
        url = f"{self.base_url}/cgi/search.pl"
        params = {
            "search_terms": name,
            "search_simple": 1,
            "action": "process",
            "json": 1,
            "page_size": 1,
            "fields": "code,product_name,ingredients_text,ingredients,image_front_url,categories_tags",
        }
        async with httpx.AsyncClient(headers=self.headers, timeout=30.0) as client:
            try:
                r = await client.get(url, params=params)
                r.raise_for_status()
                products = r.json().get("products", [])
                if not products:
                    return None
                raw = products[0]
                barcode = raw.get("code")
                if not barcode:
                    return None
                cached = await self._get_from_db(barcode)
                if cached and self._is_cache_valid(cached):
                    return cached
                p = Product(barcode=barcode, **self._parse(raw))
                self.db.add(p)
                await self.db.flush()
                return p
            except Exception as e:
                print(f"[OFF SEARCH ERROR] {e}")
                return None
