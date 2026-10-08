# 🏛️ Despacho Oficial do PMO de TI ao Dr. Taylor Code
**Documento:** PMO-HDW-2026-004  
**Data:** 08 de Outubro de 2026  
**De:** PMO de TI & Especialista em Infraestrutura de Data Warehouse  
**Para:** Dr. Taylor Code (Arquiteto-Chefe & Orquestrador de Homeostase Computacional)  
**Assunto:** Diretriz Executável de Instalação e Homologação das Ferramentas Complementares no Servidor Linux do HDW  
**Classificação:** Diretriz Operacional / Sem Downtime / Alta Concorrência Forense  

---

## 1. 📌 Contexto e Status de Implantação
A equipe de TI da SUGOI concluiu com sucesso o setup do **Hudson DW (HDW)** no servidor Linux via Docker Compose. O estado atual validado é:
* **PostgreSQL 18.6:** Ativo no banco `sugoi`, usuário `hudson`, schema `hudson` com 9 tabelas homologadas e partições do `custody_log` para 2025, 2026 e 2027 preservadas no volume `sugoi-postgres-data`;
* **Aplicação (`hudson-app`):** Ativa na porta `8000`, respondendo `HTTP 200` no endpoint `/health`, com credenciais protegidas via Docker Secrets e orquestração na rede `sugoi-net`;
* **Hudson DC (HDC):** Está provisionado e operando na nuvem **Oracle Cloud (OCI)**. Portanto, **nenhuma alteração do HDC será executada neste servidor Linux**.

---

## 2. 🛡️ Princípios de Homeostase Computacional para a Atualização
Para preservar a estabilidade da máquina e garantir zero risco aos dados já configurados:
1. **Preservação de Volumes:** Nenhuma intervenção tocará no volume `sugoi-postgres-data`. O banco de dados permanecerá operando continuamente.
2. **Rebuild Não-Destrutivo:** O contêiner `hudson-app` será atualizado de forma cirúrgica (`--no-deps`), garantindo que o PostgreSQL não reinicie nem perca o estado saudável (`service_healthy`).
3. **Pilar Anti-Alucinação (Zero LLM):** A biblioteca forense operará de forma 100% determinística através de assinaturas binárias (*Magic Bytes*), extração de texto estruturada e reconciliação difusa (*RapidFuzz*).

---

## 3. ⚙️ Instruções Técnicas para a Equipe de Engenharia do Dr. Taylor

### ETAPA A: No Host Linux (Binários do Sistema & Python 3.11)
Como a leitura inicial de HDs físicos externos de canteiros de obra (pastas pesadas com centenas de gigabytes) é realizada diretamente no Host montado em `/mnt/hd_externo`, o Linux precisa de suporte nativo:

```bash
# A.1 Binários C/C++ de Baixo Nível
sudo apt-get update -y
sudo apt-get install -y \
    unrar \
    p7zip-full \
    p7zip-rar \
    libreoffice-nogui \
    libmagic1 \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-por \
    libgl1 \
    libglib2.0-0

# A.2 Instalação no Ambiente Python 3.11 do Servidor
pip3.11 install --upgrade pip
pip3.11 install \
    rarfile \
    py7zr \
    pdfplumber \
    pypdfium2 \
    pikepdf \
    python-docx \
    openpyxl \
    rapidfuzz \
    python-magic \
    unidecode \
    docling \
    rapidocr-onnxruntime
```

---

### ETAPA B: No Contêiner da Aplicação (`hudson-app`)
Para que o serviço web do HDW (porta 8000) processe arquivos enviados via API:

1. **Atualizar o `Dockerfile` do `hudson-app` adicionando os utilitários:**
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends \
       unrar p7zip-full libreoffice-nogui libmagic1 poppler-utils \
       && rm -rf /var/lib/apt/lists/*
   ```

2. **Adicionar no `requirements.txt` da aplicação:**
   ```text
   rarfile>=4.5
   py7zr>=1.1.3
   pdfplumber>=0.11.10
   pikepdf>=10.16.0
   python-docx>=1.2.0
   openpyxl>=3.1.5
   rapidfuzz>=3.14.6
   python-magic>=0.4.27
   unidecode>=1.3.8
   docling>=2.133.0
   rapidocr-onnxruntime>=1.3.0
   ```

3. **Rebuild Cirúrgico (Sem Reiniciar o Banco de Dados):**
   ```bash
   docker compose up -d --no-deps --build hudson-app
   ```

---

### ETAPA C: Carga dos Módulos Forenses no Código do HDW
Copiar do repositório `FERRAMENTAS--FUZZY---HARNESS-` para o backend do HDW (`/home/HUDSON/backend/app/forense/`):
* **`hudson_desbloqueador.py`:** Motor de desbloqueio para PDF protegido (`pikepdf`), Word/Excel protegidos (remoção cirúrgica de `<w:documentProtection>` e `<sheetProtection>` em XML) e compactados RAR/ZIP/7Z.
* **`hudson_leitor_escalado.py`:** Identificação real de conteúdo por *Magic Bytes* via `libmagic`, acionando `Docling` e `RapidOCR` antes da extensão.
* **`hudson_whitelist_sistema.py`:** Filtro anti-fantasmas que rejeita `Thumbs.db`, `.DS_Store`, temporários `~$*` e binários `.exe`.

---

### ETAPA D: Atualização Não-Destrutiva do Schema no PostgreSQL 18.6
Para garantir que o `RapidFuzz` localize termos pesquisados pelos usuários no histórico com tolerância a erros e acentos:

```sql
-- Executar no banco 'sugoi', schema 'hudson':
ALTER TABLE hudson.custody_log ADD COLUMN IF NOT EXISTS nome_arquivo_original VARCHAR(500);
ALTER TABLE hudson.custody_log ADD COLUMN IF NOT EXISTS nome_arquivo_normalizado VARCHAR(500);
ALTER TABLE hudson.custody_log ADD COLUMN IF NOT EXISTS status_desbloqueio VARCHAR(50) DEFAULT 'original';

CREATE INDEX IF NOT EXISTS idx_custody_nome_norm ON hudson.custody_log(nome_arquivo_normalizado);
```

---

## 4. 🧪 Protocolo de Homologação em 1 Linha (Smoke Test)
Após a conclusão dos comandos, o Engenheiro de Software deverá rodar:

```bash
docker exec -it hudson-app python -c "
import docling, rapidfuzz, magic, unidecode, rarfile, py7zr, pikepdf, pdfplumber, openpyxl, docx
import shutil

print('>>> TESTE DE INTEGRIDADE DAS FERRAMENTAS DO HDW <<<')
print('✅ Bibliotecas Python 3.11 carregadas com sucesso!')

for b in ['unrar', '7z', 'soffice', 'file', 'pdfimages']:
    p = shutil.which(b)
    print(f'{\"✅\" if p else \"⚠️\"} Binário Linux {b}: {p or \"NÃO ENCONTRADO\"}')
"
```

---

## 5. 🎯 Conclusão e Próximo Passo
Com este despacho entregue, o Dr. Taylor Code e seus engenheiros têm o roteiro exato para guiar o time de infraestrutura da SUGOI a atualizar o Linux sem riscos de regressão, garantindo que o Hudson DW atinja o nível máximo de prontidão operacional.

**Aprovado por:** PMO de TI & Especialista em DW  
**Distribuição:** Dr. Taylor Code, Equipe de Engenharia, Repositório Central DAISUGI
