import base64
from inference_sdk import InferenceHTTPClient
from app.config import settings


class YoloService:
    def __init__(self):
        self.client = InferenceHTTPClient(
            api_url="https://serverless.roboflow.com",
            api_key=settings.ROBOFLOW_API_KEY,
        )
        self.model_id = settings.ROBOFLOW_MODEL_ID

    def detect_fruits(self, image_base64: str) -> dict:
        """
        Base64 görsel alır, ambalajdaki meyve/sebzeleri tespit eder.
        Döndürür: tespit edilen sınıflar ve güven skorları
        """
        try:
            # Base64'ü geçici dosyaya yaz
            import tempfile, os
            image_bytes = base64.b64decode(image_base64)
            with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as f:
                f.write(image_bytes)
                tmp_path = f.name

            result = self.client.infer(tmp_path, model_id=self.model_id)
            os.unlink(tmp_path)

            # Sonuçları işle
            predictions = result.get("predictions", [])
            detected = {}

            for pred in predictions:
                label = pred["class"].lower()
                confidence = round(pred["confidence"], 3)
                # Aynı sınıf birden fazla tespit edilirse en yüksek skoru al
                if label not in detected or detected[label] < confidence:
                    detected[label] = confidence

            # Eşik üzerindeki tespitleri döndür
            detected_claims = [k for k, v in detected.items() if v > 0.4]

            print(f"[YOLO] Tespit edilenler: {detected}")

            return {
                "detected_claims": detected_claims,
                "scores": detected,
            }

        except Exception as e:
            print(f"[YOLO ERROR] {e}")
            return {"detected_claims": [], "scores": {}}
