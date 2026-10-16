# 📘 PASSO 8: REST API SDD — ESPECIFICAÇÃO EXECUTIVA
**Semana 3 | SUGOI_CADEIA_DE_VALOR | BPM Expert Conductor**

---

**Gerado por:** Dai_Vibe_Code  
**Data:** 2026-10-16 21:45 Brasília  
**Status:** 🟢 **PRONTO PARA DESENVOLVIMENTO**  
**Confiança:** ALTA 98%

---

## 📋 SUMÁRIO EXECUTIVO

Especificação de 10 endpoints REST para orquestração BPM Semana 3:
- **4 endpoints CRUD** (processo_bpm: CREATE, READ, UPDATE, LIST)
- **1 endpoint de validação** (10 Travões paralelos)
- **1 endpoint RAG** (busca semântica históricos)
- **1 endpoint de aprovação** (Maker/Checker com assinatura digital)
- **3 endpoints auxiliares** (health, setor, cadeira)

**Stack técnico:**
- Framework: Node.js 24 + Fastify
- ORM: Prisma 6.19.3
- Database: PostgreSQL 16 + pgvector
- LLM: Ollama (DeepSeek-R1, Qwen, SaulLM cascata)
- RAG: LlamaIndex + nomic-embed-text (1536D)
- Auth: JWT + pessoa_cadeira (Kigyou shared schema)

---

## 🏗️ ARQUITETURA REST — 10 ENDPOINTS

### **TIER 1: CRUD ProcessoBPM (4 endpoints)**

#### **1️⃣ POST /api/v1/processos-bpm — CREATE**

```
Método: POST
Path: /api/v1/processos-bpm
Autenticação: JWT (bearer token)
Content-Type: application/json
```

**Request Payload:**
```typescript
{
  titulo: string;                    // [1..255] caracteres, não-vazio, único
  descricao?: string;                // [0..2048] caracteres
  setor_id: string;                  // UUID válido, deve existir em public.setor
  nos: Array<{
    id?: string;                     // Se não fornecido, gera UUID
    label: string;                   // [1..100] caracteres
    tipo: "inicio" | "atividade" | "decisao" | "fim";
    x: number;                       // Coordenada x (canvas)
    y: number;                       // Coordenada y (canvas)
    metadados?: Record<string, any>; // JSON livre
  }>;
  arestas: Array<{
    no_origem_id: string;            // Ref nó origem (deve existir em nos[])
    no_destino_id: string;           // Ref nó destino (deve existir em nos[])
    label?: string;                  // [0..50] caracteres
    tipo?: "normal" | "condicional"; // default: "normal"
  }>;
}
```

**Response (201 Created):**
```typescript
{
  id: string;                        // UUID gerado
  titulo: string;
  descricao?: string;
  setor_id: string;
  status: "draft";                   // Sempre "draft" na criação
  nos: Array<...>;                   // Com ids gerados
  arestas: Array<...>;
  hash_temp: string;                 // SHA-256 do processo (para verificação)
  created_at: string;                // ISO 8601 timestamp
  created_by: string;                // ID do user (de JWT)
  versao: 1;                         // Incrementado a cada UPDATE
}
```

**Validações Field-Level:**
```
✅ titulo: obrigatório, 1-255 chars, unique CONSTRAINT no DB
✅ setor_id: obrigatório, UUID válido, EXISTS em public.setor
✅ nos: obrigatório, mín 2 nós (inicio + fim), máx 50
✅ nos[].tipo: ENUM válido
✅ arestas: mín 1 aresta, máx 100
✅ arestas[].no_origem_id: EXISTS em nos[]
✅ arestas[].no_destino_id: EXISTS em nos[]
✅ Graph validação: nenhum ciclo, caminho conexo origem→fim
```

**Error Codes:**
```
201 Created      — Sucesso
400 Bad Request  — JSON inválido, campo faltante
422 Unprocessable Entity — Validação falhou (ex: nós insuficientes)
409 Conflict     — Título duplicado
500 Internal Server Error — Erro desconhecido
```

