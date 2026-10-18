# 🏗️ ANATOMIA TÉCNICA SEMANA 3
## SUGOI_CADEIA_DE_VALOR - REST APIs + Validadores + RAG + Frontend

**Data:** 2026-10-16  
**Status:** 🔴 BLOQUEADO - Aguardando DECISÃO FRONTEND  
**Arquiteto:** Dai_Vibe_Code  
**Referência:** RESUMO_INTELIGENCIA_SEMANA3.md + GRILL-ME (7 perguntas)

---

## 1️⃣ C4 DIAGRAM - CONTEXT & CONTAINER

### CONTEXT LEVEL
```
┌─────────────────────────────────────────────────────────────┐
│                    SUGOI_CADEIA_DE_VALOR                    │
│                   Expert BPM Conductor v1.0                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User (Analista/Diretor)  ←→  SUGOI API (REST)            │
│         │                           │                       │
│         └─────────────┬─────────────┘                       │
│                       │                                     │
│         ┌─────────────┼─────────────┐                       │
│         ▼             ▼             ▼                       │
│  Ollama      PostgreSQL    Kigyou       ClickSign         │
│  LLM Cascata  Vetorial    Shared Auth   (webhook)         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### CONTAINER LEVEL
```
┌──────────────────────────────────────────────────────────────┐
│                     ORACLE OCI 137.131.151.74               │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  SUGOI-API (Node.js/Fastify, Port 3001)           │   │
│  │  ├─ GET /api/v1/processos-bpm/:id                 │   │
│  │  ├─ POST /api/v1/processos-bpm (criar)            │   │
│  │  ├─ PUT /api/v1/processos-bpm/:id (editar)        │   │
│  │  ├─ POST /api/v1/validacoes/bpm                   │   │
│  │  ├─ POST /api/v1/validacoes/travelers (10 Travões)│   │
│  │  ├─ POST /api/v1/processo/aceitar (Maker/Checker) │   │
│  │  └─ POST /api/v1/processo/assinar (SHA-256 + HLB) │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                  │
│  ┌────────────────────────┼────────────────────────────┐   │
│  │                        │                            │    │
│  ▼                        ▼                            ▼    │
│  ┌──────────────────┐  ┌────────────────┐  ┌────────────┐  │
│  │ PostgreSQL       │  │ Ollama LLM     │  │ Frontend   │  │
│  │ (memoria_vetorial)  │ (Port 11434)   │  │ [TBD]      │  │
│  │                  │  │                │  │            │  │
│  │ • schema sugoi_* │  │ • DeepSeek-R1  │  │ Streamlit? │  │
│  │ • 8 tabelas BPM  │  │ • Qwen 2.5     │  │ Dify?      │  │
│  │ • pgvector (RAG) │  │ • SaulLM       │  │ Chainlit?  │  │
│  │ • shared: setor, │  │                │  │            │  │
│  │   cadeira, SoD   │  │ Cascata Ollama │  │            │  │
│  └──────────────────┘  └────────────────┘  └────────────┘  │
│  Shared with           (Paralelo S3 + S4 |                  │
│  Kigyou schema         Sequencial SoD)                      │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Caddy Gateway (HTTPS/TLS 1.3)                      │   │
│  │ • kigyou.daisugi.com.br → 3000 (Kigyou)           │   │
│  │ • sugoi.daisugi.com.br → 3001 (SUGOI)            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### COMPONENT LEVEL (API Services)

```
SUGOI-API Container
├─ Controllers
│  ├─ ProcessoBPMController (CRUD)
│  ├─ ValidacaoController (Travões)
│  └─ MakerCheckerController (Aprovação)
│
├─ Services
│  ├─ OllamaService (Cascata: DeepSeek → Qwen → SaulLM)
│  ├─ ValidadorBPMService (Estrutura, ciclos)
│  ├─ ValidadorTravoes (10 validadores em paralelo)
│  ├─ RAGService (LlamaIndex + pgvector)
│  └─ AssinaturaDigitalService (SHA-256 + HLB + Flag)
│
├─ Infraestrutura
│  ├─ PostgreSQLClient (Prisma ORM)
│  ├─ OllamaClient (HTTP requests)
│  ├─ AuthMiddleware (Google SSO + Azure AD)
│  └─ AuditoriaMiddleware (login_audit)
│
└─ Models (Prisma)
   ├─ ProcessoBPM
   ├─ NoBPM
   ├─ ArestaBPM
   ├─ TravaoExecutado
   ├─ MakerCheckerApproval
   ├─ AssinaturaDigital
   └─ ProcessoEmbedding (RAG)
```

---

