FROM python:3.9-slim

# Dependências do sistema para o OpenCV e PaddleOCR rodarem no Linux
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala as ferramentas pesadas isoladas do seu Windows
RUN pip install --no-cache-dir --default-timeout=1000 paddlepaddle paddleocr fastapi uvicorn python-multipart Pillow

COPY api_ocr.py /app/

CMD ["uvicorn", "api_ocr:app", "--host", "0.0.0.0", "--port", "8000"]