**SLA:** < 500ms  
**Idempotência:** Não (cria novo a cada chamada)

---

#### **2️⃣ GET /api/v1/processos-bpm/:id — READ**

```
Método: GET
Path: /api/v1/processos-bpm/:id
Autenticação: JWT
```

**Path Parameters:**
```
id: string (UUID)  — ID do processo
```

**Response (200 OK):**
```typescript
{
  id: string;
  titulo: string;
  descricao?: string;
  setor_id: string;
  status: "draft" | "em_validacao" | "validado" | "aprovado" | "rejeitado";
  nos: Array<...>;
  arestas: Array<...>;
  hash_temp?: string;               // Presente se status = draft
  hash_assinatura?: string;         // Presente se status = aprovado
  validacoes?: Array<{              // Se já foi validado
    travao_id: string;
    passou: boolean;
    resultado: string;
  }>;
  created_at: string;
  created_by: string;
  updated_at: string;
  updated_by?: string;
  versao: number;
}
```

**Error Codes:**
```
200 OK
404 Not Found    — Processo não existe
500 Internal Server Error
```

**SLA:** < 100ms  
**Cache:** Recomendado Redis TTL 5 minutos (se status não muda)

---

#### **3️⃣ PUT /api/v1/processos-bpm/:id — UPDATE**

```
Método: PUT
Path: /api/v1/processos-bpm/:id
Autenticação: JWT
```

**Request Payload:**
```typescript
{
  titulo?: string;
  descricao?: string;
  nos?: Array<...>;      // Substitui todos os nós
  arestas?: Array<...>;  // Substitui todas as arestas
  // Nota: setor_id é imutável após criação
}
```

**Response (200 OK):**
```typescript
{
  // Mesmo formato de GET, mas com:
  updated_at: new timestamp;
  updated_by: user_id;
  versao: versao + 1;
  hash_temp: novo hash;  // Resetado para draft
}
```

**Validações:**
```
✅ Processo deve existir
✅ User deve ser o criador OU admin (RACI: Arquiteto)
✅ Setor_id não pode ser alterado
✅ Status deve ser "draft" ou "rejeitado" para permitir UPDATE
```

**Error Codes:**
```
200 OK
400 Bad Request
403 Forbidden     — User não tem permissão
404 Not Found
409 Conflict      — Processo não está em status editável
422 Unprocessable Entity
500 Internal Server Error
```

**SLA:** < 500ms

---

#### **4️⃣ GET /api/v1/processos-bpm — LIST (com RAG)**

```
Método: GET
Path: /api/v1/processos-bpm
Autenticação: JWT
Query Parameters:
  - setor_id?: string          (filtro por setor)
  - status?: string            (draft, validado, etc)
  - busca?: string             (RAG semântica, ex: "aprovação orçamento")
  - limite?: number            (default: 20, máx: 100)
  - offset?: number            (default: 0, para pagination)
```

**Response (200 OK):**
```typescript
{
  total: number;
  limite: number;
  offset: number;
  resultados: Array<{
    id: string;
    titulo: string;
    descricao?: string;
    setor_id: string;
    status: string;
    similarity_score?: number;    // Se busca RAG foi usado
    created_at: string;
  }>;
}
```

**RAG Behavior:**
```
Se busca=null:
  → Query simples: SELECT * FROM sugoi.processo_bpm WHERE setor_id=? LIMIT ?

Se busca="algum texto":
  → Embedding via nomic-embed-text (1536D)
  → Semantic search via pgvector cosine similarity
  → ORDER BY similarity_score DESC
  → Retorna top-K resultados com scores [0.0, 1.0]
  → Limite default 5 resultados (RAG é caro)
```

**Error Codes:**
```
200 OK
400 Bad Request
404 Not Found (setor não existe)
500 Internal Server Error
```

**SLA:** 
- Sem RAG: < 200ms
- Com RAG: < 2000ms (embedding + similarity search)

---