## 2️⃣ SEQUENCE DIAGRAM - FLUXO BPM

### Caso 1: Criar Processo BPM (POST /api/v1/processos-bpm)

```
User (Maker)                    API                        Ollama         PostgreSQL      Kigyou
    │                            │                          │              │               │
    │─ POST /processos-bpm ─────>│                          │              │               │
    │  {nos, arestas, metadata}  │                          │              │               │
    │                            │─ Extrair contexto ──────>│              │               │
    │                            │<─ DeepSeek resposta ─────│              │               │
    │                            │  (análise estrutural)    │              │               │
    │                            │                          │              │               │
    │                            │─ Validar (paralelo) ────────────────>│               │
    │                            │  BPM ✓ HAP ✓ EAP ✓     │              │               │
    │                            │<─ OK/FAIL ────────────────────────────│               │
    │                            │                          │              │               │
    │                            │─ Validar SoD (seq) ────────────────>│               │
    │                            │  SoD rules (20) ✓       │              │               │
    │                            │<─ OK/FAIL ────────────────────────────│               │
    │                            │                          │              │               │
    │                            │─ RapidFuzz reconcil ───────────────>│               │
    │                            │  nomes, variações ✓    │              │               │
    │                            │<─ OK/FAIL ────────────────────────────│               │
    │                            │                          │              │               │
    │                            │─ Gerar embedding ─────>│              │               │
    │                            │  (nomic-embed) LlamaIdx │              │               │
    │                            │<─ vector(1536) ─────────│              │               │
    │                            │                          │              │               │
    │                            │─ Salvar em DB ────────────────────────>│               │
    │                            │  processo_bpm          │              │               │
    │                            │  estado: pendente_aprov │              │               │
    │<─ 201 Created─────────────│ {id, hash_temp}        │              │               │
    │  {processo_id}             │                          │              │               │
    │                            │                          │              │               │
    │                            │─ Notificar Kigyou ──────────────────────────────────>│
    │                            │  (audit log: Maker:id) │              │               │
    │                            │<─ ACK ────────────────────────────────────────────────│
    │                            │                          │              │               │
```

### Caso 2: Diretor Aprova (Maker/Checker - PUT /api/v1/processo/aceitar/:id)

```
Diretor (Checker)               API                        PostgreSQL
    │                            │                          │
    │─ PUT /processo/aceitar ───>│                          │
    │  {id, concordancia: true}  │                          │
    │                            │─ Validar autorização ───>│
    │                            │  (pessoa_cadeira role)  │
    │                            │<─ OK/UNAUTHORIZED ──────│
    │                            │                          │
    │                            │─ Calcular SHA-256 ────>│
    │                            │  (processo_bpm + Hora) │
    │                            │  Hora Legal Brasileira │
    │                            │<─ hash ─────────────────│
    │                            │                          │
    │                            │─ Update processo ──────>│
    │                            │  status: aprovado      │
    │                            │  flag_concordancia:true │
    │                            │  hash_assinatura       │
    │                            │  timestamp_hlb         │
    │                            │  checker_id            │
    │<─ 200 OK ────────────────│ {id, status}           │
    │  {status: aprovado}        │                          │
    │                            │─ Audit log ───────────>│
    │                            │  (login_audit:Checker) │
    │                            │<─ OK ──────────────────│
    │                            │                          │
```

---

## 3️⃣ PYDANTIC SCHEMAS (Validação)

