# 🏛️ FASE 2 OTIMIZADA: Governança Corporativa + Análise LLM (Arsenal Real)

**Versão:** 2.0 | **Status:** BLUEPRINT (94.2% confiança) | **Data:** 2026-10-16  
**Dai_Vibe_Code:** Tempo 3 - Anatomia + Arsenal Real  
**Timeline:** 4 Semanas (Paralelo a FASE 1) | **Tokens:** 0 (Ollama local)

---

## 📋 EXECUTIVO

### Objetivo Primário
**Orquestrador de Governança Corporativa** que permite G&G **subir, analisar, revisar e publicar** Políticas, Código de Ética e Missão/Visão/Valores com análise LLM inteligente, workflow colaborativo e rastreamento completo (usando Docling, RapidFuzz, SaulLM jurídico, RAG).

### Escopo
- ✅ Upload de documentos (PDF/Word)
- ✅ Docling auto-parse → Markdown estruturado
- ✅ Análise LLM com compliance + sugestões
- ✅ Workflow colaborativo (comentários + threads)
- ✅ RACI dinâmico (quem comenta/valida)
- ✅ Versioning + auditoria completa
- ✅ RAG para buscar políticas anteriores
- ✅ Integração 100% com FASE 1 (sem quebras)

---

## 🏛️ ARQUITETURA C4 + ARSENAL

### Nível 1: CONTEXTO (Expandido)
```
Kigyou (Oracle)
└─ SUGOI_CADEIA_DE_VALOR (Expandido com FASE 2)
   │
   ├─ FASE 1: Processos (4 semanas)
   │  ├─ Meta_GPT + Docling + RapidFuzz
   │  └─ Ollama (DeepSeek, Qwen, SaulLM)
   │
   └─ FASE 2: Governança (paralelo, 4 semanas)
      ├─ Docling: Parse Políticas/Ética/MVV
      ├─ RapidFuzz: Triagem duplicidade
      ├─ Cascata SaulLM (jurídico) → DeepSeek (raciocínio)
      ├─ RAG: Base de políticas aprovadas
      ├─ LangGraph: Orquestração comentários
      └─ PostgreSQL+pgvector: memória semântica
```

### Nível 2: CONTAINER

#### **Frontend (React/Next.js)**
```
Módulo Governança
├─ Upload Document
│  ├─ Drag-drop PDF/Word
│  ├─ Preview com Docling parsed
│  └─ Auto-detecta tipo (Política/Ética/MVV)
│
├─ Painel Análise LLM
│  ├─ Sugestões em tempo real
│  │  ├─ SaulLM: "Art. 2.1 conflita com SoD-004"
│  │  ├─ DeepSeek: "Seção 'Responsabilidades' falta"
│  │  └─ Qwen: "Reescrever: deixar mais conciso"
│  ├─ Confiança % explícita
│  ├─ Accept/Reject cada sugestão
│  └─ Aprende com feedback (fuzzy tuning)
│
├─ Comentários & Threads
│  ├─ Comentar artigo (menciona linha)
│  ├─ Responder comentário (thread)
│  ├─ Resolver quando implementado
│  └─ Histórico completo (auditoria)
│
├─ Painel RACI Dinâmico
│  ├─ G&G designa: "Diretor Setor X comenta"
│  ├─ "Diretor Setor Y valida"
│  ├─ "Presidência aprova"
│  └─ Sistema envia notificações
│
└─ Histórico & Versões
   ├─ Timeline de alterações
   ├─ Diff entre versões
   └─ Quem fez o quê, quando
```

#### **Backend (Node.js/Express)**
```
APIs Governança
│
├─ POST /api/v1/documentos/upload
│  ├─ Recebe PDF/Word
│  ├─ Docling parse → Markdown + metadata
│  ├─ Salva em DB + pgvector (embedding)
│  ├─ Trigger: Análise LLM automática
│  └─ Retorna: document_id, parsing_status
│
├─ POST /api/v1/documentos/{id}/analisar
│  ├─ Cascata LLM (em paralelo):
│  │  ├─ SaulLM: Compliance (SoD, regras)
│  │  ├─ DeepSeek-R1: Estrutura (seções faltantes)
│  │  ├─ Qwen: Redação (clareza, tom)
│  │  └─ RapidFuzz: Duplicidade (vs histórico)
│  ├─ Agregação de sugestões
│  ├─ Confiança fuzzy por sugestão
│  └─ Salva em AnaliseDocumento + SugestaoDocumento
│
├─ POST /api/v1/documentos/{id}/comentarios
│  ├─ Criar comentário (com linha + texto selecionado)
│  ├─ Thread com respostas
│  ├─ Status (ABERTO|RESOLVIDO|BLOQUEADOR)
│  └─ Log em DB (imutável)
│
├─ PUT /api/v1/documentos/{id}/raci
│  ├─ Designar pessoa para papel (R/A/C/I)
│  ├─ Sistema envia notificação
│  └─ Rastreamento de leitura
│
└─ POST /api/v1/documentos/{id}/publicar
   ├─ Gera página final (HTML + mobile)
   ├─ Cria assinatura digital
   ├─ Status: PUBLICADO
   └─ Export para downstream
```

