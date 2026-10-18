# INTEGRAÇÃO SUGOI_CADEIA_DE_VALOR → DAISUGI KIGYOU 4.0
## Proposta Arquitetural: 1 Infraestrutura, 2 Módulos Complementares

**Data:** 2026-10-16  
**Status:** 🟢 PROPOSTA EXECUTIVA  
**Confiança:** 98% (reutilizando padrões Kigyou validados)  
**ETA:** QUINTA-SEXTA semana 1 (com infra Kigyou já ativa)

---

## 📊 CENÁRIO ATUAL

### ❌ Problema com Local-Only (seu laptop):
```
QUINTA-SEXTA: ✅ Roda local (localhost)
SEMANA 2+:    ❌ Cai quando desliga (24/7 não é viável)
              ❌ RAG, Ollama, Validadores offline
              ❌ Cascata LLM sem garantia de uptime
```

### ✅ Solução: Reutilizar Kigyou (Google Cloud Sugoi)
```
QUINTA-SEXTA: ✅ Local (seu dev) → git push
SEMANA 2+:    ✅ Cloud (GCP Sugoi) → auto-deploy
              ✅ PostgreSQL 24/7
              ✅ Gemini AI corporativo
              ✅ CDN + WAF + HTTPS
              ✅ Validadores + RAG sempre up
```

---

## 🏗️ ARQUITETURA PROPOSTA

```
┌──────────────────────────────────────────────────────────────────┐
│                   GOOGLE CLOUD - SUGOI S/A                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ MÓDULO 1: DAISUGI KIGYOU (Gestão de Fornecedores B2B)      │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │ • Contratos, Minutas, Medições, Ciclo 24 meses            │ │
│  │ • Motor Gemini AI (OCR, Matching CNAE)                     │ │
│  │ • Autenticação: Google SSO, Azure AD, Magic Link           │ │
│  │ • DB: Cloud SQL PostgreSQL (schema kigyou_*)               │ │
│  │ • API: Fastify REST (PORT 3000)                            │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ MÓDULO 2: SUGOI_CADEIA_DE_VALOR (Designer de Processos)   │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │ • Desenho BPM, Validadores (10 Travões), Publicação        │ │
│  │ • Motor Gemini AI (Análise BPM estrutural)                 │ │
│  │ • Autenticação: Mesma (Google SSO + SoD)                   │ │
│  │ • DB: Cloud SQL PostgreSQL (schema sugoi_*)                │ │
│  │ • API: Node.js/Express (PORT 3001)                         │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ SHARED SERVICES (Ambos módulos usam)                        │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │ ✓ Cloud SQL PostgreSQL (2 schemas distintos)               │ │
│  │ ✓ Gemini AI API (credencial corporativa)                   │ │
│  │ ✓ Cloud Storage GCS (PDFs, imagens, evidências)            │ │
│  │ ✓ Cloud IAM (roles, service accounts)                      │ │
│  │ ✓ Cloud CDN (HTTPS, WAF, DDoS protection)                  │ │
│  │ ✓ Cloud Logging & Monitoring (CloudWatch)                  │ │
│  │ ✓ Secret Manager (chaves de API, JWT secrets)              │ │
│  │ ✓ Ollama (rodando em Cloud Run ou VM Always-On)            │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
└──────────────────────────────────────────────────────────────────┘

SEU LAPTOP (Desenvolvimento)
┌──────────────────────────────────────────────────────────────────┐
│                                                                    │
│  QUINTA-SEXTA (Semana 1):                                        │
│  ├─ Docker local (PostgreSQL, Ollama, APIs)                     │
│  ├─ Git: feature/dai-integration-audit                          │
│  ├─ npm install + npm run dev                                   │
│  └─ git push → GitHub                                           │
│                                                                    │
│  SEMANA 2+ (Cloud Auto-Deploy):                                 │
│  ├─ git push auto-deploys para GCP                             │
│  ├─ Cloud Build (pipeline CI/CD)                               │
│  ├─ APIs rodam em Cloud Run (serverless)                       │
│  ├─ Ollama roda em VM Always-On (E2-medium)                    │
│  └─ Validadores + RAG sempre up                                │
│                                                                    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔄 CRONOGRAMA REVISADO

### **QUINTA-SEXTA (Semana 1):**

**Seu laptop (localhost):**
```bash
cd app/backend