```python
# ═══════════════════════════════════════════════════════════════════
# API Request/Response Models (Semana 3)
# ═══════════════════════════════════════════════════════════════════

from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any
from enum import Enum
from datetime import datetime
import uuid

# ────────────────────────────────────────────────────────────────────
# ENUM: Status do Processo
# ────────────────────────────────────────────────────────────────────

class StatusProcesso(str, Enum):
    DRAFT = "draft"
    PENDENTE_APROVACAO = "pendente_aprovacao"
    APROVADO = "aprovado"
    PUBLICADO = "publicado"
    REJEITADO = "rejeitado"

class TipoNo(str, Enum):
    INICIO = "inicio"
    ATIVIDADE = "atividade"
    DECISAO = "decisao"
    FIM = "fim"

# ────────────────────────────────────────────────────────────────────
# MODEL: No BPM
# ────────────────────────────────────────────────────────────────────

class NoBPMCreate(BaseModel):
    label: str = Field(..., min_length=1, max_length=255)
    tipo: TipoNo
    x: float  # Canvas coordinates
    y: float
    metadata: Optional[Dict[str, Any]] = None

class NoBPMResponse(NoBPMCreate):
    id: uuid.UUID
    processo_id: uuid.UUID
    created_at: datetime

# ────────────────────────────────────────────────────────────────────
# MODEL: Aresta BPM
# ────────────────────────────────────────────────────────────────────

class ArestaBPMCreate(BaseModel):
    no_origem_id: uuid.UUID
    no_destino_id: uuid.UUID
    condicao: Optional[Dict[str, Any]] = None  # JSON: {label, tipo}

class ArestaBPMResponse(ArestaBPMCreate):
    id: uuid.UUID
    processo_id: uuid.UUID

# ────────────────────────────────────────────────────────────────────
# MODEL: Processo BPM (Main)
# ────────────────────────────────────────────────────────────────────

class ProcessoBPMCreate(BaseModel):
    titulo: str = Field(..., min_length=3, max_length=255)
    descricao: Optional[str] = None
    setor_id: uuid.UUID
    nos: List[NoBPMCreate]
    arestas: List[ArestaBPMCreate]

    @validator('nos')
    def validar_nos_minimo(cls, v):
        if len(v) < 2:
            raise ValueError("Processo deve ter pelo menos 2 nós (início e fim)")
        return v

class ProcessoBPMResponse(ProcessoBPMCreate):
    id: uuid.UUID
    criador_id: uuid.UUID
    status: StatusProcesso
    hash_assinatura: Optional[str] = None  # SHA-256
    timestamp_assinatura: Optional[datetime] = None  # HLB
    embedding: Optional[List[float]] = None  # vector(1536)
    created_at: datetime
    updated_at: datetime

# ────────────────────────────────────────────────────────────────────
# MODEL: Resultado Validação (Travões)
# ────────────────────────────────────────────────────────────────────

class TravaoResultado(BaseModel):
    nome: str  # "BPM", "HAP", "EAP", "SoD", "RapidFuzz", etc
    passou: bool
    mensagem: str
    detalhes: Optional[Dict[str, Any]] = None
    tempo_ms: int

class ValidacaoResultado(BaseModel):
    processo_id: uuid.UUID
    travoes: List[TravaoResultado]
    passou_todos: bool
    tempo_total_ms: int
    timestamp: datetime

    @validator('passou_todos')
    def calcular_passou_todos(cls, v, values):
        if 'travoes' in values:
            return all(t.passou for t in values['travoes'])
        return v

# ────────────────────────────────────────────────────────────────────
# MODEL: Maker/Checker Approval
# ────────────────────────────────────────────────────────────────────

class MakerCheckerApproval(BaseModel):
    processo_id: uuid.UUID
    concordancia: bool  # Flag: Checker concorda?
    motivo_rejeicao: Optional[str] = None
    checker_id: uuid.UUID

class MakerCheckerApprovalResponse(MakerCheckerApproval):
    hash_assinatura: str  # SHA-256 (Hora Legal Brasileira)
    timestamp_assinatura: datetime
    status: StatusProcesso

# ────────────────────────────────────────────────────────────────────
# MODEL: Assinatura Digital
# ────────────────────────────────────────────────────────────────────

class AssinaturaDigital(BaseModel):
    processo_id: uuid.UUID
    hash_processo: str  # SHA-256(processo_json)
    timestamp_hlb: datetime  # Hora Legal Brasileira
    assinante_id: uuid.UUID
    flag_concordancia: bool
    tipo: str = "maker_checker"  # ou "clicksign" (S4)

# ────────────────────────────────────────────────────────────────────
# MODEL: RAG Query & Response
# ────────────────────────────────────────────────────────────────────

class RAGQuery(BaseModel):
    texto_busca: str = Field(..., min_length=5, max_length=1000)
    limite: int = Field(default=3, ge=1, le=10)

class ProcessoRAGResult(BaseModel):
    id: uuid.UUID
    titulo: str
    similarity_score: float  # [0.0, 1.0]
    detalhes: str

class RAGResponse(BaseModel):
    query: str
    resultados: List[ProcessoRAGResult]
    total_encontrados: int

# ────────────────────────────────────────────────────────────────────
# MODEL: Error Response (Padrão)
# ────────────────────────────────────────────────────────────────────

class ErrorResponse(BaseModel):
    code: str  # "VALIDATION_ERROR", "UNAUTHORIZED", etc
    message: str
    details: Optional[Dict[str, Any]] = None
```

---

## 4️⃣ RACI MATRIX (Semana 3)

