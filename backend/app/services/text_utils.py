import re
import unicodedata

FOOD_SYNONYMS = {
    "çilek": ["çilek", "cilek", "strawberry"],
    "süt": ["süt", "sut", "milk", "lait", "skimmed milk", "milk powder", "süt tozu"],
    "fındık": ["fındık", "findik", "hazelnut", "noisette"],
    "kakao": ["kakao", "cocoa", "cacao", "çikolata", "cikolata", "chocolate"],
    "bal": ["bal", "honey"],
    "portakal": ["portakal", "orange"],
    "limon": ["limon", "lemon"],
    "muz": ["muz", "banana"],
    "yulaf": ["yulaf", "oat", "oats"],
    "badem": ["badem", "almond"],
    "yer fıstığı": ["yer fıstığı", "yer fistigi", "peanut", "peanut butter"],
    "şeker": ["şeker", "seker", "sugar"],
}

HIGH_RISK_E = {
    "E102", "E104", "E110", "E122", "E124", "E129",
    "E211", "E220", "E250", "E251", "E621",
}

MEDIUM_RISK_E = {
    "E150", "E150A", "E150B", "E150C", "E150D",
    "E202", "E221", "E322", "E330", "E338",
    "E407", "E415", "E471", "E476", "E950", "E951",
    "E955", "E960",
}

ATTENTION_TERMS = [
    "palm", "palmiye", "hidrojene", "hydrogenated", "fully hydrogenated", "tam hidrojenize",
    "aroma", "aroması", "aromasi", "flavouring", "flavoring", "flavourings", "flavorings",
    "renklendirici", "colorant", "koruyucu", "preservative",
    "glukoz", "fruktoz", "glucose", "fructose", "şurubu", "surubu", "syrup",
    "emülgatör", "emulgator", "emulsifier", "stabilizör", "stabilizer",
    "sweetener", "sweeteners", "tatlandırıcı", "tatlandirici",
    "aspartam", "aspartame", "asesülfam", "acesulfame", "sukraloz", "sucralose",
    "fosforik asit", "phosphoric acid", "asitlik düzenleyici", "acidity regulator",
    "zero sugar", "sıfır şeker", "sifir seker", "şekersiz", "sekersiz",
]

AROMA_WORDS = [
    "aroma", "aroması", "aromasi", "flavouring", "flavoring",
    "flavourings", "flavorings", "vanillin", "vanilin"
]


def normalize_text(text: str) -> str:
    text = text or ""
    text = unicodedata.normalize("NFKC", text)
    text = text.replace("İ", "i").replace("I", "ı")
    text = re.sub(r"\s+", " ", text)
    return text.strip().lower()


def clean_ingredients_text(text: str) -> str:
    text = text or ""
    text = text.replace("\n", " ").replace("\r", " ")
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"(içindekiler|ingredients)\s*[:：-]?", "", text, flags=re.I)
    return text.strip()


def extract_ingredients(text: str) -> list[str]:
    cleaned = clean_ingredients_text(text)
    cleaned = re.split(
        r"\b(besin|nutrition|enerji|energy|raf fiyat|tavsiye edilen|recommended shelf price)\b",
        cleaned,
        flags=re.I,
    )[0]

    parts = re.split(r"[,;•\n]+", cleaned)
    items = []

    blacklist = {
        "içerik metni okunamadı",
        "icerik metni okunamadi",
        "ingredients not read",
    }

    for part in parts:
        item = part.strip(" .:-–—\t")
        normalized = normalize_text(item)

        if not item:
            continue

        if normalized in blacklist:
            continue

        if len(item) >= 2:
            items.append(item)

    if not items:
        items.append("İçerik bilgisi sınırlı analiz edildi")

    return items[:28]


def extract_e_codes(text: str) -> list[str]:
    found = re.findall(r"\bE\s*-?\s*(\d{3,4}[A-Z]?)\b", text or "", flags=re.I)
    return sorted({"E" + f.upper() for f in found})


def health_score_from_text(e_codes: list[str], ingredients_text: str) -> tuple[int, str]:
    text = normalize_text(ingredients_text)
    score = 0

    for code in e_codes:
        code = code.upper().replace(" ", "")

        if code in HIGH_RISK_E:
            score += 25
        elif code in MEDIUM_RISK_E:
            score += 12
        else:
            score += 5

    if any(term in text for term in ["palm", "palmiye"]):
        score += 15

    if any(term in text for term in ["hidrojene", "hydrogenated", "fully hydrogenated", "tam hidrojenize"]):
        score += 20

    if any(term in text for term in ["aroma", "aroması", "aromasi", "flavouring", "flavoring", "flavourings", "flavorings", "vanillin", "vanilin"]):
        score += 12

    if any(term in text for term in ["glukoz", "fruktoz", "glucose", "fructose", "şurubu", "surubu", "syrup"]):
        score += 10

    if any(term in text for term in ["emülgatör", "emulgator", "emulsifier", "lesitin", "lecithin", "lécithine", "stabilizör", "stabilizer"]):
        score += 10

    if any(term in text for term in ["koruyucu", "preservative", "renklendirici", "colorant"]):
        score += 8

    if any(term in text for term in ["zero sugar", "sıfır şeker", "sifir seker", "şekersiz", "sekersiz"]):
        score += 22

    if any(term in text for term in ["sweetener", "sweeteners", "tatlandırıcı", "tatlandirici", "aspartame", "aspartam", "acesulfame", "asesülfam", "sucralose", "sukraloz"]):
        score += 18

    if any(term in text for term in ["phosphoric acid", "fosforik asit", "acidity regulator", "asitlik düzenleyici"]):
        score += 10

    score = min(score, 100)

    if score >= 55:
        return score, "yüksek"
    if score >= 20:
        return score, "orta"
    return score, "düşük"


