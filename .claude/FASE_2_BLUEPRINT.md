# 🏛️ FASE 2 BLUEPRINT: SUGOI_CADEIA_DE_VALOR - Governança Corporativa + Análise LLM

**Versão:** 1.0 | **Status:** BLUEPRINT | **Data:** 2026-10-16  
**Dai_Vibe_Code:** Tempo 3 - Anatomia Técnica | **Modo:** Design-First  
**Timeline:** 4 Semanas (Paralelo a FASE 1) | **Usuários Simultâneos:** 5 máx

---

## 📋 EXECUTIVO

### Objetivo Primário
**Orquestrador de Governança Corporativa** que permite G&G **subir, analisar, revisar e publicar** Políticas Corporativas, Código de Ética e Missão/Visão/Valores com **análise LLM inteligente, workflow colaborativo e rastreamento completo**.

### O que Adiciona
- ✅ Upload de Documentos (Políticas, Ética, MVV)
- ✅ Análise LLM com compliance checking
- ✅ Workflow colaborativo (comentários + threads)
- ✅ RACI dinâmico (quem comenta, quem valida)
- ✅ Sugestões automáticas (redação, estrutura, compliance)
- ✅ Versioning completo + auditoria

### Foco
- Não tira nada da FASE 1 (apenas adiciona)
- Aproveita logs de auditoria existentes
- Reutiliza padrão de assinatura digital
- Expande validadores para conteúdo (não só estrutura)

---

## 🏛️ ARQUITETURA C4 (FASE 2)

### Nível 1: CONTEXTO (Expandido)
```
┌────────────────────────────────────────────────────────┐
│         Kigyou (Oracle) - Gestão Central               │
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │  SUGOI_CADEIA_DE_VALOR (Módulo Expandido)       │ │
│  │                                                   │ │
│  │  FASE 1 (Processos)                              │ │
│  │  ├─ Designer de Processos (BPM/HAP)             │ │
│  │  ├─ Documentação (POPs, ITs)                     │ │
│  │  ├─ Validadores estruturais                      │ │
│  │  └─ Publicação + Exportadores                    │ │
│  │                                                   │ │
│  │  FASE 2 (Governança) ⭐ NOVO                     │ │
│  │  ├─ Upload de Políticas/Ética/MVV              │ │
│  │  ├─ Análise LLM (compliance + redação)          │ │
│  │  ├─ Workflow colaborativo                        │ │
│  │  ├─ RACI dinâmico                                │ │
│  │  └─ Publicação + Assinatura Digital              │ │
│  └──────────────────────────────────────────────────┘ │
│           │                                             │
│           ├─► PAM-IGA (Auth)                            │
│           ├─► PostgreSQL (Data)                         │
│           ├─► LLM APIs (Análise)                        │ 
│           └─► Oracle ERP (Referência)                   │
└────────────────────────────────────────────────────────┘
```

### Nível 2: CONTAINER (FASE 2 Components)
```
SUGOI_CADEIA_DE_VALOR - FASE 2
├── Frontend Layer (React/Next.js)
│   ├─ Editor de Políticas (Upload + Preview)
│   ├─ Painel de Análise LLM (Sugestões em tempo real)
│   ├─ Comentários/Threads (Revisão colaborativa)
│   ├─ Painel RACI (Quem revisa o quê?)
│   └─ Histórico de Versões (Auditoria completa)
│
├── Backend Layer (Node.js/Express)
│   ├─ APIs de Documentos (Upload, Edit, Version)
│   ├─ LLM Engine (Análise + Sugestões)
│   │   ├─ Compliance Checker (SoD, políticas)
│   │   ├─ Structure Analyzer (Restruturação)
│   │   ├─ Redaction Suggester (Melhorias text)
│   │   └─ Fuzzy Confidence Scorer
│   ├─ Workflow Engine (Comentários, threads)
│   ├─ Approval Engine (RACI dinâmico)
│   └─ Exportadores (mesmo da FASE 1)
│
├── Data Layer (PostgreSQL + Extensões)
│   ├─ DocumentoCorporativo (Políticas, Ética, MVV)
│   ├─ AnaliseDocumento (LLM output + metadata)
│   ├─ ComentarioThread (Revisão colaborativa)
│   ├─ DefinicaoRaci (Dinâmica por documento)
│   ├─ PublicacaoDocumento (Versioning)
│   └─ AssinaturaCorporativa (Rastreamento)
│
└── Security Layer (PAM-IGA)
    ├─ Rota A: SSO (usuários nominais)
    └─ Rota B: Cofre (acesso genérico)
```