| Atividade | Dev | Arquiteto | QA | Diretor Setor | Dir Presidente |
|---|---|---|---|---|---|
| **REST API endpoints** | **R,A** | C | I | | |
| **Ollama cascata** | **R,A** | C | C | | |
| **10 Travões** | **R,A** | C | C | | |
| **RAG + embeddings** | **R,A** | C | C | | |
| **Frontend (TBD)** | **R,A** | C | C | | |
| **Maker/Checker flow** | R | **A,C** | C | C | C |
| **SHA-256 + HLB** | **R,A** | C | C | C | |
| **Testes unitários** | A | | **R,C** | | |
| **Testes integrados** | A | C | **R,A** | | |
| **Deploy Oracle** | C | **R,A** | C | I | I |

**Legenda:** R=Responsible (faz) | A=Accountable (aprova) | C=Consulted | I=Informed

---

## 5️⃣ TECH STACK (Sem Duplicações)

### Backend
```json
{
  "runtime": "Node.js 24 + Fastify",
  "orm": "Prisma (16 modelos)",
  "database": "PostgreSQL 16 + pgvector",
  "llm_orchestration": [
    "LangChain 1.4.3 (cadeias)",
    "LangGraph 1.2.12 (grafos)"
  ],
  "rag": "LlamaIndex 0.14.25 (chunking + indexação)",
  "embeddings": "nomic-embed-text (Ollama)",
  "auth": "Google SSO + Azure AD + Magic Link (shared Kigyou)",
  "api_validation": "Pydantic (acima)"
}
```

### LLM Cascata (Ollama Local - Custo Marginal = 0)
```json
{
  "modelo_1": "DeepSeek-R1 8B (BPM logic, 95% confiança, timeout 30s)",
  "modelo_2": "Qwen 2.5 Coder 7B (algos, 85%, timeout 20s) - fallback",
  "modelo_3": "SaulLM 7B (compliance, 98%, timeout 15s) - fallback2",
  "fallback_externo": "Outra LLM open-source similar (não Gemini API)"
}
```

### Frontend 🔴 BLOQUEADO
```
⚠️ AGUARDANDO DECISÃO USER:
├─ Opção A: Streamlit (rápida, mvp, prototipagem)
├─ Opção B: Dify (visual, canvas, production)
└─ Opção C: Chainlit (conversacional, web-first)

Recomendação Dai_Vibe_Code (pendente resposta user):
```

### Infraestrutura (Confirmado)
```json
{
  "cloud": "Oracle OCI (137.131.151.74, SLA 99.9%)",
  "gateway": "Caddy (HTTPS/TLS 1.3, reverse proxy)",
  "network": "daisugi-network (shared Kigyou)",
  "logging": "CloudWatch (Oracle)",
  "audit": "login_audit (shared public schema)"
}
```

---

## 6️⃣ TIMELINE SEMANA 3

### SEGUNDA (Dia 1)
- ✅ REST API endpoints: GET/POST/PUT /processos-bpm
- ✅ OllamaService + cascata (DeepSeek → Qwen → SaulLM)
- 📊 Testes unitários Ollama (mock responses)
- **Deliverable:** API + Ollama integrados, health check ✓

### TERÇA (Dia 2)
- ✅ 10 Travões: BPM, HAP, EAP, SoD (20 rules), RapidFuzz, etc
- ✅ Paralelo (S3/S4) + Sequencial (SoD)
- ✅ ValidadorService + ValidacaoResultado schema
- 📊 Testes integrados (validadores em sequência)
- **Deliverable:** POST /validacoes/bpm operacional, todos travões passando

### QUARTA (Dia 3)
- ✅ RAG: LlamaIndex + carregamento históricos (_VERSOES_ANTERIORES)
- ✅ Embeddings: nomic-embed-text (Ollama)
- ✅ GET /processos-bpm?busca=... (similarity search)
- 📊 Testes RAG: 5-10 queries contra históricos antigos
- **Deliverable:** RAG funcionando, busca semântica operacional

### QUINTA (Dia 4)
- ✅ Frontend (TBD: Streamlit/Dify/Chainlit) integrado à API
- ✅ Canvas BPM (criar nós/arestas visualmente)
- ✅ Real-time validation durante design
- 📊 Testes E2E (criar BPM → validar → visualizar)
- **Deliverable:** Frontend renderizado, fluxo completo

### SEXTA (Dia 5)
- ✅ Maker/Checker: POST /processo/aceitar (Diretor aprova)
- ✅ SHA-256 + HLB timestamp + flag concordância
- ✅ Audit log em login_audit (Kigyou shared)
- 📊 Teste de aprovação (sem ClickSign, com flag)
- **Deliverable:** GO-LIVE GATE SEMANA 3 ✅

---

## 7️⃣ 5 GATES (Confiança + Bloqueios)

