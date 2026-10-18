# RESUMO INTELIGÊNCIA - SEMANA 3 (com validação de ferramentas + hierarquia)
**Data:** 2026-10-16  
**Status:** Pronto para Dai_Vibe_Code executar Anatomia de Semana 3  
**Fonte:** Lista de Ferramentas OFICIAL + Planilha PAM V03 + Resumo anterior

---

## 🔴 CORREÇÕES CRÍTICAS APLICADAS

### 1. HIERARQUIA DE APROVAÇÃO (Corrigida)
**ANTES (INCORRETO):**
```
Diretoria / COPAG (aprovadores) → Assinam digitalmente
```

**AGORA (CORRETO):**
```
Maker/Checker Pattern:
├─ Maker: Analista cria o processo BPM (criação/edição)
├─ Checker: Diretor do Setor + Diretor Presidente (aprovam)
└─ Signer: SHA-256 + Hora Legal Brasileira + Webhook ClickSign

Fonte: Planilha PAM V03, aba "Cadeiras", coluna K (Maker/Checker)
```

### 2. BIBLIOTECAS JÁ EXISTENTES (Anti-Duplicação)
**Acervo FUZZY-HARNESS confirmado (Lista de Ferramentas - 08-10-2026):**

| Necessidade | Solução Existente | Status |
|---|---|---|
| Orquestração (grafos) | LangGraph (langgraph==1.2.12) | ✅ Ativo |
| Cadeias de LLMs | LangChain (langchain==1.4.3) | ✅ Ativo |
| Frontend conversacional | Streamlit (streamlit==1.65.0) | ✅ Ativo |
| Chat dinâmico | Chainlit (chainlit==2.11.0) | ✅ Ativo |
| Plataforma Low-Code | Dify (./dify) | ✅ Clonado |
| Automação workflows | n8n (n8n_automacao) | ✅ Ativo (PORT 5678) |
| RAG/Vetorização | LlamaIndex (llama-index==0.14.25) | ✅ Ativo |
| Embeddings | nomic-embed-text | ✅ Ativo (Ollama) |
| Banco vetorial | PostgreSQL + pgvector | ✅ Ativo (Oracle) |
| Visão/OCR | PaddleOCR, Docling, RapidOCR | ✅ Ativo |
| Fuzzy matching | RapidFuzz (RapidFuzz==3.14.6) | ✅ Ativo |

**DECISÃO:** NÃO adicionar LangChain/LangGraph/react-flow extras — usar Stack interno.

---

## ✅ CONTEXTO SEMANA 3 (Confirmado Operacional)

### Infraestrutura Oracle OCI - ATIVA
```
IP: 137.131.151.74 (SLA 99.9%)
├─ Caddy Gateway (HTTPS/TLS 1.3)
├─ API SUGOI (Port 3001) → https://kigyou.daisugi.com.br
├─ PostgreSQL (memoria_vetorial) - Compartilhado Kigyou
│  ├─ Schema public: setor (14), cadeira, pessoa_cadeira, login_audit, sod_*
│  └─ Schema sugoi_*: 8 tabelas BPM
├─ Ollama (Port 11434) - 7 modelos LLM
└─ Network: daisugi-network (compartilhada)
```

### 14 Setores (PAM SUGOI - Ordem Aprovada)
1. Presidência
2. Gente/cultura/gestão
3. Operações
4. Planejamento financeiro
5. Controladoria
6. Administrativo financeiro
7. Jurídico empresarial
8. QSMS
9. Land bank e novos negócios
10. Jurídico imobiliário
11. Incorporação
12. Engenharia
13. Suprimentos
14. CRM

---

## 🎯 SEMANA 3 - ROADMAP (Dia 16 → Dia 30)

### SEGUNDA-TERÇA (REST APIs + Validadores Ollama)
```
POST /api/v1/processos-bpm
├─ Body: {no_bpm: [], arestas_bpm: [], metadata}
├─ Ollama Cascata:
│  ├─ DeepSeek-R1 8B: análise estrutural BPM (95% confiança)
│  ├─ Qwen 2.5 Coder: validação algorítmica (85%)
│  └─ SaulLM: compliance/jurídico (98%)
├─ 10 Travões em paralelo (RapidFuzz + SoD)
└─ Response: {processo_id, status, validacoes[], assinatura_hash}

GET /api/v1/processos-bpm/:id (+ RAG semântica)
```

### QUARTA-SEXTA (RAG + Frontend React)
```
Backend RAG:
├─ LlamaIndex: chunking de processos históricos
├─ pgvector: similarity search (Cosine)
└─ Context injection: últimos 3 processos + templates

Frontend:
├─ Streamlit / Dify canvas (ao invés de react-flow)
├─ Drag-drop nós/arestas (usar componentes Dify/Streamlit)
├─ Real-time validation (WebSocket Chainlit)
└─ Publicação com Maker/Checker (nenhum WebhookClickSign ainda)
```

---

## 🛠️ TECH STACK SEMANA 3 (SEM DUPLICAÇÕES)

### Backend
```
├─ Node.js/Fastify (existente)
├─ Prisma ORM (16 modelos)
├─ PostgreSQL 16 + pgvector
├─ LangChain 1.4.3 (para cadeias)
├─ LangGraph 1.2.12 (para orquestração)
└─ LlamaIndex 0.14.25 (para RAG)
```