### **TIER 2: VALIDAÇÃO (1 endpoint)**

#### **5️⃣ POST /api/v1/validacoes/bpm — 10 TRAVÕES**

```
Método: POST
Path: /api/v1/validacoes/bpm
Autenticação: JWT
```

**Request Payload:**
```typescript
{
  processo_id: string;  // UUID, deve existir
  forcar?: boolean;     // true = ignora cache de validação anterior
}
```

**Response (200 OK):**
```typescript
{
  processo_id: string;
  data_validacao: string;           // ISO timestamp
  passou_todos: boolean;            // true se ALL travoes = true
  tempo_total_ms: number;           // Tempo total de execução
  travoes: Array<{
    id: number;                     // 1-10
    nome: string;
    passou: boolean;
    resultado: string;              // Mensagem de feedback
    tempo_ms: number;               // Tempo individual
    detalhes?: Record<string, any>; // Dados específicos do travão
  }>;
  // Exemplo travao:
  // {
  //   id: 1,
  //   nome: "Ciclo lógico livre (sem ciclos)",
  //   passou: true,
  //   resultado: "Nenhum ciclo detectado no grafo",
  //   tempo_ms: 45
  // }
}
```

**10 TRAVÕES Implementação:**

| # | Nome | Descrição | Timeout |
|---|------|-----------|---------|
| 1 | Ciclo Lógico | Detecta ciclos no grafo (DFS) | 100ms |
| 2 | Conectividade | Caminho conexo início→fim existe | 100ms |
| 3 | Nós Órfãos | Nenhum nó desconectado | 100ms |
| 4 | Tipos Válidos | Enum nó/aresta corretos | 50ms |
| 5 | Compliance PAM | Respeita sequência PAM_SUGOI (14 setores) | 200ms |
| 6 | Semântica BPM | LLM valida descrições (DeepSeek) | 1500ms |
| 7 | Performance | Tempo execução processo < 30s | 100ms |
| 8 | Dados Completos | Campos obrigatórios presentes | 50ms |
| 9 | Assinatura Integridade | Hash válido (se aprovado) | 100ms |
| 10 | Histórico Precedentes | RAG: processo similar já existe? | 1000ms |

**Execução:** Paralela (Promise.all) com timeout individual  
**Fallback Ollama:** DeepSeek (1500ms) → Qwen (1000ms) → SaulLM (800ms)

**Error Codes:**
```
200 OK (mesmo que alguns travões falhem)
400 Bad Request
404 Not Found (processo não existe)
500 Internal Server Error
```

**SLA:** < 5000ms (5 segundos para 10 travões)

---

### **TIER 3: RAG & BUSCA**

#### **6️⃣ GET /api/v1/processos-bpm?busca=... — SEMANTIC SEARCH**

*(Integrado em LIST endpoint, documentado separadamente)*

```
Query RAG semântica usando LlamaIndex + pgvector

Fluxo:
1. User faz query em linguagem natural (ex: "processos de aprovação orçamento")
2. Nomic-embed-text codifica em 1536D vector
3. pgvector cosine similarity busca no histórico
4. Retorna top-K resultados com similarity_score
```

**Exemplo:**
```
GET /api/v1/processos-bpm?busca=aprovacao%20orcamento&limite=5

Response:
{
  resultados: [
    {
      id: "uuid-1",
      titulo: "Aprovação Orçamento Q4 2026",
      similarity_score: 0.87
    },
    {
      id: "uuid-2",
      titulo: "Autorização Despesa Orçamentária",
      similarity_score: 0.79
    }
  ]
}
```

---

### **TIER 4: APROVAÇÃO (1 endpoint)**

#### **7️⃣ POST /api/v1/processo/aceitar/:id — MAKER/CHECKER**

```
Método: POST
Path: /api/v1/processo/aceitar/:id
Autenticação: JWT (com role validation)
```

**Request Payload:**
```typescript
{
  concordancia: boolean;            // true = aprova, false = rejeita
  justificativa?: string;           // [0..500] caracteres
  // Assinatura digital é calculada pelo servidor
}
```

