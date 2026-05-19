# Bu dosya önce yerel OCR denemesi yapar. EasyOCR kurulu değilse boş döner ve Grok OCR fallback devreye girer.

_reader = None

def run_local_ocr(image_path: str) -> str:
    global _reader
    try:
        import easyocr  # type: ignore
        if _reader is None:
            _reader = easyocr.Reader(['tr', 'en'], gpu=False)
        result = _reader.readtext(image_path, detail=0, paragraph=True)
        return " ".join(result).strip()
    except Exception:
        return ""
