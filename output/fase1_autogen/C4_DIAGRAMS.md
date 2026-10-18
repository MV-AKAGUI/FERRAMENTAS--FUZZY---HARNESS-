# C4 Architecture Diagrams - SUGOI_CADEIA_DE_VALOR

## Context Diagram

```mermaid
C4Context
  title SUGOI_CADEIA_DE_VALOR - Context Diagram

  Person(gng, "G&G / TI-Processos", "Designer de processos (alçada 0-3)")
  Person(diretor, "Diretor Setor", "Aprova e publica (alçada 0)")
  
  System(sugoi, "SUGOI_CADEIA_DE_VALOR", "Expert System Condutor\nDesign de processos, validação, documentação")
  
  System_Ext(zeev, "Zeev", "Execução de processos (downstream)")
  System_Ext(pam, "PAM / IGA", "Autenticação e controle de acesso (semana 3+)")
  System_Ext(portal, "Portal SUGOI", "Publicação e assinatura digital")
  
  Rel(gng, sugoi, "Desenha e valida processos (read/write)")
  Rel(diretor, sugoi, "Aprova e publica (alçada 0)")
  Rel(sugoi, portal, "Publica com assinatura digital")
  Rel(sugoi, zeev, "Direciona fluxos (sem execução)")
  Rel(sugoi, pam, "Autentica via CPF+banco (depois PAM.exe)")
```

---

## Container Diagram

```mermaid
C4Container
  title SUGOI_CADEIA_DE_VALOR - Container Diagram

  Container(web_app, "Web Browser", "React.js", "- Canvas BPM drag-drop\n- Edição colaborativa\n- Viewer de validações")
  Container(api_server, "REST API Server", "Node.js / Express", "- CRUD processos\n- Validações LLM\n- Auth + SoD\n- Assinatura digital")
  Container(db, "Database", "PostgreSQL + pgvector", "- Processos BPM\n- Pessoas & RACI\n- Auditoria imutável\n- Embeddings RAG")
  Container(llm_engine, "LLM Cascade", "Ollama (local)", "- DeepSeek-R1 (BPM)\n- Qwen2.5-Coder (schemas)\n- SaulLM (compliance)\n- RapidFuzz (duplicidade)")
  Container(rag, "RAG + Vector Store", "LlamaIndex + pgvector", "- Busca semântica\n- Histórico processos\n- Context para LLM")
  Container(signature, "Digital Signature", "Python + Hashlib", "- Hash do processo\n- DE ACORDO timestamp\n- Link publicação")

  Rel(web_app, api_server, "HTTP REST (JWT)")
  Rel(api_server, db, "SQL (Prisma ORM)")
  Rel(api_server, llm_engine, "JSON (validação)")
  Rel(llm_engine, rag, "Consulta contexto")
  Rel(api_server, signature, "POST assinar")
  Rel(web_app, rag, "Busca similar [opcional]")
```

---

## Component Diagram (API)

```mermaid
C4Component
  title SUGOI_CADEIA_DE_VALOR - Component Diagram (API)

  Component(auth_module, "Auth Module", "Middleware", "- CPF validation\n- JWT generation\n- SoD check (20 regras)\n- Login audit")
  
  Component(process_manager, "Process Manager", "Controller", "- CRUD ProcessoBPM\n- Nós & arestas\n- Versionamento")
  
  Component(validator_engine, "Validator Engine", "Orchestration", "- 10 Travões paralelo\n- Cascata LLM\n- Confidence scoring\n- Anti-alucinação")
  
  Component(bpm_validator, "BPM Validator", "Service", "- Estrutura BPM\n- Cadeia integridade\n- Nó/aresta válidos")
  
  Component(sod_validator, "SoD Validator", "Service", "- 20 regras determinísticas\n- 100% confiança\n- Sem exceção")
  
  Component(duplicity_check, "Duplicity Checker", "Service", "- RapidFuzz matching\n- RAG semantic search\n- 70-85% alertas")
  
  Component(signature_manager, "Signature Manager", "Service", "- Hash geração\n- DE ACORDO log\n- Portal publicação")
  
  Component(audit_logger, "Audit Logger", "Repository", "- Append-only logs\n- Login tracking\n- SoD violations\n- Validação history")

  Rel(auth_module, audit_logger, "Log login")
  Rel(process_manager, validator_engine, "Trigger validações")
  Rel(validator_engine, bpm_validator, "BPM check")
  Rel(validator_engine, sod_validator, "SoD check")
  Rel(validator_engine, duplicity_check, "Duplicity check")
  Rel(validator_engine, audit_logger, "Log resultado")
  Rel(signature_manager, audit_logger, "Log assinatura")
  Rel(process_manager, signature_manager, "POST assinar")
```