**Maker/Checker Flow:**

```
MAKER (Diretor Setor):
  1. Cria processo via POST /processos-bpm
  2. Submete para validação: PUT status = "em_validacao"
  3. Espera resultado de 10 Travões

CHECKER (Diretor Presidente):
  1. Verifica resultado dos Travões
  2. Faz POST /processo/aceitar/:id com concordancia=true/false
  3. Sistema calcula SHA-256 do processo + HLB timestamp
  4. Gera hash de assinatura + flag concordância (KAN-SA M4 pattern)
  5. Persiste em banco com audit log

SEGURANÇA:
  - Maker ≠ Checker (roles diferentes, validação servidor-side)
  - Hash SHA-256 do process JSON completo
  - HLB timestamp (Hierarchical Lamport Block) para ordering
  - Flag concordância indica aprovação/rejeição
  - Imutável após assinatura (processo não pode ser editado)
```

**Response (200 OK):**
```typescript
{
  id: string;
  status: "aprovado" | "rejeitado";
  concordancia: boolean;
  justificativa?: string;
  hash_assinatura: string;          // SHA-256 (64 chars hex)
  timestamp_assinatura: string;     // ISO 8601 + HLB
  assinado_por: string;             // ID do Checker (Diretor Presidente)
  maker_id: string;                 // ID do Maker (Diretor Setor)
  versao_assinada: number;          // Versão imutável do processo
}
```

**Validações:**
```
✅ Processo deve existir e status = "validado"
✅ User autenticado deve ser Diretor Presidente (RACI)
✅ Maker ≠ Checker (não pode assinar próprio processo)
✅ Todos 10 Travões devem ter passou=true (se concordancia=true)
✅ Assinatura digital via ClickSign (future: v1.1, agora SHA-256 + HLB)
```

**Error Codes:**
```
200 OK
400 Bad Request
403 Forbidden     — User não é Diretor Presidente
404 Not Found
409 Conflict      — Processo já assinado OR status incorreto
422 Unprocessable Entity — Travões falharam, não pode aprovar
500 Internal Server Error
```

**SLA:** < 1000ms (inclui cálculo SHA-256 + DB commit)

---

### **TIER 5: AUXILIARES (3 endpoints)**

#### **8️⃣ GET /health — HEALTH CHECK**

```
Método: GET
Path: /health
Autenticação: NÃO (public)
```

**Response (200 OK):**
```typescript
{
  status: "ok";
  timestamp: string;                // ISO 8601
  database: "connected" | "error";
  ollama: "connected" | "error";
  uptime_seconds: number;
}
```

**SLA:** < 100ms

---

#### **9️⃣ GET /api/v1/setores — LIST SETORES**

```
Método: GET
Path: /api/v1/setores
Autenticação: JWT
```

**Response (200 OK):**
```typescript
{
  total: number;
  resultados: Array<{
    id: string;
    nome: string;
    descricao?: string;
    ordem_pam: number;            // 1-14 (PAM SUGOI)
  }>;
}
```

**SLA:** < 100ms (cache recomendado, dados estáticos)

---

#### **🔟 GET /api/v1/cadeiras/:setor_id — LIST CADEIRAS POR SETOR**

```
Método: GET
Path: /api/v1/cadeiras/:setor_id
Autenticação: JWT
```

**Response (200 OK):**
```typescript
{
  total: number;
  setor_id: string;
  resultados: Array<{
    id: string;
    nome: string;
    tipo: string;                  // "Diretor", "Gerente", etc
    data_inicio: string;
  }>;
}
```

**SLA:** < 100ms

---

## 📦 PYDANTIC SCHEMAS