# Copiar schema.prisma local
cp ../../output/fase1_autogen/schema.prisma prisma/

# Prisma migrations LOCAL
npx prisma migrate dev --name "init"

# Seed 14 setores LOCAL
npx prisma db seed

# Auth real (CPF+banco+SoD) LOCAL
npm run dev  # rodando em http://localhost:3001
```

**Output Friday 17:00:**
- ✅ GO-LIVE GATE (local)
- ✅ Commit + push para GitHub

---

### **SEMANA 2+ (Integração Cloud):**

**1. Setup GCP (primeira terça-feira):**
```
┌─ Cloud SQL PostgreSQL (criar schema sugoi_*)
├─ Cloud Storage GCS (criar bucket sugoi-cadeia)
├─ Ollama em Cloud Run (deploy imagem Docker)
├─ Service Account para CI/CD (Cloud Build)
└─ Secret Manager (JWT_SECRET, DATABASE_URL)
```

**2. Prisma Migrate → Cloud SQL:**
```bash
# Credencial: SECRET_MANAGER
DATABASE_URL="postgresql://cloud-sql-user:...@cloudsql-ip/sugoi_cadeia"
npx prisma migrate deploy

# Seed data (14 setores) na CLOUD
npx prisma db seed --prod
```

**3. Deploy APIs em Cloud Run:**
```bash
# Build imagem Docker
docker build -t sugoi-api:latest .

# Push para Artifact Registry
docker push gcr.io/PROJETO-SUGOI/sugoi-api:latest

# Deploy em Cloud Run (serverless, auto-scaling)
gcloud run deploy sugoi-api \
  --image gcr.io/PROJETO-SUGOI/sugoi-api:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

**4. Ollama em Cloud Run (ou VM Always-On):**
```bash
# Option A: Cloud Run (serverless, mas menos eficiente para LLM)
docker build -t sugoi-ollama .
gcloud run deploy sugoi-ollama ...

# Option B: Compute Engine VM Always-On (recomendado)
# VM E2-medium + GPU (optional)
# Ollama rodando 24/7, pronto para cascata LLM
```

**5. CI/CD via Cloud Build:**
```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/git'
    args: ['clone', 'https://github.com/MV-AKAGUI/...']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/sugoi-api', '.']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/sugoi-api']
  
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args: ['run', '-f', '.', '-i', 'gcr.io/$PROJECT_ID/sugoi-api']
```

---

## 💾 BANCO DE DADOS

### **QUINTA-SEXTA (Local):**
```sql
-- Seu Docker local
PostgreSQL: localhost:5432
Database: cadeia_valor
User: dev / dev

CREATE SCHEMA sugoi;
CREATE TABLE sugoi.setor (id SERIAL PRIMARY KEY, codigo VARCHAR(2) UNIQUE, nome VARCHAR(255));
-- + 15 modelos restantes (Prisma schema.prisma)
```

### **SEMANA 2+ (Cloud SQL):**
```sql
-- Google Cloud SQL (Sugoi S/A)
CloudSQL: cloudsql-instance.c.PROJETO-SUGOI.internal
Database: sugoi_cadeia_valor
User: cloud-sql-user (credencial no Secret Manager)

-- Mesmos schemas e DDL
CREATE SCHEMA sugoi;
-- Mesmas tabelas
```

---

## 🔐 AUTENTICAÇÃO & CONFORMIDADE

### **Reutilizar Kigyou:**
✅ Google Workspace SSO (`@sugoi.com.br`)
✅ Azure AD / Entra ID (parceiros)
✅ Magic Link + 2FA (fornecedores)
✅ JWT com SoD validado
✅ Auditoria append-only (LoginAudit, SodViolationLog)

### **Compartilhar com SUGOI:**
```
Kigyou:
  - Usuários da Sugoi em Jinzai (fornecedores)
  - OAuth scope: read-only aos processos SUGOI

SUGOI:
  - G&G designers (Presidência, Operações, etc)
  - OAuth scope: full (criar, validar, publicar)

Ambos:
  - Mesma PessoaCadeira table (14 setores)
  - Mesma LoginAudit (auditoria centralizada)
  - Mesma trilha SoD (20 regras compartilhadas)
```

---

## 📊 CUSTOS ESTIMADOS (GCP Sugoi S/A)