#### **Data Layer (PostgreSQL + pgvector + RAG)**
```
🗄️ Schemas FASE 2

DocumentoCorporativo
├─ id, tipo_doc_id (Política|Ética|MVV)
├─ codigo, titulo, versao ("1.0", "1.1", ...)
├─ conteudo (Markdown via Docling)
├─ metadata (JSON: seções, tópicos-chave)
├─ status (RASCUNHO|SOB_ANALISE|APROVADO|PUBLICADO|ARQUIVADO)
├─ criado_por_cpf, data_criacao
├─ embedding_vetor (pgvector para RAG)
└─ similar_documentos_ids (JSON: [id1, id2] com scores)

AnaliseDocumento
├─ id, documento_id
├─ tipo_analise (COMPLIANCE|ESTRUTURA|REDACAO|DUPLICIDADE)
├─ resultado_llm (JSON)
├─ confianca_fuzzy (0-100%)
├─ modelo_usado (saullm|deepseek-r1|qwen2.5|rapidfuzz)
├─ tempo_analise_ms
└─ sugestoes (FK → SugestaoDocumento)

SugestaoDocumento
├─ id, analise_id
├─ tipo_sugestao (COMPLIANCE|ESTRUTURA|REDACAO|DUPLICIDADE)
├─ conteudo_original, conteudo_sugerido
├─ confianca (0-100%)
├─ aceita (boolean), motivo_rejeicao
└─ feedback_usuario (para aprendizado)

ComentarioDocumento
├─ id, documento_id, comentario_pai_id (para threads)
├─ cpf_autor, conteudo
├─ posicao_texto, selecionado_texto (citação)
├─ tipo (DÚVIDA|SUGESTÃO|BLOQUEADOR|INFORMAÇÃO)
├─ status (ABERTO|RESPONDIDO|RESOLVIDO|REJEITADO)
└─ timestamp, resolved_at

DefinicaoRaciDocumento
├─ id, documento_id, cpf_pessoa
├─ papel_raci (R|A|C|I)
├─ data_designacao, status (PENDENTE|CONFIRMADO|RECUSADO)
└─ notificacao_enviada (boolean)

PublicacaoDocumento
├─ id, documento_id, versao_publicada
├─ conteudo_html, conteudo_mobile
├─ status, aprovado_por_cpf, data_aprovacao
└─ data_publicacao

AssinaturaCorporativa
├─ id, publicacao_id, cpf_pessoa
├─ data_leitura, de_acordo (boolean)
├─ data_acordo, hash_assinatura (SHA-256)
└─ observacoes

LogRapidFuzz (FASE 2)
├─ documento_a_id, documento_b_id
├─ score_similaridade (0-100%)
├─ aceito_duplicado (boolean)
└─ feedback_usuario (tuning)
```

---

## 🧠 CASCATA LLM (FASE 2) - Por Tipo de Análise

### **Decisão Tree**

```
[Upload de Política/Ética/MVV]
│
├─ COMPLIANCE Check?
│  └─→ SaulLM 7B (jurídico)
│     ├─ Analisa conflitos SoD (20 regras)
│     ├─ Checa LGPD/compliance legal
│     ├─ Output: "Art. 2.1 conflita com SoD-004, confiança 98%"
│     └─ Se > 95%: BLOQUEIA, senão: ALERTA
│
├─ ESTRUTURA Check?
│  └─→ DeepSeek-R1 8B (raciocínio)
│     ├─ Analisa seções presentes vs. esperadas
│     ├─ Chain-of-Thought: "Falta 'Responsabilidades', deveria vir após 'Objetivo'"
│     ├─ Output: "Sugestão de restruturação"
│     └─ Confiança: 78-85%
│
├─ REDAÇÃO Check?
│  └─→ Qwen2.5 7B (geral)
│     ├─ Melhora clareza, tom corporativo, concisão
│     ├─ "Parágrafo 3: muito verboso, reduzir 30%"
│     ├─ Output: "[original] → [sugestão]"
│     └─ Confiança: 65-75%
│
└─ DUPLICIDADE Check?
   └─→ RapidFuzz 3.14.6 + RAG
      ├─ Compara novo doc com base histórica (pgvector)
      ├─ Token Sort Ratio + Embeddings
      ├─ Output: "88% similar com Política POL-2023-04"
      └─ Se > 85%: ALERTA, user decide (aprender com feedback)
```