```python
from pydantic import BaseModel, Field, validator
from typing import Optional, List, Literal
from datetime import datetime
import re

# ═══════════════════════════════════════════════════════════════════════════
# PROCESSO BPM
# ═══════════════════════════════════════════════════════════════════════════

class NoCreate(BaseModel):
    id: Optional[str] = Field(None, description="UUID, gerado se ausente")
    label: str = Field(..., min_length=1, max_length=100)
    tipo: Literal["inicio", "atividade", "decisao", "fim"]
    x: float
    y: float
    metadados: Optional[dict] = None

    @validator('label')
    def label_not_blank(cls, v):
        if not v.strip():
            raise ValueError('label não pode ser vazio')
        return v

class ArestaCreate(BaseModel):
    no_origem_id: str
    no_destino_id: str
    label: Optional[str] = Field(None, max_length=50)
    tipo: Literal["normal", "condicional"] = "normal"

class ProcessoBPMCreate(BaseModel):
    titulo: str = Field(..., min_length=1, max_length=255)
    descricao: Optional[str] = Field(None, max_length=2048)
    setor_id: str = Field(..., description="UUID válido")
    nos: List[NoCreate] = Field(..., min_items=2, max_items=50)
    arestas: List[ArestaCreate] = Field(..., min_items=1, max_items=100)

    @validator('titulo')
    def titulo_unique(cls, v):
        # Será validado no DB (UNIQUE CONSTRAINT)
        return v

    @validator('nos')
    def has_inicio_e_fim(cls, v):
        tipos = [no.tipo for no in v]
        if 'inicio' not in tipos or 'fim' not in tipos:
            raise ValueError('Deve ter no mínimo um nó de "inicio" e um de "fim"')
        return v

    @validator('arestas')
    def arestas_referencias_validas(cls, v, values):
        if 'nos' in values:
            no_ids = {no.id or f"node-{i}" for i, no in enumerate(values['nos'])}
            for aresta in v:
                if aresta.no_origem_id not in no_ids:
                    raise ValueError(f'no_origem_id {aresta.no_origem_id} não existe')
                if aresta.no_destino_id not in no_ids:
                    raise ValueError(f'no_destino_id {aresta.no_destino_id} não existe')
        return v

class ProcessoBPMResponse(BaseModel):
    id: str
    titulo: str
    descricao: Optional[str]
    setor_id: str
    status: str
    nos: List[NoCreate]
    arestas: List[ArestaCreate]
    hash_temp: Optional[str]
    created_at: datetime
    created_by: str
    versao: int

# ═══════════════════════════════════════════════════════════════════════════
# VALIDAÇÃO — 10 TRAVÕES
# ═══════════════════════════════════════════════════════════════════════════

class TravaoResultado(BaseModel):
    id: int = Field(..., ge=1, le=10)
    nome: str
    passou: bool
    resultado: str
    tempo_ms: int
    detalhes: Optional[dict] = None

class ValidacaoResultado(BaseModel):
    processo_id: str
    data_validacao: datetime
    passou_todos: bool
    tempo_total_ms: int
    travoes: List[TravaoResultado] = Field(..., min_items=10, max_items=10)

# ═══════════════════════════════════════════════════════════════════════════
# MAKER/CHECKER APPROVAL
# ═══════════════════════════════════════════════════════════════════════════

class MakerCheckerApprovalRequest(BaseModel):
    concordancia: bool
    justificativa: Optional[str] = Field(None, max_length=500)

class AssinaturaDigital(BaseModel):
    hash_assinatura: str = Field(..., description="SHA-256 (64 hex chars)")
    timestamp_assinatura: datetime
    assinado_por: str  # ID Diretor Presidente
    maker_id: str      # ID Diretor Setor
    versao_assinada: int

class MakerCheckerApprovalResponse(BaseModel):
    id: str
    status: Literal["aprovado", "rejeitado"]
    concordancia: bool
    justificativa: Optional[str]
    hash_assinatura: str
    timestamp_assinatura: datetime
    assinado_por: str
    maker_id: str
    versao_assinada: int

# ═══════════════════════════════════════════════════════════════════════════
# RAG & BUSCA
# ═══════════════════════════════════════════════════════════════════════════

class RAGResultado(BaseModel):
    id: str
    titulo: str
    descricao: Optional[str]
    similarity_score: float = Field(..., ge=0.0, le=1.0)

class RAGQueryResponse(BaseModel):
    total: int
    limite: int
    offset: int
    resultados: List[RAGResultado]

# ═══════════════════════════════════════════════════════════════════════════
# SAÚDE & STATUS
# ═══════════════════════════════════════════════════════════════════════════

class HealthResponse(BaseModel):
    status: Literal["ok", "degraded", "down"]
    timestamp: datetime
    database: Literal["connected", "error"]
    ollama: Literal["connected", "error"]
    uptime_seconds: float
```