### 🟢 GATE 1: Validação Tech Stack Interno
**Status:** [ALTA 98%] ✅ PASSOU  
**Decisão:** Usar LangGraph 1.2.12 + LangChain 1.4.3 (já existem, sem duplicações)  
**Risco:** Negligible  
**Desbloqueador:** ✅

---

### 🟢 GATE 2: Cascata Ollama Fallback
**Status:** [ALTA 95%] ✅ PASSOU  
**Decisão:** DeepSeek → Qwen → SaulLM (todos open-source, Ollama)  
**Risco:** Se todos 3 falham = erro (aceitável, <1% chance)  
**Desbloqueador:** ✅

---

### 🟢 GATE 3: Assinatura Digital (SHA-256 + HLB)
**Status:** [ALTA 98%] ✅ PASSOU  
**Decisão:** Flag concordância + SHA-256 + HLB (padrão KAN-SA M4)  
**Risco:** Não é X.509 criptográfica (OK para MVP S3, X.509 é S4)  
**Desbloqueador:** ✅

---

### 🔴 GATE 4: FRONTEND CHOICE (BLOQUEADO)
**Status:** [PENDENTE] ❌ AGUARDANDO USER  
**Decisão:** ???  
**Opções:**
- **A: Streamlit** (3h, rápida, mvp-ready, prototipagem)
- **B: Dify** (5h, visual/canvas, production-ready)
- **C: Chainlit** (4h, conversacional, web-first)

**Risco por opção:**
- A: Menos visual, necessita melhorias S4
- B: Mais tempo, mas pronta para prod
- C: Chat não é ideal para BPM visual

**Desbloqueador:** ❌ USER DEVE RESPONDER

---

### 🟢 GATE 5: RAG Volume & Sensibilidade
**Status:** [ALTA 90%] ✅ PASSOU  
**Decisão:** Começar com embeddings de templates + históricos antigos (_VERSOES_ANTERIORES)  
**Risco:** Dados são institucional (não sigilo bancário), OK para pgvector  
**Desbloqueador:** ✅

---

## 📋 PRÓXIMOS PASSOS (Imediatos)

### 🔴 BLOQUEADO ATÉ "DE ACORDO" USER:

1. **Frontend:** Qual opção? (Streamlit/Dify/Chainlit)
   - Resposta esperada: "Vamos na OPÇÃO X porque..."
   - Desbloqueador: User confirma

2. (Opcional) **Validadores**: Confirmar ordem exata dos 10 Travões
   - User já respondeu: "paralelo (rápido) + sequencial (seguro)"
   - Desbloqueador: ✅ (já consolidado)

3. (Opcional) **ClickSign**: Confirmar padrão KAN-SA M4
   - User já respondeu: "use modelo KAN-SA M4 (flag concordância)"
   - Desbloqueador: ✅ (já consolidado)

---

## 📎 REFERÊNCIAS & ARTEFATOS

| Artefato | Local | Status |
|---|---|---|
| **SDD Fase 1** | output/fase1_autogen/SDD_FASE1_AUTOGEN.md | ✅ Existe |
| **Schema Prisma** | output/fase1_autogen/schema.prisma | ✅ Existe |
| **C4 Diagramas** | output/fase1_autogen/C4_DIAGRAMS.md | ✅ Existe |
| **Históricos RAG** | _VERSOES_ANTERIORES (fluxogramas HAP) | ✅ Encontrados |
| **Padrão KAN-SA** | M4 Módulo (controle de dívida) | ✅ Referenciado |
| **RACI Kigyou** | planilha PAM V03 (Maker/Checker) | ✅ Validado |

---

## 🚀 RESUMO ANATOMIA

```
┌─────────────────────────────────────────────────────────────┐
│ SEMANA 3 READY (SEM BLOCKERS TÉCNICOS)                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ ✅ REST APIs: Fastify + Prisma (SEGUNDA)                   │
│ ✅ Ollama Cascata: DeepSeek→Qwen→SaulLM (TERÇA)           │
│ ✅ 10 Travões: Paralelo+Sequencial (TERÇA)                │
│ ✅ RAG: LlamaIndex+pgvector (QUARTA)                       │
│ 🔴 Frontend: BLOQUEADO (QUINTA)                             │
│ ✅ Maker/Checker: SHA-256+HLB (SEXTA)                      │
│                                                              │
│ 4 de 5 GATES ✅ | 1 GATE BLOQUEADO 🔴 (FRONTEND)          │
│                                                              │
│ GO-LIVE GATE: SEXTA TARDE (22:00 Brasília)                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

**Assinado:** Dai_Vibe_Code (Arquiteto-Chefe)  
**Data:** 2026-10-16 | 15:45 Brasília  
**Status:** 🔴 AWAITING FRONTEND DECISION

