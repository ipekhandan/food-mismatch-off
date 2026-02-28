import base64
import torch
from PIL import Image
from transformers import CLIPProcessor, CLIPModel
from io import BytesIO

THRESHOLD = 0.12

class ClipService:
    def __init__(self):
        print("🤖 CLIP modeli yükleniyor...")
        self.model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
        self.processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")
        self.model.eval()
        print("✅ CLIP hazır!")

    def analyze_image(self, image_base64: str, categories: list[str]) -> dict:
        """
        OFF API'den gelen kategorileri dinamik olarak prompt'a çevirir.
        Örn: "hazelnut-spreads" → "hazelnut on product packaging"
        """
        image_bytes = base64.b64decode(image_base64)
        image = Image.open(BytesIO(image_bytes)).convert("RGB")

        if not categories:
            return {"detected_claims": [], "scores": {}}

        # Kategorileri prompt'a çevir
        prompts = []
        for cat in categories:
            # "en:hazelnut-spreads" → "hazelnut spreads on product packaging"
            clean = cat.replace("en:", "").replace("-", " ").replace("_", " ")
            prompts.append(f"{clean} on product packaging")

        inputs = self.processor(
            text=prompts,
            images=image,
            return_tensors="pt",
            padding=True,
        )

        with torch.no_grad():
            outputs = self.model(**inputs)
            probs = outputs.logits_per_image.softmax(dim=1)[0]

        scores = {}
        detected_claims = []

        for cat, prompt, prob in zip(categories, prompts, probs.tolist()):
            clean = cat.replace("en:", "").replace("-", " ")
            scores[clean] = round(prob, 3)
            if prob > THRESHOLD:
                detected_claims.append(clean)

        # Skora göre sırala
        detected_claims = sorted(
            detected_claims,
            key=lambda x: scores[x],
            reverse=True
        )

        return {
            "detected_claims": detected_claims,
            "scores": scores,
        }