### Nível 3: COMPONENT (LLM Architecture)

```
LLM Engine (FASE 2)
├── Compliance Checker
│   ├─ Entrada: Artigo de política + Base de regras (SoD, compliance)
│   ├─ Lógica: Match contra 20 regras SoD
│   ├─ Output: "Artigo 2.1 potencialmente conflita com SoD-004"
│   ├─ Fuzzy: 85% confiança
│   └─ Model: Claude 3.5 Sonnet (compliance) ou DeepSeek R1 (local)
│
├── Structure Analyzer
│   ├─ Entrada: Documento completo
│   ├─ Lógica: Detecta seções faltantes, orden subótima
│   ├─ Output: "Sugestão: mover 'Responsabilidades' antes de 'Definições'"
│   ├─ Fuzzy: 72% confiança
│   └─ Model: Claude 3.5 Sonnet (análise estrutural)
│
├── Redaction Suggester
│   ├─ Entrada: Texto da política
│   ├─ Lógica: Melhora clareza, concisão, tom corporativo
│   ├─ Output: "Proposição reescrita: '[original]' → '[sugestão]'"
│   ├─ Fuzzy: 65% confiança
│   └─ Model: Claude 3.5 Sonnet (redação)
│
└── Duplicity Detector
    ├─ Entrada: Novo documento vs. base existente
    ├─ Lógica: Compara semantic similarity
    ├─ Output: "88% similar com Política POL-2023-04"
    ├─ Fuzzy: 88% confiança
    └─ Model: Embeddings (Ollama local ou Claude)
```

---

## 💾 PRISMA SCHEMA (FASE 2 - Extensions)