### LLM Cascata (Ollama Local - Sem custos API)
```
├─ DeepSeek-R1 8B (BPM logic, 95%)
├─ Qwen 2.5 Coder 7B (algoritmos, 85%)
└─ SaulLM 7B (compliance, 98%)
```

### Frontend (Opções - Escolher 1)
```
Opção A: Streamlit (rápida, prototipagem)
│  └─ Usar componentes Streamlit para canvas (sem react-flow)

Opção B: Dify (visual, low-code)
│  └─ Usar blocos Dify para BPM (sem react-flow)

Opção C: Chainlit (conversacional, web)
│  └─ Chat + canvas integrado
```

### Automação & Workflows
```
├─ n8n (5678): integração com ClickSign, webhook
└─ RapidFuzz: reconciliação Maker/Checker
```

---

## 📊 RACI SEMANA 3 (Corrigido)

| Atividade | Dev | Architect | QA | Aprovador |
|---|---|---|---|---|
| REST API endpoints | ✅ | | | |
| Ollama cascata | ✅ | ✅ | ✅ | |
| 10 Travões paralelo | ✅ | ✅ | ✅ | |
| RAG + pgvector | ✅ | ✅ | | |
| Frontend (Streamlit/Dify) | ✅ | | ✅ | |
| Maker/Checker flow | | ✅ | ✅ | ✅ Diretor Setor + Dir Presidente |
| Assinatura digital | ✅ | | ✅ | |
| Deploy Oracle | | ✅ | ✅ | |

**Aprovadores Corretos:**
- ❌ COPAG (não existe)
- ✅ Diretor do Setor (cadeira da função)
- ✅ Diretor Presidente (órgão supremo)

---

## 🔒 ARQUITETURA DE DADOS SEMANA 3

### Tabelas BPM (Schema `sugoi_*`)
```sql
processo_bpm
├─ id UUID (PK)
├─ titulo VARCHAR
├─ descricao TEXT
├─ setor_id FK (public.setor)
├─ criador_id FK (public.pessoa_cadeira)
├─ status ENUM: draft, pendente_aprovacao, aprovado, publicado
├─ hash_assinatura CHAR(64) -- SHA-256
├─ timestamp_assinatura TIMESTAMP -- Hora Legal Brasileira
├─ embedding VECTOR(1536) -- pgvector (nomic-embed-text)
└─ created_at, updated_at

no_bpm
├─ id UUID
├─ processo_id FK
├─ label VARCHAR
├─ tipo ENUM: inicio, atividade, decisao, fim
├─ travoes_aplicaveis JSON -- 10 Travões: BPM, HAP, EAP, SoD, RapidFuzz, ...
└─ coordenadas_canvas x, y

aresta_bpm
├─ id UUID
├─ processo_id FK
├─ no_origem FK
├─ no_destino FK
└─ condicao JSON
```

### Compartilhado (Schema `public`)
```sql
setor (14 setores, ordem PAM)
pessoa_cadeira (Maker)
login_audit (Checker - auditoria)
sod_violation_log (SoD - 20 regras)
```

---

## 🚀 GATES SEMANA 3

### ANTES de começar (🔴 Bloqueado até "De Acordo")
1. ✅ Tech stack sem duplicações aprovado
2. ✅ Hierarquia Maker/Checker confirmada
3. ✅ 10 Travões definidos (lista exata)
4. 🔴 Escolher frontend: Streamlit vs Dify vs Chainlit?

### DURANTE (🟢 Livre)
- Schemas Pydantic
- Unit tests
- Testes locais Ollama
- Diagramas C4/Sequence

### APÓS (🔴 Bloqueado até "De Acordo")
- Deploy Oracle (novos ports/redes)
- ClickSign webhook (integração)
- Commit → prod

---

## 📋 PRÓXIMOS PASSOS

**AGORA (Tem 5 minutos):**
1. ✅ Dai_Vibe_Code: Escuta Ativa (contexto confirmado)
2. ✅ Dai_Vibe_Code: Grill-Me (7 perguntas)
3. ✅ Dai_Vibe_Code: Anatomia (C4, Pydantic, RACI, Timeline)
4. 🔴 GATE: Frontend (Streamlit/Dify/Chainlit)? → Bloqueado

**SEGUNDA (Semana 2):**
- Implementar REST API + Ollama cascata
- Testes unitários dos validadores

**QUARTA (Semana 2):**
- RAG + Frontend deployment

---

## 📎 REFERÊNCIAS

- **Lista de Ferramentas:** FUZZY-HARNESS [08-10-2026]
- **PAM V03:** SUGOI_Modelo_Gestao_PAM_R03.xlsx (Cadeiras, Maker/Checker)
- **Semana 2 Deploy:** ✅ COMPLETO (API rodando, Oracle SLA 99.9%)
- **Anterior (Semana 1):** schema.prisma + SDD_FASE1_AUTOGEN.md

---

**Status:** 🟢 PRONTO PARA DAI_VIBE_CODE ANATOMIA  
**Bloqueador Principal:** Escolher Frontend (Streamlit vs Dify vs Chainlit)