def health_score_from_e_codes(e_codes: list[str]) -> tuple[int, str]:
    return health_score_from_text(e_codes, "")


def is_ocr_good_enough(text: str) -> bool:
    cleaned = normalize_text(text)

    if len(cleaned) < 35:
        return False

    keywords = [
        "içindekiler", "ingredients", "şeker", "seker", "yağ", "yag",
        "süt", "sut", "un", "aroma", "e", "palm", "kakao", "cocoa",
        "emülgatör", "emulsifier"
    ]

    if not any(k in cleaned for k in keywords):
        return False

    weird = re.findall(r"[^a-zA-ZğüşöçıİĞÜŞÖÇ0-9,.;:%()\-/\s]", text or "")
    return len(weird) < max(10, len(cleaned) * 0.15)


def _find_percent_near_alias(text: str, aliases: list[str]) -> float | None:
    for alias in aliases:
        a = re.escape(normalize_text(alias))

        patterns = [
            rf"{a}[^%]{{0,45}}%\s*(\d+(?:[\.,]\d+)?)",
            rf"{a}[^%]{{0,45}}(\d+(?:[\.,]\d+)?)\s*%",
            rf"(\d+(?:[\.,]\d+)?)\s*%[^,.;]{{0,45}}{a}",
        ]

        for pattern in patterns:
            match = re.search(pattern, text, flags=re.I)
            if match:
                try:
                    return float(match.group(1).replace(",", "."))
                except ValueError:
                    pass

    return None


def _has_aroma_for_alias(text: str, aliases: list[str]) -> bool:
    for alias in aliases:
        a = re.escape(normalize_text(alias))

        if re.search(rf"{a}\s+\w*arom\w*", text):
            return True

        if re.search(rf"\w*arom\w*[^,.;]{{0,35}}{a}", text):
            return True

    if any(word in text for word in AROMA_WORDS):
        return True

    return False


def compare_visuals_with_ingredients(
    visual_claims: list[str],
    ingredients: list[str],
) -> tuple[list[str], int]:
    text = normalize_text(" ".join(ingredients))
    mismatches = []
    score = 0

    for visual in visual_claims:
        v = normalize_text(visual)
        aliases = FOOD_SYNONYMS.get(v, [v])

        has_real_word = any(
            re.search(rf"\b{re.escape(normalize_text(alias))}\b", text)
            for alias in aliases
        )

        has_aroma = _has_aroma_for_alias(text, aliases)
        percent = _find_percent_near_alias(text, aliases)

        if has_aroma and not has_real_word:
            mismatches.append(
                f"{visual} vaadi var ancak içerikte gerçek {visual} yerine aroma ifadesi öne çıkıyor."
            )
            score += 35

        elif not has_real_word:
            mismatches.append(
                f"{visual} ambalaj/ürün vaadinde geçiyor ancak içerik listesinde açık biçimde bulunamadı."
            )
            score += 35

        elif percent is not None and percent < 5:
            mismatches.append(
                f"{visual} içerikte var ancak oranı düşük görünüyor (%{percent:g}); ambalaj vaadiyle oranı birlikte değerlendirilmelidir."
            )
            score += 20

        elif has_aroma:
            mismatches.append(
                f"{visual} içerikte geçiyor; ancak aroma/verici ifadesi de bulunduğu için gerçek içerik oranı kontrol edilmelidir."
            )
            score += 15

    if score == 0 and any(term in text for term in ATTENTION_TERMS):
        mismatches.append(
            "İçerikte aroma, palm/hidrojene yağ, tatlandırıcı veya teknik katkı ifadeleri bulunduğu için ambalaj algısı ile içerik niteliği birlikte kontrol edilmelidir."
        )
        score += 20

    if not visual_claims:
        if any(term in text for term in ATTENTION_TERMS):
            mismatches.append(
                "Ambalajda belirgin görsel vaat tespit edilemedi; ancak içerikte dikkat gerektiren teknik bileşenler bulundu."
            )
        else:
            mismatches.append(
                "Ambalaj ön yüzünde belirgin bir gıda görsel vaadi tespit edilemedi."
            )

    return mismatches[:8], min(score, 100)