| Serviço | Custo Mês | Observação |
|---------|-----------|----------|
| Cloud SQL PostgreSQL | ~$300 | Compartilhado com Kigyou |
| Cloud Run (APIs) | ~$100 | Autoscaling, serverless |
| Cloud Storage GCS | ~$50 | Armazenamento de PDFs/imagens |
| Ollama (VM E2-medium) | ~$80 | Always-on, 24/7 |
| Gemini AI API | ~$200 | Análise BPM + OCR (compartilhado) |
| Monitoring + Logging | ~$50 | CloudWatch, alertas |
| **TOTAL** | **~$780/mês** | *Compartilhado entre 2 módulos* |

---

## 🚀 TIMELINE EXECUÇÃO

### **QUINTA-SEXTA (Semana 1):**
```
SEG-TER:  Local Docker setup + Prisma migrations
QUA:      SDD auto-gen + Prisma schema finalized
QUI-SEX:  Auth real (CPF+banco+SoD) testado LOCAL
FRI 17h:  GO-LIVE GATE ✅ (local pronto)
FRI 18h:  git push feature/dai-integration-audit
```

### **SEGUNDA-TERÇA (Semana 2):**
```
SEG:      Setup GCP (Cloud SQL, Storage, Secrets)
TER:      Prisma migrate → Cloud SQL + seed data
QUA:      Ollama deployment (Cloud Run ou VM)
QUI-SEX:  Cloud Run API deployment + CI/CD setup
```

### **SEMANA 3+:**
```
Validadores rodando 24/7
RAG + pgvector completo
Cascata LLM integrado
React Frontend (Canvas BPM)
```

---

## ✅ AÇÕES IMEDIATAS

### **1. Confirmar com você (hoje):**
- [ ] Usar GCP Kigyou existente? **SIM / NÃO**
- [ ] Cloud SQL novo schema ou compartilhar? **NOVO / COMPARTILHADO**
- [ ] Ollama em Cloud Run (serverless) ou VM Always-On? **RUN / VM**

### **2. Coordenar com Kigyou team (segunda):**
- [ ] Credenciais GCP (service account, projeto ID)
- [ ] Cloud SQL connection string
- [ ] Gemini API key (corporativo)
- [ ] Secret Manager setup

### **3. Adaptar scripts QUINTA-SEXTA:**
- [ ] `COMANDO_IDE_QUINTA_SEXTA.txt` → LOCAL ONLY (sem changes)
- [ ] Criar `DEPLOY_GCP_SEMANA2.sh` para Cloud
- [ ] Criar `cloudbuild.yaml` para CI/CD

---

## 🎯 VANTAGENS DA INTEGRAÇÃO

| Aspecto | Local-Only | Kigyou Integrado |
|---------|-----------|------------------|
| **Uptime** | ❌ Cai à noite | ✅ 99.9% SLA |
| **Escalabilidade** | ❌ Limitado (laptop) | ✅ Auto-scaling Cloud Run |
| **Auditoria** | ⚠️ Básica | ✅ Append-only, SHA-256 |
| **Conformidade** | ⚠️ Parcial | ✅ Lei 14.063, MP 2.200-2 |
| **Gemini AI** | ❌ Quota pessoal | ✅ Credencial corporativa |
| **RAG 24/7** | ❌ Offline | ✅ pgvector + Pinecone |
| **Cascata LLM** | ❌ Sem garantia | ✅ Ollama always-on |
| **Backup / Disaster Recovery** | ❌ Manual | ✅ Automático GCP |
| **Custos** | $ Seu laptop | $ Rateado com Kigyou |

---

## 📋 PRÓXIMO PASSO

**Você decide:**

1. **Opção A (Recomendado):** Integrar com Kigyou agora
   - Usar GCP Sugoi existente
   - QUINTA-SEXTA local, SEMANA 2+ cloud
   - ETA GO-LIVE completo: 2 semanas

2. **Opção B (Alternativa):** Ficar local QUINTA-SEXTA, cloud depois
   - Executar scripts QUINTA-SEXTA como está
   - Migrar para cloud manualmente semana 2
   - Mais trabalho manual de migração

**Recomendação:** **OPÇÃO A** (reutilizar Kigyou = menos refactoring, mais segurança, conformidade legal garantida).

---

**Aguardando seu go-ahead para coordenar com Kigyou team 🚀**