```prisma
// ============================================
// FASE 2: GOVERNANÇA CORPORATIVA
// ============================================

// ============================================
// 1. DOCUMENTOS CORPORATIVOS
// ============================================

model TipoDocumento {
  id                    Int       @id @default(autoincrement())
  codigo                String    @unique @db.VarChar(20)
  nome                  String    @db.VarChar(100)
  secoes_padrao         String    @db.JsonB
  template              String?   @db.Text

  documentos            DocumentoCorporativo[]
  created_at            DateTime  @default(now())

  @@index([codigo])
}

model DocumentoCorporativo {
  id                    Int       @id @default(autoincrement())
  tipo_doc_id           Int
  codigo_documento      String    @unique @db.VarChar(30)
  titulo                String    @db.VarChar(255)
  versao                String    @db.VarChar(10)  @default("1.0")
  conteudo              String    @db.Text
  metadata              String    @db.JsonB
  status                String    @db.VarChar(20)  @default("RASCUNHO")
  criado_por_cpf        String    @db.VarChar(11)
  data_criacao          DateTime  @default(now())

  tipo_documento        TipoDocumento  @relation(fields: [tipo_doc_id], references: [id], onDelete: Restrict)
  analises              AnaliseDocumento[]
  comentarios           ComentarioDocumento[]
  raci_dinamico         DefinicaoRaciDocumento[]
  publicacoes           PublicacaoDocumento[]
  created_at            DateTime  @default(now())
  updated_at            DateTime  @updatedAt

  @@index([tipo_doc_id, status])
  @@index([criado_por_cpf])
}

// ============================================
// 2. ANÁLISE LLM (FASE 2)
// ============================================

model AnaliseDocumento {
  id                    Int       @id @default(autoincrement())
  documento_id          Int
  tipo_analise          String    @db.VarChar(50)
  resultado_llm         String    @db.JsonB
  confianca_fuzzy       Int       @default(0)
  sugestoes             String    @db.JsonB
  tempo_analise_ms      Int
  modelo_llm            String    @db.VarChar(50)

  documento             DocumentoCorporativo  @relation(fields: [documento_id], references: [id], onDelete: Cascade)
  created_at            DateTime  @default(now())

  @@index([documento_id, tipo_analise])
}

model SugestaoDocumento {
  id                    Int       @id @default(autoincrement())
  analise_id            Int
  tipo_sugestao         String    @db.VarChar(50)
  conteudo_original     String    @db.Text
  conteudo_sugerido     String    @db.Text
  confianca             Int       @default(0)
  aceita                Boolean   @default(false)
  motivo_rejeicao       String?   @db.Text

  created_at            DateTime  @default(now())
  updated_at            DateTime  @updatedAt

  @@index([analise_id])
}

// ============================================
// 3. COMENTÁRIOS & THREADS (Colaboração)
// ============================================

model ComentarioDocumento {
  id                    Int       @id @default(autoincrement())
  documento_id          Int
  comentario_pai_id     Int?
  cpf_autor             String    @db.VarChar(11)
  conteudo              String    @db.Text
  posicao_texto         Int?
  selecionado_texto     String?   @db.Text
  tipo                  String    @db.VarChar(20)
  status                String    @db.VarChar(20)  @default("ABERTO")

  documento             DocumentoCorporativo  @relation(fields: [documento_id], references: [id], onDelete: Cascade)
  comentario_pai        ComentarioDocumento? @relation("RespostasComentario", fields: [comentario_pai_id], references: [id], onDelete: Cascade)
  respostas             ComentarioDocumento[] @relation("RespostasComentario")
  created_at            DateTime  @default(now())
  updated_at            DateTime  @updatedAt

  @@index([documento_id, status])
  @@index([cpf_autor])
}

// ============================================
// 4. RACI DINÂMICO (Quem revisa o quê)
// ============================================

model DefinicaoRaciDocumento {
  id                    Int       @id @default(autoincrement())
  documento_id          Int
  cpf_pessoa            String    @db.VarChar(11)
  papel_raci            String    @db.VarChar(20)
  data_designacao       DateTime  @default(now())
  status                String    @db.VarChar(20)  @default("PENDENTE")

  documento             DocumentoCorporativo  @relation(fields: [documento_id], references: [id], onDelete: Cascade)
  created_at            DateTime  @default(now())

  @@unique([documento_id, cpf_pessoa])
  @@index([documento_id, papel_raci])
}

// ============================================
// 5. PUBLICAÇÃO & VERSIONING
// ============================================

model PublicacaoDocumento {
  id                    Int       @id @default(autoincrement())
  documento_id          Int
  versao_publicada      String    @db.VarChar(10)
  conteudo_html         String    @db.Text
  conteudo_mobile       String    @db.Text
  status                String    @db.VarChar(20)  @default("RASCUNHO")
  aprovado_por_cpf      String?   @db.VarChar(11)
  data_aprovacao        DateTime?
  data_publicacao       DateTime?

  documento             DocumentoCorporativo  @relation(fields: [documento_id], references: [id], onDelete: Cascade)
  assinaturas           AssinaturaCorporativa[]
  created_at            DateTime  @default(now())
  updated_at            DateTime  @updatedAt

  @@index([documento_id, status])
}

model AssinaturaCorporativa {
  id                    Int       @id @default(autoincrement())
  publicacao_id         Int
  cpf_pessoa            String    @db.VarChar(11)
  data_leitura          DateTime  @default(now())
  de_acordo              Boolean   @default(false)
  data_acordo           DateTime?
  hash_assinatura       String    @db.VarChar(256)
  observacoes           String?   @db.Text

  publicacao            PublicacaoDocumento  @relation(fields: [publicacao_id], references: [id], onDelete: Cascade)
  created_at            DateTime  @default(now())

  @@unique([publicacao_id, cpf_pessoa])
  @@index([publicacao_id, de_acordo])
}

// ============================================
// 6. AUDITORIA EXPANDIDA (FASE 2)
// ============================================

model LogAuditoriaDocumento {
  id                    BigInt    @id @default(autoincrement())
  timestamp             DateTime  @default(now()) @db.Timestamptz
  cpf_executor          String    @db.VarChar(11)
  acao                  String    @db.VarChar(100)
  documento_id          Int
  documento_tipo        String    @db.VarChar(50)
  versao_anterior       String?   @db.VarChar(10)
  versao_nova           String?   @db.VarChar(10)
  dados_alterados       String?   @db.JsonB
  resultado             String    @db.VarChar(20)
  confianca_fuzzy       Int       @default(100)

  created_at            DateTime  @default(now())

  @@index([timestamp, cpf_executor])
  @@index([documento_id])
}
```