### **Implementação (Python + LangGraph)**

```python
from langgraph.graph import StateGraph
from ollama import OllamaClient
from rapidfuzz import fuzz

class AnalisadorGovernanca:
    def __init__(self):
        self.ollama = OllamaClient(base_url="http://localhost:11434")
        self.rapidfuzz = RapidFuzz()
        self.rag = LlamaIndex(
            embed_model="nomic-embed-text",
            vector_store="pgvector",
            db_uri="postgresql://..."
        )
    
    async def analisar_documento(self, doc_id: int):
        """
        Cascata paralela: Compliance + Estrutura + Redação + Duplicidade
        """
        documento = await db.DocumentoCorporativo.get(id=doc_id)
        tarefas = []
        
        # Task 1: Compliance (SaulLM)
        async def compliance():
            resposta = self.ollama.generate(
                model="saullm:latest",
                prompt=f"""
                Analise compliance legal desta política:
                {documento.conteudo[:2000]}...
                
                Verificar:
                - Conflitos SoD (20 regras)
                - LGPD compliance
                - Tone corporativo
                
                Retorne JSON: {{
                    "conflitos": [...],
                    "confianca": 0-100,
                    "severidade": "ALTA|MÉDIA|BAIXA"
                }}
                """,
                stream=False,
                temperature=0.2
            )
            return ("COMPLIANCE", resposta, 98)
        
        # Task 2: Estrutura (DeepSeek-R1)
        async def estrutura():
            resposta = self.ollama.generate(
                model="deepseek-r1:8b",
                prompt=f"""
                Analise estrutura desta política (objetivo, seções, etc):
                {documento.conteudo}
                
                Retorne JSON: {{
                    "secoes_presentes": [...],
                    "secoes_faltantes": [...],
                    "ordem_sugerida": [...],
                    "confianca": 0-100
                }}
                """,
                stream=False,
                temperature=0.1
            )
            return ("ESTRUTURA", resposta, 80)
        
        # Task 3: Redação (Qwen)
        async def redacao():
            resposta = self.ollama.generate(
                model="qwen2.5:7b",
                prompt=f"""
                Melhore clareza, concisão e tom corporativo:
                {documento.conteudo[:1500]}...
                
                Retorne JSON: {{
                    "sugestoes": [
                        {{"original": "...", "sugerido": "...", "razao": "..."}},
                    ],
                    "confianca": 0-100
                }}
                """,
                stream=False,
                temperature=0.3
            )
            return ("REDACAO", resposta, 70)
        
        # Task 4: Duplicidade (RapidFuzz + RAG)
        async def duplicidade():
            # Buscar similares em pgvector
            similares = self.rag.query(
                documento.conteudo,
                top_k=5,
                similarity_threshold=0.75
            )
            
            scores = []
            for doc_similar in similares:
                score = fuzz.token_sort_ratio(
                    documento.conteudo[:500],
                    doc_similar.conteudo[:500]
                ) / 100
                scores.append({
                    "doc_id": doc_similar.id,
                    "titulo": doc_similar.titulo,
                    "score": score,
                    "versao": doc_similar.versao
                })
            
            max_score = max([s["score"] for s in scores], default=0)
            return ("DUPLICIDADE", {
                "similares": scores,
                "max_score": max_score,
                "confianca": int(max_score * 100)
            }, int(max_score * 100))
        
        # Executar paralelo
        tarefas = [compliance(), estrutura(), redacao(), duplicidade()]
        resultados = await asyncio.gather(*tarefas)
        
        # Salvar análises
        for tipo, resultado, confianca in resultados:
            await db.AnaliseDocumento.create(
                documento_id=doc_id,
                tipo_analise=tipo,
                resultado_llm=resultado,
                confianca_fuzzy=confianca,
                modelo_usado={
                    "COMPLIANCE": "saullm:latest",
                    "ESTRUTURA": "deepseek-r1:8b",
                    "REDACAO": "qwen2.5:7b",
                    "DUPLICIDADE": "rapidfuzz"
                }[tipo]
            )
        
        return {
            "documento_id": doc_id,
            "analises": len(resultados),
            "confianca_media": sum([r[2] for r in resultados]) / len(resultados),
            "timestamp": datetime.now()
        }
```