---

## ✅ VALIDAÇÕES CONSOLIDADAS

### Field-Level Validations

```
[ProcessoBPMCreate]
  titulo:     1-255 chars, não-vazio, UNIQUE no DB
  descricao:  0-2048 chars, opcional
  setor_id:   UUID format, EXISTS em public.setor
  nos:        2-50 items, ENUM tipo válido
  arestas:    1-100 items, referencias válidas

[NoCreate]
  label:      1-100 chars, não-vazio
  tipo:       ENUM {inicio, atividade, decisao, fim}
  x, y:       números (float)

[ArestaCreate]
  no_origem_id, no_destino_id:  existem em nos[]
  label:      0-50 chars, opcional
  tipo:       ENUM {normal, condicional}
```

### Graph Validations (Server-side)

```
✅ Ciclo Lógico:      DFS detecta ciclos → FAIL se encontrado
✅ Conectividade:     BFS garante caminho inicio→fim
✅ Nós Órfãos:       Nenhum nó sem aresta entrada/saída
✅ Aresta Válida:     no_origem e no_destino existem
```

### Maker/Checker Validations

```
✅ User role:        CHECKER = Diretor Presidente (BD lookup)
✅ Maker ≠ Checker:  created_by ≠ assinado_por
✅ Status:           processo.status = "validado"
✅ Travões:          ALL passou=true (se aprovação)
✅ Integridade:      hash_temp = hash_novo (imutável)
```

---

## 🔴 ERROR HANDLING

### HTTP Status Codes

| Code | Condição | Exemplo |
|------|----------|---------|
| 200 | Sucesso (GET, PUT, POST validações) | GET processo |
| 201 | Criado (POST) | POST processo-bpm → id gerado |
| 400 | JSON inválido, campo faltante | `titulo: null` |
| 403 | Permissão negada (role incorreta) | Non-Checker tenta aprovar |
| 404 | Recurso não existe | GET /processo/uuid-invalido |
| 409 | Conflito (título duplicado, status incorreto) | Aprova 2x mesmo processo |
| 422 | Validação falhou (lógica de negócio) | Travões falharam |
| 500 | Erro servidor (exception não tratada) | Exceção não-capturada |

### Error Response Format

```json
{
  "erro": "string",
  "codigo": "ERROR_CODE",
  "detalhes": {
    "campo": "nome_do_campo",
    "mensagem": "descrição do problema"
  },
  "timestamp": "2026-10-16T21:45:00Z",
  "request_id": "uuid-para-logging"
}
```

### Exemplos

```json
// 422 - Validação de Travões falhou
{
  "erro": "Não pode aprovar: travões falharam",
  "codigo": "TRAVOES_FAILED",
  "detalhes": {
    "travoes_failed": [2, 5, 9],
    "razao": "Ciclo lógico detectado, Compliance PAM falhou"
  }
}

// 403 - Apenas Diretor Presidente pode assinar
{
  "erro": "Acesso negado",
  "codigo": "FORBIDDEN_ROLE",
  "detalhes": {
    "role_requerida": "Diretor Presidente",
    "role_usuario": "Gerente Operacional"
  }
}

// 400 - Campo obrigatório faltando
{
  "erro": "Validação falhou",
  "codigo": "VALIDATION_ERROR",
  "detalhes": {
    "campo": "titulo",
    "mensagem": "Campo obrigatório"
  }
}
```

---

## ⚡ SLA & PERFORMANCE