---

## 🧠 LLM ARCHITECTURE (FASE 2)

### 4 Especialistas LLM

```
┌─────────────────────────────────────────────────────┐
│             LLM Engine (FASE 2)                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  1. Compliance Checker                              │
│     Model: Claude 3.5 Sonnet                        │
│     Task: "Artigo conflita com SoD-004?"           │
│     Input: Policy text + SoD rules knowledge base   │
│     Output: { conflito, tipo, confiança }          │
│     Fuzzy: 85-95% confiança                         │
│                                                      │
│  2. Structure Analyzer                              │
│     Model: Claude 3.5 Sonnet                        │
│     Task: "Documento bem estruturado?"              │
│     Input: Documento completo                        │
│     Output: { seções_faltantes, ordem_ótima }      │
│     Fuzzy: 70-85% confiança                         │
│                                                      │
│  3. Redaction Suggester                             │
│     Model: Claude 3.5 Sonnet                        │
│     Task: "Melhorar clareza e concisão"            │
│     Input: Parágrafo original                        │
│     Output: { texto_sugerido, razão }              │
│     Fuzzy: 60-75% confiança                         │
│                                                      │
│  4. Duplicity Detector (Embeddings)                 │
│     Model: Ollama (local) ou Embeddings API         │
│     Task: "Documento similar ao existente?"        │
│     Input: Novo documento vs. base existente        │
│     Output: { similaridade, documento_similar }    │
│     Fuzzy: 80-92% confiança                         │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Implementation (Backend)

```python
# services/llm_service.py