---

## Deployment Diagram (FASE 1)

```mermaid
C4Deployment
  title SUGOI_CADEIA_DE_VALOR - Deployment (FASE 1)

  Deployment_Node(dev_machine, "Developer Machine", "Windows 11", "") {
    Container(web, "Web App", "React Dev Server")
    Container(api, "API Server", "Node.js (localhost:3001)")
    Container(db_local, "PostgreSQL", "Docker (localhost:5432)")
    Container(ollama_local, "Ollama", "7 models (localhost:11434)")
  }

  Deployment_Node(git, "GitHub", "Version Control") {
    Container(repo_code, "Code Repository", "Git")
    Container(repo_meta, "Meta_GPT_DAISUGI", "SDD/C4/Schema autogen")
  }

  Rel(api, db_local, "SQL")
  Rel(api, ollama_local, "HTTP (validação)")
  Rel(web, api, "HTTP")
  Rel(repo_code, dev_machine, "git clone/pull")
```

---

## Data Flow Diagram (Validação BPM)

```mermaid
flowchart TD
  A["[Usuario] Desenha Processo BPM"] -->|POST /processos-bpm| B["API Server"]
  B -->|Autenticar| C{"Auth OK?"}
  C -->|Sim| D["Process Manager"]
  C -->|Nao| E["[401] Unauthorized"]
  D -->|Trigger| F["Validator Engine"]
  
  F -->|Paralelo| G["BPM Validator"]
  F -->|Paralelo| H["SoD Validator"]
  F -->|Paralelo| I["HAP Validator"]
  F -->|Paralelo| J["Duplicity Checker"]
  
  G -->|Resultado| K{"BPM OK?"}
  K -->|Sim| L["Log resultado"]
  K -->|Nao| M["[BLOQUEIA] Estrutura invalida"]
  
  H -->|Resultado| N{"SoD OK?"}
  N -->|Sim| O["Log resultado"]
  N -->|Nao| P["[BLOQUEIA] Violacao SoD"]
  
  J -->|Resultado| Q{"Duplicidade?"}
  Q -->|>85%| R["[ALERTA] Possivel duplicado"]
  Q -->|<85%| S["[INFO] Similares encontrados"]
  
  L --> T["Salvar em DB"]
  O --> T
  S --> T
  T -->|Response| U["[200] Processo criado"]
  U -->|GET /processos/:id| V["[Usuario] Valida resultado"]
```

---

## Sequence Diagram (Login + Criação Processo)

```mermaid
sequenceDiagram
  actor User as Usuario (G&G)
  participant Web as Web App
  participant API as API Server
  participant Auth as Auth Module
  participant DB as PostgreSQL
  participant Validator as Validator Engine
  
  User ->>+ Web: Abre editor
  User ->>+ Web: Clica "Login"
  Web ->>+ API: POST /auth/login { cpf: "123..." }
  API ->>+ Auth: Validar CPF
  Auth ->>+ DB: SELECT * FROM pessoa_cadeira WHERE cpf
  DB -->>- Auth: { cpf, nome, setor, cadeira, alçada }
  Auth ->> DB: INSERT INTO login_audit { cpf, resultado, timestamp }
  Auth -->> API: JWT token
  API -->> Web: { token, user }
  Web -->> User: [OK] Logado
  
  User ->> Web: Desenha processo BPM
  User ->> Web: Clica "Validar"
  Web ->>+ API: POST /validacoes/bpm { processo_id }
  API ->>+ Validator: Executar 10 Travoes
  Validator ->>+ DB: Buscar processo + RACI
  DB -->> Validator: { processo, nos, arestas, raci }
  Validator -->> API: { valido, confianca, log_id }
  API ->> DB: INSERT INTO AnalisadorDocumento { ... }
  API -->> Web: { resultado validacao }
  Web -->> User: [OK] Processo válido, publicar?
```

---

**Status:** ✅ Completo  
**Formato:** Mermaid diagrams (renderizáveis)  
**Próximo:** Component implementation (FASE 1, Semana 2)

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