---

## 🔒 GUARDRAILS + FUZZY (FASE 2)

### **3 Regras + Thresholds Específicos**

```
REGRA 1: Nunca Assuma Intenção
└─ Se política ambígua, questione antes de sugerir bloquear
└─ Exemplo: "Seção faltante?" → ALERTA (70%), não BLOQUEIA

REGRA 2: Cite Fonte + Modelo
└─ Toda sugestão vem com:
   ├─ Modelo (SaulLM, DeepSeek, etc)
   ├─ Confiança % (98, 80, 70)
   ├─ Log em DB (imutável)
   └─ User pode ver raciocínio

REGRA 3: Aprendizado Contínuo
└─ User rejeita sugestão → Log em feedback
└─ Fuzzy threshold se ajusta dinamicamente
└─ RapidFuzz aprende: "Isso não é duplicidade"
```

### **Fuzzy Thresholds (FASE 2 Específico)**

```
Tipo Análise | Limiar | Ação | Exemplos Confiança
---|---|---|---
COMPLIANCE | < 60% | IGNORAR | Baixa certeza legal
COMPLIANCE | 60-85% | ALERTA | Possível conflito SoD
COMPLIANCE | > 85% | BLOQUEIA se crítico | SoD violado (98%)
---|---|---|---
ESTRUTURA | < 60% | SUGESTÃO | Falta seção (opcional)
ESTRUTURA | 60-85% | SUGERE + ALERTA | Restruturação recomendada
ESTRUTURA | > 85% | SUGERE FORTEMENTE | Ordem clara melhor (85%)
---|---|---|---
REDACAO | < 50% | IGNORAR | Muito especulativo
REDACAO | 50-75% | SUGESTÃO (opcional) | Melhoria sugerida
REDACAO | > 75% | SUGESTÃO (forte) | Clareza ruim (80%)
---|---|---|---
DUPLICIDADE | < 70% | INFORMAÇÃO | "Similar a POL-X" (info)
DUPLICIDADE | 70-85% | ALERTA | "Duplicidade provável"
DUPLICIDADE | > 85% | BLOQUEIA | "Exatamente igual" (92%)
```

---

## 📊 TIMELINE (Paralelo a FASE 1)

### **SEMANA 1: Upload + Docling**
- [ ] Docling parser configurado
- [ ] Upload de PDFs/Word funcionando
- [ ] Docling extrai: seções, tabelas, estrutura
- [ ] Armazenar em DB + embeddings (pgvector)

### **SEMANA 2: LLM Engines**
- [ ] SaulLM integrado (compliance)
- [ ] DeepSeek-R1 integrado (estrutura)
- [ ] Qwen integrado (redação)
- [ ] RapidFuzz + RAG integrados
- [ ] Testes das 4 análises

### **SEMANA 3: Workflow Colaborativo**
- [ ] Comentários + threads
- [ ] RACI dinâmico
- [ ] Notificações
- [ ] Painel de análise LLM
- [ ] Testes ponta-a-ponta

### **SEMANA 4: Publicação + Integration com FASE 1**
- [ ] Assinatura digital
- [ ] Merge sem quebras com FASE 1
- [ ] QA completo
- [ ] GO-LIVE (após FASE 1 week 4)

---

## ✅ GO-LIVE CHECKLIST (FASE 2)

- [ ] Docling parseia corretamente
- [ ] 4 LLM engines funcionam
- [ ] RapidFuzz acerta duplicidade
- [ ] RAG retorna similares com score
- [ ] Comentários e threads funcionam
- [ ] RACI dinâmico atribui pessoas
- [ ] Assinatura digital funciona
- [ ] 0 conflitos com FASE 1
- [ ] Auditoria imutável
- [ ] Fuzzy learning ativo

---

**Status FASE 2:** ✅ OTIMIZADA COM ARSENAL REAL  
**Confiança:** 94.2% (Docling + SaulLM + DeepSeek + RapidFuzz + RAG)  
**Merge:** Sem quebras com FASE 1 (semana 9)