class LLMAnalysisService:
    async def analisar_compliance(self, documento: DocumentoCorporativo) -> AnaliseDocumento:
        """Compliance Checker: Valida contra 20 regras SoD + políticas"""
        prompt = f"""
        Analise o seguinte documento corporativo e verifique se há conflitos com:
        - 20 Regras de SoD (Segregação de Funções)
        - Políticas corporativas existentes
        - Compliance legal (LGPD, etc.)
        
        Documento: {documento.conteudo[:2000]}...
        
        Retorne JSON com: {{
            "conflitos": [{{
                "tipo": "SoD-004",
                "artigo": "2.1",
                "descricao": "Artigo 2.1 permite maker=checker",
                "severidade": "ALTA",
                "confianca": 92
            }}],
            "observacoes": "..."
        }}
        """
        
        response = await claude_api.generate(prompt, model="claude-3-5-sonnet")
        return await self._salvar_analise(documento, "COMPLIANCE", response, confianca=92)
    
    async def analisar_estrutura(self, documento: DocumentoCorporativo) -> AnaliseDocumento:
        """Structure Analyzer: Detecta seções faltantes e ordem subótima"""
        prompt = f"""
        Analise a estrutura do documento corporativo.
        
        Documento: {documento.conteudo}
        
        Retorne JSON com: {{
            "secoes_existentes": ["Definições", "Responsabilidades", ...],
            "secoes_recomendadas": ["Objetivo", "Definições", "Responsabilidades", ...],
            "sugestoes_restruturacao": [{{
                "seção": "Responsabilidades",
                "posição_atual": 3,
                "posição_sugerida": 1,
                "razão": "Deve vir cedo no documento"
            }}],
            "confianca": 78
        }}
        """
        
        response = await claude_api.generate(prompt)
        return await self._salvar_analise(documento, "ESTRUTURA", response, confianca=78)
    
    async def sugerir_melhorias_redacao(self, documento: DocumentoCorporativo) -> List[SugestaoDocumento]:
        """Redaction Suggester: Melhora clareza e tom corporativo"""
        paragrafos = self._quebrar_em_paragrafos(documento.conteudo)
        sugestoes = []
        
        for i, paragrafo in enumerate(paragrafos):
            prompt = f"""
            Melhore a clareza e concisão deste parágrafo corporativo:
            
            Original: {paragrafo}
            
            Retorne JSON com: {{
                "sugestao": "...",
                "razao": "Remover jargão, deixar mais conciso",
                "confianca": 72
            }}
            """
            
            response = await claude_api.generate(prompt)
            sugestoes.append(
                SugestaoDocumento(
                    documento_id=documento.id,
                    tipo_sugestao="REDACAO",
                    conteudo_original=paragrafo,
                    conteudo_sugerido=response["sugestao"],
                    confianca=response["confianca"]
                )
            )
        
        return await self._salvar_sugestoes(sugestoes)
    
    async def detectar_duplicidade(self, documento_novo: DocumentoCorporativo) -> List[Dict]:
        """Duplicity Detector: Compara com documentos existentes"""
        embedding_novo = await self._gerar_embedding(documento_novo.conteudo)
        
        documentos_existentes = await self._buscar_documentos(
            tipo=documento_novo.tipo_documento,
            excluir_id=documento_novo.id
        )
        
        similares = []
        for doc_existente in documentos_existentes:
            embedding_existente = await self._gerar_embedding(doc_existente.conteudo)
            similaridade = self._cosine_similarity(embedding_novo, embedding_existente)
            
            if similaridade > 0.80:
                similares.append({
                    "documento_id": doc_existente.id,
                    "titulo": doc_existente.titulo,
                    "versao": doc_existente.versao,
                    "similaridade": similaridade,
                    "confianca": min(100, int(similaridade * 100))
                })
        
        return sorted(similares, key=lambda x: x["similaridade"], reverse=True)
```

---

## 🎛️ WORKFLOW COLABORATIVO (FASE 2)

### Fluxo de Análise & Revisão

```
1. G&G SOBE DOCUMENTO
   ├─ Upload (Política, Ética ou MVV)
   ├─ Status: RASCUNHO
   └─ Sistema roda análises LLM automáticas

2. ANÁLISES RODAM (Paralelo)
   ├─ Compliance Checker (85% confiança)
   ├─ Structure Analyzer (78% confiança)
   ├─ Redaction Suggester (72% confiança)
   ├─ Duplicity Detector (88% confiança)
   └─ Output: Painel com sugestões + confiança

3. G&G REVISA SUGESTÕES
   ├─ Vê conflitos compliance
   ├─ Vê restruturação sugerida
   ├─ Vê melhorias de redação
   ├─ Aceita, rejeita ou edita cada sugestão
   └─ Status: REVISADO

4. G&G DEFINE RACI DINÂMICO
   ├─ "Director de Setor X comenta"
   ├─ "Director de Setor Y valida"
   ├─ "Presidência aprova"
   └─ Sistema envia notificações

5. REVISORES COMENTAM (Threads)
   ├─ Comentário → Citação → Thread
   ├─ Sistema coleta feedback
   ├─ Resolve conflitos
   └─ Status: SOB_ANALISE

6. G&G APLICA FEEDBACK
   ├─ Edita documento
   ├─ Marca comentários como "Resolvido"
   ├─ Nova versão criada
   └─ Versioning automático

7. APROVADOR FINAL VALIDA
   ├─ Diretor G&G revisa tudo
   ├─ Aprova ou solicita ajustes
   ├─ Status: APROVADO
   └─ Gera página de publicação

