import re

# Ambalajda sık kullanılan görsel iddialar ve karşılık gelen içerik anahtar kelimeleri
CLAIM_KEYWORDS = {
    "hindistan cevizi": ["hindistan cevizi", "coconut", "kokos"],
    "çilek": ["çilek", "strawberry", "fraise"],
    "fındık": ["fındık", "hazelnut", "noisette"],
    "süt": ["süt", "milk", "lait", "latte"],
    "bal": ["bal", "honey", "miel"],
    "badem": ["badem", "almond", "amande"],
    "kakao": ["kakao", "cacao", "cocoa"],
    "meyve": ["meyve", "fruit", "frucht"],
    "limon": ["limon", "lemon", "citron"],
    "portakal": ["portakal", "orange"],
    "ahududu": ["ahududu", "raspberry", "framboise"],
    "yaban mersini": ["yaban mersini", "blueberry", "myrtille"],
    "şeftali": ["şeftali", "peach", "pêche"],
    "vanilja": ["vanilja", "vanilla", "vanille", "vanillin"],
    "karamel": ["karamel", "caramel"],
    "bitter": ["bitter", "dark", "noir"],
}


class TrustScoreService:
    """
    OCR metninden tespit edilen iddiaları gerçek içerik listesiyle karşılaştırır
    ve 0-100 arası güven skoru üretir.
    """

    def calculate(
        self,
        ocr_text: str,
        actual_ingredients: list[str],
    ) -> dict:
        ocr_lower = ocr_text.lower()
        ingredients_lower = " ".join(actual_ingredients).lower()

        # 1. OCR'dan iddia edilen içerikleri tespit et
        detected_claims = []
        for claim, synonyms in CLAIM_KEYWORDS.items():
            for synonym in synonyms:
                if synonym in ocr_lower:
                    detected_claims.append(claim)
                    break

        if not detected_claims:
            return {
                "trust_score": 70,
                "verdict": "İddia Tespit Edilemedi",
                "detected_claims": [],
                "matched": [],
                "unmatched": [],
            }

        # 2. Her iddia için gerçek içerikte eşleşme ara
        matched = []
        unmatched = []

        for claim in detected_claims:
            synonyms = CLAIM_KEYWORDS.get(claim, [claim])
            found = any(s in ingredients_lower for s in synonyms)
            if found:
                matched.append(claim)
            else:
                unmatched.append(claim)

        # 3. Skor hesapla
        match_ratio = len(matched) / len(detected_claims) if detected_claims else 1.0
        trust_score = int(match_ratio * 100)

        # 4. Verdict
        if trust_score >= 80:
            verdict = "✅ Güvenilir"
        elif trust_score >= 50:
            verdict = "⚠️ Şüpheli"
        else:
            verdict = "❌ Yanıltıcı"

        return {
            "trust_score": trust_score,
            "verdict": verdict,
            "detected_claims": detected_claims,
            "matched": matched,
            "unmatched": unmatched,
        }
