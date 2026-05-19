import base64
import json
from pathlib import Path
import httpx

from app.core.config import get_settings


def _image_to_data_url(path: str) -> str:
    data = Path(path).read_bytes()
    suffix = Path(path).suffix.lower().replace('.', '') or 'jpeg'
    if suffix == 'jpg':
        suffix = 'jpeg'
    encoded = base64.b64encode(data).decode('utf-8')
    return f"data:image/{suffix};base64,{encoded}"


def _safe_json_loads(text: str) -> dict:
    text = (text or '').strip()
    if text.startswith('```'):
        text = text.strip('`')
        text = text.replace('json\n', '', 1).replace('JSON\n', '', 1)
    start = text.find('{')
    end = text.rfind('}')
    if start != -1 and end != -1:
        text = text[start:end + 1]
    return json.loads(text)


async def _chat_with_images(prompt: str, image_paths: list[str], max_tokens: int = 900) -> dict:
    settings = get_settings()
    if settings.allow_fake_grok or not settings.xai_api_key:
        return {
            "visual_claims": ["çilek", "süt"],
            "ingredients_text": "İçindekiler: şeker, süt tozu, bitkisel yağ, çilek aroması, E322",
            "explanation": "Demo modunda Grok çağrısı yapılmadı. .env içine XAI_API_KEY eklenince gerçek analiz çalışır."
        }

    content = [{"type": "text", "text": prompt}]
    for path in image_paths:
        content.append({"type": "image_url", "image_url": {"url": _image_to_data_url(path)}})

    payload = {
        "model": settings.xai_model,
        "messages": [
            {"role": "system", "content": "Sen gıda ambalajı analiz eden bir asistansın. Sadece geçerli JSON döndür."},
            {"role": "user", "content": content},
        ],
        "temperature": 0.1,
        "max_tokens": max_tokens,
    }

    headers = {
        "Authorization": f"Bearer {settings.xai_api_key}",
        "Content-Type": "application/json",
    }
    url = settings.xai_base_url.rstrip('/') + "/chat/completions"

    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(url, headers=headers, json=payload)
    response.raise_for_status()
    raw = response.json()["choices"][0]["message"]["content"]
    return _safe_json_loads(raw)


async def detect_visual_claims(front_image_path: str) -> list[str]:
    prompt = """
Bu görsel bir paketli gıda ambalajının ön yüzüdür.
Ambalajda tüketicide içerik vaadi oluşturan gıda öğelerini tespit et.
Logo, tabak, kaşık, süs, yaprak gibi gıda içeriği olmayan öğeleri alma.
Sadece JSON döndür:
{"visual_claims": ["çilek", "süt"]}
"""
    data = await _chat_with_images(prompt, [front_image_path])
    claims = data.get("visual_claims", [])
    if not isinstance(claims, list):
        return []
    return [str(x).strip().lower() for x in claims if str(x).strip()]


async def read_ingredients_with_grok(ingredients_image_path: str) -> str:
    prompt = """
Bu görsel paketli gıda ürününün içindekiler/ingredients etiketidir.
Etiketteki içerik metnini mümkün olduğunca aynen oku.
Sadece JSON döndür:
{"ingredients_text": "İçindekiler: ..."}
"""
    data = await _chat_with_images(prompt, [ingredients_image_path])
    return str(data.get("ingredients_text", "")).strip()


async def generate_explanation(payload: dict) -> str:
    settings = get_settings()
    if settings.allow_fake_grok or not settings.xai_api_key:
        return payload.get("fallback_explanation", "Analiz tamamlandı.")

    prompt = f"""
Aşağıdaki gıda ambalaj analizini kullanıcı dostu Türkçe ile 2-3 cümlede açıkla.
Tıbbi kesin hüküm verme, sadece bilgilendirici konuş.
Sadece JSON döndür: {{"explanation": "..."}}

Veri:
{json.dumps(payload, ensure_ascii=False)}
"""
    data = await _chat_with_images(prompt, [])
    return str(data.get("explanation", "")).strip()
