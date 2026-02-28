import asyncio
import httpx
import json
from pathlib import Path

DATASET_DIR = Path("ml/dataset")
IMAGES_DIR = DATASET_DIR / "images"
LABELS_FILE = DATASET_DIR / "labels.json"

IMAGES_DIR.mkdir(parents=True, exist_ok=True)

headers = {"User-Agent": "FoodMismatchML/1.0 (research)"}

PRODUCTS_PER_PAGE = 50
MAX_PAGES = 20  # 50 * 20 = 1000 ürün


async def fetch_turkish_products(client: httpx.AsyncClient, page: int) -> list[dict]:
    """Türkiye'deki ürünleri çeker."""
    url = "https://tr.openfoodfacts.org/cgi/search.pl"
    params = {
        "action": "process",
        "json": 1,
        "page_size": PRODUCTS_PER_PAGE,
        "page": page,
        "fields": "code,product_name,ingredients_text,ingredients,image_front_url,categories_tags,labels_tags",
        "sort_by": "popularity",
    }
    try:
        r = await client.get(url, params=params, timeout=30.0)
        r.raise_for_status()
        data = r.json()
        products = data.get("products", [])
        print(f"  Sayfa {page}: {len(products)} ürün")
        return products
    except Exception as e:
        print(f"  [SKIP] Sayfa {page}: {e}")
        return []


async def download_image(client: httpx.AsyncClient, url: str, path: Path) -> bool:
    try:
        r = await client.get(url, timeout=15.0)
        if r.status_code == 200:
            path.write_bytes(r.content)
            return True
    except Exception:
        pass
    return False


def extract_labels(product: dict) -> dict:
    ingredients_text = (product.get("ingredients_text") or "").lower()
    ingredients_list = product.get("ingredients") or []
    all_ingredients = ingredients_text + " " + " ".join(
        i.get("text", "").lower() for i in ingredients_list if isinstance(i, dict)
    )

    product_name = (product.get("product_name") or "").lower()
    categories = " ".join(product.get("categories_tags") or []).lower()

    # Ürün adındaki iddialar içerikte var mı?
    name_words = [w for w in product_name.split() if len(w) > 3]
    misleading_clues = []
    for word in set(name_words):
        if word in product_name and word not in all_ingredients:
            misleading_clues.append(word)

    return {
        "has_ingredients": bool(ingredients_text),
        "misleading": len(misleading_clues) > 0,
        "misleading_clues": misleading_clues,
        "categories": categories,
        "ingredient_count": len(ingredients_list),
    }


async def collect():
    all_labels = {}
    downloaded = 0
    skipped = 0

    if LABELS_FILE.exists():
        all_labels = json.loads(LABELS_FILE.read_text())
        print(f"📂 Mevcut {len(all_labels)} kayıt yüklendi.")

    print("🚀 Türkiye ürünleri toplanıyor...\n")

    async with httpx.AsyncClient(headers=headers, follow_redirects=True) as client:
        for page in range(1, MAX_PAGES + 1):
            print(f"\n📄 Sayfa {page}/{MAX_PAGES}")
            products = await fetch_turkish_products(client, page)

            if not products:
                print("Ürün kalmadı, durduruluyor.")
                break

            for product in products:
                code = product.get("code")
                image_url = product.get("image_front_url")
                if not code or not image_url:
                    skipped += 1
                    continue

                image_path = IMAGES_DIR / f"{code}.jpg"
                if image_path.exists() and code in all_labels:
                    continue

                success = await download_image(client, image_url, image_path)
                if success:
                    all_labels[code] = {
                        "product_name": product.get("product_name"),
                        "image_path": str(image_path),
                        "labels": extract_labels(product),
                    }
                    downloaded += 1
                    if downloaded % 25 == 0:
                        LABELS_FILE.write_text(
                            json.dumps(all_labels, ensure_ascii=False, indent=2)
                        )
                        print(f"  💾 {downloaded} görsel indirildi")
                else:
                    skipped += 1

            await asyncio.sleep(1)

    LABELS_FILE.write_text(json.dumps(all_labels, ensure_ascii=False, indent=2))
    print(f"\n✅ Tamamlandı!")
    print(f"   İndirilen: {downloaded} | Atlanan: {skipped} | Toplam: {len(all_labels)}")
    misleading = sum(1 for v in all_labels.values() if v["labels"].get("misleading"))
    print(f"   Yanıltıcı: {misleading} | Güvenilir: {len(all_labels) - misleading}")

if __name__ == "__main__":
    asyncio.run(collect())