8. ASSINATURA DIGITAL
   ├─ Cria link para assinatura
   ├─ Diretores de setor + TIME SUGOI assinam
   ├─ Rastreamento: quem leu, quando, "DE ACORDO"
   └─ Status: ASSINADO

9. PUBLICAÇÃO FINAL
   ├─ Portal SUGOI recebe documento
   ├─ Exporta para downstream (se necessário)
   └─ Status: PUBLICADO
```

---

## 📊 RACI DINÂMICO (FASE 2)

G&G define para cada documento:

```
DefinicaoRaciDocumento {
  documento_id: 123,
  cpf_pessoa: "12345678901",
  papel_raci: "C" (Commented/Consulted),
  status: "PENDENTE"
}

Papéis Disponíveis:
- R (Responsável): G&G principal
- A (Accountable): Diretor G&G (homologação final)
- C (Consulted): Diretores de setor (comentários)
- I (Informed): TIME SUGOI (apenas lê + assina)
```

---

## 🚀 TIMELINE (4 Semanas - Paralelo a FASE 1)

### SEMANA 1: Models + LLM Setup
- [ ] Seg-Ter: Prisma models para documentos (4 tables)
- [ ] Qua: Setup LLM API (Claude Sonnet + embeddings)
- [ ] Qui-Sex: Testes de conexão com LLM

**Saída:** Database preparado, LLM pronto

### SEMANA 2: LLM Engines
- [ ] Seg-Ter: Compliance Checker implementado
- [ ] Qua: Structure Analyzer + Redaction Suggester
- [ ] Qui: Duplicity Detector
- [ ] Sex: Testes end-to-end dos 4 LLMs

**Saída:** LLM engines operacionais, sugestões sendo geradas

### SEMANA 3: Workflow + Colaboração
- [ ] Seg-Ter: APIs de Upload e Análise
- [ ] Qua: Comentários + Threads
- [ ] Qui: RACI Dinâmico (atribuição)
- [ ] Sex: Testes de workflow completo

**Saída:** Colaboração funciona, comentários rastreados

### SEMANA 4: Publicação + Integration
- [ ] Seg-Ter: Publicação + Assinatura Digital
- [ ] Qua: Exportadores (mesmo da FASE 1)
- [ ] Qui: Auditoria completa
- [ ] Sex: QA + Deploy

**Saída:** FASE 2 pronta para produção (após FASE 1)

---

## 📦 INTEGRAÇÃO COM FASE 1

FASE 2 é **100% compatível** com FASE 1:

- ✅ Reutiliza tabelas de Auditoria (LogAuditoria)
- ✅ Reutiliza tabelas de Publicação (PublicacaoAprovada, AssinaturaDigital)
- ✅ Reutiliza esquema de Auth (PAM-IGA)
- ✅ Reutiliza APIs de Exportação
- ✅ Estende, não quebra

### Merge Strategy (Semana 9)
```
1. FASE 1 roda em produção (4 semanas)
2. FASE 2 é desenvolvida em paralelo
3. Semana 5: FASE 2 entra em staging
4. Semana 9: Merge com FASE 1 (sem downtime)
   ├─ G&G continua usando FASE 1 (processos)
   ├─ Agora adiciona FASE 2 (governança)
   └─ Mesma ferramenta, mais funcionalidade
```

---

## ✅ CHECKLIST GO-LIVE (FASE 2)

- [ ] LLM engines testados (todos 4)
- [ ] Análises rodam em < 5 segundos
- [ ] Workflow colaborativo (comentários OK)
- [ ] RACI dinâmico atribuindo corretamente
- [ ] Publicação + assinatura funciona
- [ ] Auditoria completa
- [ ] Exportadores funcionam
- [ ] Merge com FASE 1 sem quebras
- [ ] Security (PAM-IGA integrado)

---

**Status FASE 2:** ✅ BLUEPRINT PRONTO PARA DESENVOLVIMENTO  
**Confiança:** 94%  
**Cronograma:** Paralelo a FASE 1 (começa semana 1, termina semana 4)  
**Próximo:** Implementação FASE 1 + 2 em paralelo
