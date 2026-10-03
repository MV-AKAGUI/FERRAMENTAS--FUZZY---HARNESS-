from fastapi import FastAPI, UploadFile, File
from paddleocr import PaddleOCR
import io
import numpy as np
from PIL import Image

app = FastAPI(title="API do Olho Clínico (PaddleOCR)")

# Inicializa o motor de leitura em Português
ocr = PaddleOCR(use_angle_cls=True, lang='pt')

@app.post("/ler_nota_fiscal")
async def ler_nota_fiscal(arquivo: UploadFile = File(...)):
    # Lê a imagem que o Dify vai mandar
    conteudo = await arquivo.read()
    imagem = Image.open(io.BytesIO(conteudo)).convert('RGB')
    img_array = np.array(imagem)
    img_array = img_array[:, :, ::-1].copy() # Converte para BGR
    
    # Extrai o texto mágico
    resultado = ocr.ocr(img_array, cls=True)
    texto_extraido = ""
    
    if resultado:
        for idx in range(len(resultado)):
            res = resultado[idx]
            if res is not None:
                for linha in res:
                    texto_extraido += linha[1][0] + "\n"
                    
    return {"texto": texto_extraido.strip()}