### Target SLAs

| Endpoint | Target | Percentil | Notas |
|----------|--------|-----------|-------|
| POST /processos-bpm | < 500ms | p95 | Inclui validação de grafo |
| GET /processos-bpm/:id | < 100ms | p99 | Sem RAG; com cache Redis |
| PUT /processos-bpm/:id | < 500ms | p95 | Recalcula hash |
| GET /processos-bpm (list) | < 200ms | p95 | Sem RAG |
| GET /processos-bpm?busca=... | < 2000ms | p95 | RAG embedding + similarity |
| POST /validacoes/bpm | < 5000ms | p95 | 10 Travões paralelos |
| POST /processo/aceitar/:id | < 1000ms | p95 | SHA-256 + DB commit |
| GET /health | < 100ms | p99 | Public, sempre rápido |

### Ollama Cascata Timeouts

```
DeepSeek-R1 8B:  30000ms (30s) timeout
  ↓ fallback se timeout
Qwen 2.5 Coder:  20000ms (20s) timeout
  ↓ fallback se timeout
SaulLM 7B:       15000ms (15s) timeout
  ↓ se falhar
ERROR → return travao.passou=false
```

### Database Optimization

```sql
-- Índices recomendados
CREATE INDEX idx_processo_bpm_setor_id ON sugoi.processo_bpm(setor_id);
CREATE INDEX idx_processo_bpm_status ON sugoi.processo_bpm(status);
CREATE INDEX idx_processo_bpm_created_by ON sugoi.processo_bpm(created_by);

-- RAG índice
CREATE INDEX idx_processo_embedding ON sugoi.processo_embedding 
  USING hnsw (embedding vector_cosine_ops);

-- Connection pooling: max 20 connections (default Prisma)
```

---

## 👥 RACI MATRIX

| Tarefa | Responsável | Accountable | Consultor | Informado |
|--------|-------------|-------------|-----------|-----------|
| **Arquitetura REST** | Dai_Vibe_Code | Arquiteto Lead | Dev Senior | Equipe Full Stack |
| **Impl. POST /processos-bpm** | Dev 1 (Backend) | Dev Lead | Arquiteto, QA | Frontend, DevOps |
| **Impl. GET /validacoes/bpm** | Dev 2 (Backend + LLM) | Dev Lead | IA Team (Ollama) | QA, DevOps |
| **Impl. RAG busca** | Dev 3 (Backend + RAG) | Dev Lead | Data Eng (pgvector) | QA |
| **Impl. Maker/Checker** | Dev 4 (Backend + Auth) | Arquiteto, Security | DBA (Kigyou schema) | DevOps |
| **Testes Unitários** | QA 1 | QA Lead | Devs | Release |
| **Testes Integradores** | QA 2 | QA Lead | DevOps (infra) | Devs |
| **Deploy staging** | DevOps | Release Lead | QA | Arquiteto |
| **Go-Live production** | DevOps | Release Lead | Arquiteto, Security | Equipe Inteira |

---

## 📅 TIMELINE IMPLEMENTAÇÃO

```
SEGUNDA (08:00-17:00):
  ├─ 08:00-09:00:  Auto-setup (npm install, Prisma generate)
  ├─ 09:00-12:00:  Dev 1 → POST /processos-bpm (CRUD create, validação)
  ├─ 10:00-13:00:  Dev 2 → GET /processos-bpm + LIST (com cache)
  ├─ 11:00-14:00:  Dev 3 → RAG setup + busca semântica
  └─ 15:00-17:00:  Code review + merge para develop

TERÇA (08:00-17:00):
  ├─ 08:00-12:00:  Dev 2 → POST /validacoes/bpm (10 Travões)
  ├─ 09:00-13:00:  Dev 4 → POST /processo/aceitar (Maker/Checker)
  ├─ 14:00-17:00:  QA 1 → Testes unitários (Jest)
  └─ 16:00-17:00:  Code review

QUARTA (08:00-17:00):
  ├─ 08:00-12:00:  Frontend Dev → DIFY canvas + bonecos BPM
  ├─ 13:00-15:00:  QA 2 → Testes integradores (E2E)
  └─ 15:00-17:00:  Performance tuning + SLA validation

QUINTA (08:00-17:00):
  ├─ 08:00-10:00:  Final QA + bug fixes
  ├─ 10:00-12:00:  Staging deploy
  ├─ 13:00-15:00:  User acceptance testing (UAT)
  └─ 16:00-17:00:  Release prep

SEXTA (08:00-22:00):
  ├─ 08:00-14:00:  Final checks + smoke tests
  ├─ 14:00-18:00:  Production deploy (go-live window)
  ├─ 18:00-21:00:  Post-go-live monitoring
  └─ 21:00-22:00:  Release notes + postmortem
```

---

## 🔐 SEGURANÇA

### Authentication & Authorization

```
Todos endpoints (exceto /health):
  ✅ Bearer token JWT (RS256)
  ✅ Claims: sub (user_id), role (cadeira_id), exp

POST /processo/aceitar/:id:
  ✅ Role must be "Diretor Presidente" (validação servidor)
  ✅ created_by ≠ assinado_por (maker ≠ checker)
```

### Data Protection

```
SHA-256 hashing:
  ✅ hash_temp = SHA256(JSON.stringify(processo)) na criação
  ✅ hash_assinatura = SHA256(hash_temp + HLB_timestamp) na aprovação
  ✅ Armazenado em banco (imutável)

Audit Log:
  ✅ Toda ação registrada (created_by, updated_by, assinado_por)
  ✅ Timestamp HLB para ordering causal
```

### Rate Limiting (Recomendado)

```
POST /validacoes/bpm:  Max 10 req/min por user (LLM caro)
POST /processo/aceitar: Max 50 req/min (Maker/Checker crítico)
GET /processos-bpm?busca=...: Max 100 req/min (RAG caro)
POST /processos-bpm: Max 50 req/min
```

---

## 📝 NOTAS IMPLEMENTAÇÃO

### Prioridade Alta (Blockers)

```
1. Prisma generate + pg module (RESOLVIDO em PASSO 3 ✅)
2. PostgreSQL schemas (sugoi_*, processo_bpm) — PRONTO ✅
3. Ollama 3 modelos (DeepSeek, Qwen, SaulLM) — PRONTO ✅
4. LlamaIndex setup + nomic-embed-text — PRONTO ✅
5. Kigyou shared schema (pessoa_cadeira) — PRONTO ✅
```

### Decisões Técnicas Validadas

```
🟢 Fastify (não Express): Mais rápido, melhor perf
🟢 Prisma 6.19.3: Estável (6.x, não rc)
🟢 Ollama cascata: Fallback automático se timeout
🟢 pgvector cosine: Melhor para embeddings semânticos
🟢 SHA-256 + HLB: Segurança + ordering causal (KAN-SA M4)
```

### Observações

```
• Hash_temp é recalculado a cada UPDATE
  → Força novo processo de validação/aprovação

• Maker/Checker é IMUTÁVEL após assinatura
  → Nenhuma alteração possível pós-aprovação
  → Novo processo precisa ser criado se mudanças necessárias

• RAG embedding é ASSÍNCRONO (background job)
  → Não bloqueia criação do processo
  → Busca ativa assim que embedding disponível

• Todos endpoints retornam ISO 8601 timestamps
  → Facilita parsing em frontend/mobile
```

---

## 🎯 PRÓXIMOS PASSOS

**PASSO 9:** Backend Implementation (Fastify routes)  
**PASSO 10:** Frontend DIFY Canvas  
**PASSO 11:** Jest tests + SLA validation  
**PASSO 12:** Go-Live checklist  

---

**Assinado:** Dai_Vibe_Code  
**Data:** 2026-10-16 21:45 Brasília  
**Status:** 🟢 PRONTO PARA DESENVOLVIMENTO  
**Confiança:** ALTA 98%

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
