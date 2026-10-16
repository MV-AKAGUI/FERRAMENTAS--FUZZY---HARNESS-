# 🛡️ POLICY OFICIAL: Guardrails Anti-Alucinação + Fuzzy Thresholds

**Versão:** 1.0 | **Status:** PUBLICADA | **Data:** 2026-10-16  
**Escopo:** FASE 1 + FASE 2 | **Validada por:** Dai_Vibe_Code + Ronaldo Akagui  
**Obrigatória:** SIM (todos os endpoints, validadores, LLM calls)

---

## 🔒 3 GUARDRAILS OBRIGATÓRIOS

### **GUARDRAIL 1: Nunca Assuma Dados**

**Regra:**
```
IF (entrada ambígua ou ausente)
    THEN questione OU use default conservador
    NOT adivinhe
```

**Aplicação:**

| Cenário | ❌ ERRADO | ✅ CORRETO |
|---------|----------|----------|
| Cadeira desconhecida | "Vou usar Técnico" | BLOQUEIA (cadeira obrigatória) |
| Setor não informado | "Provavelmente Operações" | ALERTA (setor fixo, obrigatório) |
| RACI incompleta | "Vou preencher A" | BLOQUEIA (R + A mínimo) |
| RapidFuzz < 70% | "Parece duplicado" | INFORMAÇÃO (não bloqueia) |

**Implementação:**
```javascript
if (!req.body.cadeira_id) {
    throw Error("Cadeira obrigatória (nunca assume)");
}

if (!pessoa) {
    throw Error("CPF não cadastrado (nunca assume ativo)");
}

if (rapidfuzz_score < 70) {
    log.info("Similar, mas < 70%, apenas informar");
    // NÃO bloqueia
}
```

---

### **GUARDRAIL 2: Cite Fonte Confiável**

**Regra:**
```
Toda afirmação técnica OU resultado LLM deve ter:
├─ Modelo usado (deepseek-r1:8b, saullm, rapidfuzz, etc)
├─ Timestamp exato
├─ Confiança % (fuzzy score)
├─ Log em DB (imutável)
└─ Rastreabilidade completa
```

**Aplicação:**

| Tipo | Exemplo | Fonte |
|------|---------|-------|
| **LLM** | "Art. 2.1 conflita com SoD-004" | SaulLM, timestamp, 98% |
| **RapidFuzz** | "88% similar com POL-2023-04" | RapidFuzz, score, log_id |
| **Estrutura** | "Seção 'Responsabilidades' falta" | DeepSeek-R1, timestamp, 82% |
| **SoD** | "Violação SoD-001" | Harness determinístico, 100% |

**Implementação:**
```python
resultado = {
    "validacao": "BPM estrutural",
    "modelo": "deepseek-r1:8b",
    "confianca": 95,
    "timestamp": "2026-10-16 14:30:45",
    "log_id": "audit_abc123xyz",
    "resultado": "BPM válido",
    "tempo_ms": 18500
}

db.AnaliseDocumento.create(resultado)
# Nunca afirmar sem rastreamento
```

---

### **GUARDRAIL 3: Marque Incerteza Explicitamente**

**Regra:**
```
[ALTA 95%]   = Certeza quase total
[MÉDIA 75%]  = Provavelmente sim, mas validar
[BAIXA 40%]  = Especulação, alertar
[DESCONHECIDO ?] = Investigar antes de proceder
```

**Aplicação:**

| Confiança | Ação | Exemplo |
|-----------|------|---------|
| [ALTA 99%] | PROCEDER | "SoD validado, sem violação" |
| [ALTA 95%] | PROCEDER | "DeepSeek: BPM estrutural OK" |
| [MÉDIA 80%] | PROCEDER + LOG | "RapidFuzz: 80% similar, informar user" |
| [MÉDIA 70%] | ALERTA | "Estrutura subótima, sugerir" |
| [BAIXA 50%] | SUGESTÃO LEVE | "Talvez reescrever, opcional" |
| [BAIXA 30%] | IGNORAR | "Confiança muito baixa, não mostrar" |
| [DESCONHECIDO ?] | BLOQUEIA | "Não testado, requer investigação" |

**Implementação:**
```python
def marcar_confianca(resultado, modelo, threshold):
    confianca = resultado['score'] * 100
    
    if confianca >= 95:
        nivel = "ALTA"
        acao = "PROCEDER"
    elif 70 <= confianca < 95:
        nivel = "MÉDIA"
        acao = "ALERTA + SUGESTÃO"
    elif 30 <= confianca < 70:
        nivel = "BAIXA"
        acao = "SUGESTÃO LEVE"
    else:
        nivel = "DESCONHECIDO"
        acao = "BLOQUEIA"
    
    return {
        "nivel": nivel,
        "confianca": confianca,
        "acao": acao,
        "modelo": modelo,
        "timestamp": now()
    }
```

---

## 📊 FUZZY CONFIDENCE THRESHOLDS

### **FASE 1: Processos & Documentação**

| Tipo Validação | Threshold | Ação | Exemplo |
|---|---|---|---|
| **BPM Estrutural** | |  |  |
| < 60% | ⚠️ ALERTA | "Nó sem cadeira", alertar |
| 60-85% | ⚠️ ALERTA | "Cadeia confusa", sugerir |
| > 85% | 🔴 BLOQUEIA | "Cadeia faltando", trava |
| **HAP 4-Níveis** | |  |  |
| < 70% | ℹ️ INFO | "Estrutura subótima", apenas mostrar |
| 70-90% | ⚠️ ALERTA | "Restruturação sugerida" |
| > 90% | 🔴 BLOQUEIA | "Hierarquia violada", trava |
| **SoD (20 Regras)** | |  |  |
| 0-99% | 🔴 BLOQUEIA | "Determinístico, sem margem" |
| 100% | 🔴 BLOQUEIA | "Regra confirmada, sem exceção" |
| **RapidFuzz Duplicidade** | |  |  |
| < 70% | ℹ️ INFO | "Similares encontrados, FYI" |
| 70-85% | ⚠️ ALERTA | "Possível duplicidade" |
| > 85% | 🔴 BLOQUEIA | "Exatamente igual", trava |
| **Entregáveis Obrigatórios** | |  |  |
| Faltante | 🔴 BLOQUEIA | "Entregável obrigatório ausente" |
| **SLA Gargalo** | |  |  |
| > 50% acima da média | ⚠️ ALERTA | "SLA atípico, revisar" |
| **RACI Incompleta** | |  |  |
| Faltante R ou A | 🔴 BLOQUEIA | "R + A obrigatório" |

---

### **FASE 2: Governança Corporativa**

| Tipo Análise | Threshold | Ação | Exemplo |
|---|---|---|---|
| **Compliance (SaulLM)** | |  |  |
| < 60% | ℹ️ INFO | "Possível conflito, investigar" |
| 60-85% | ⚠️ ALERTA | "Conflito SoD provável" |
| > 85% | 🔴 BLOQUEIA se crítico | "SoD-004 violado (98%)" |
| **Estrutura (DeepSeek)** | |  |  |
| < 60% | ℹ️ INFO | "Estrutura aceitável" |
| 60-80% | ⚠️ ALERTA | "Restruturação recomendada" |
| > 80% | 🔴 SUGERE FORTE | "Ordem muito melhor" |
| **Redação (Qwen)** | |  |  |
| < 50% | 🚫 IGNORAR | "Muito especulativo" |
| 50-75% | ℹ️ SUGESTÃO | "Melhoria sugerida" |
| > 75% | ⚠️ SUGESTÃO FORTE | "Clareza ruim, reescrever" |
| **Duplicidade (RapidFuzz)** | |  |  |
| < 70% | ℹ️ INFO | "Similares no histórico" |
| 70-85% | ⚠️ ALERTA | "Duplicidade provável" |
| > 85% | 🔴 BLOQUEIA | "Política já existe (92%)" |

---

## 🧠 CASCATA DE MODELOS (Quem Usar)

### **Decisão Tree Implementada**

```
[Entrada de Validação]
│
├─ BPM estrutural? → DeepSeek-R1 8B (95% confiança)
├─ HAP/EAP? → DeepSeek-R1 8B → Qwen Coder
├─ SoD (20 regras)? → Harness determinístico (100%)
├─ Compliance jurídico? → SaulLM 7B (98%)
├─ Redação? → Qwen2.5 7B (70-75%)
└─ Duplicidade? → RapidFuzz + RAG (80-92%)

Todos retornam: { resultado, confianca%, modelo, timestamp, log_id }
```

### **Ordem de Confiabilidade**

```
1. Harness Determinístico (SoD, regras fixas) → 100%
2. SaulLM (jurídico, compliance) → 95-98%
3. DeepSeek-R1 (raciocínio investigativo) → 90-95%
4. RapidFuzz (fuzzy matching) → 80-92%
5. Qwen Coder (geração de código) → 85-90%
6. Qwen2.5 (consolidação/redação) → 70-80%
```

---

## 📝 IMPLEMENTAÇÃO DO PIPELINE

### **Pseudocódigo Universal**

```python
def validar_com_guardrails(entrada, tipo_validacao):
    """
    Pipeline que aplica 3 guardrails + fuzzy thresholds
    """
    
    # GUARDRAIL 1: Nunca assuma
    if not entrada or entrada is ambiguous:
        usar_default_conservador()  # ou blocar
    
    # Executar validador
    resultado = executar_validador(entrada, tipo_validacao)
    
    # GUARDRAIL 2: Cite fonte
    resultado_com_fonte = {
        "validacao": tipo_validacao,
        "modelo": resultado['modelo'],
        "confianca": resultado['score'] * 100,
        "timestamp": datetime.now(),
        "log_id": db.generate_audit_id(),
        "resultado": resultado['output']
    }
    
    # Salvar em DB (imutável)
    db.LogValidador.create(resultado_com_fonte)
    
    # GUARDRAIL 3: Marque incerteza
    confianca = resultado_com_fonte['confianca']
    acao = determinar_acao_por_threshold(confianca, tipo_validacao)
    
    return {
        "valido": acao != "BLOQUEIA",
        "confianca": confianca,
        "acao": acao,
        "mensagem": gerar_mensagem_usuario(acao, confianca),
        "log_id": resultado_com_fonte['log_id']
    }
```

---

## 🔄 APRENDIZADO CONTÍNUO (Fuzzy Tuning)

### **Como o Sistema Aprende**

```
1. USER REJEITA SUGESTÃO
   └─ "Isso não é duplicado!"
   └─ Feedback armazenado em DB

2. AJUSTE DE THRESHOLD
   └─ RapidFuzz: aumentar threshold para 88% (era 85%)
   └─ Log: "Usuario rejeitou 3x score 82%, ajustou para 88%"

3. PRÓXIMA EXECUÇÃO
   └─ RapidFuzz com novo threshold
   └─ Menos falsos positivos

Exemplo:
└─ LogRapidFuzz: { score: 82%, rejeitado: true, feedback: "falso positivo" }
└─ Sistema: "Aumentar threshold de 85% para 88%"
└─ DB: UPDATE validation_rules SET threshold = 88% WHERE tipo = 'duplicidade'
```

### **RapidFuzz Memory (Histórico)**

```
DocumentoA: "Política de Viagens 2024"
DocumentoB: "Política de Viagens 2023"
Score: 92% (similar)

User: "Não é duplicação, versões diferentes"

LogRapidFuzz: {
    doc_a: A_id,
    doc_b: B_id,
    score: 92,
    aceito_duplicado: false,
    feedback: "versoes diferentes",
    aprender: true
}

Sistema aprende: "92% entre versões diferentes = não é duplicação sempre"
```

---

## 🚫 O QUE NUNCA FAZER

```
❌ Usar LLM sem guardrails (pode alucinar)
❌ Assumir confiança 100% (exceto Harness determinístico)
❌ Não logar decisões (auditoria essencial)
❌ Usar thresholds manuais (deve ser em DB, ajustável)
❌ Confiar em models sem cite de fonte
❌ Ignorar feedback do usuário
❌ Permitir "fuzzy tolerance" em SoD (determinístico)
❌ Armazenar PII sem criptografia
❌ Não documentar alterações de threshold
```

---

## 📋 CHECKLIST IMPLEMENTAÇÃO

- [ ] 3 Guardrails documentados em README
- [ ] Toda chamada LLM retorna { modelo, confianca%, timestamp, log_id }
- [ ] DB logs imutáveis (append-only)
- [ ] Fuzzy thresholds em tabela (não hardcoded)
- [ ] RapidFuzz com memory learning
- [ ] Harness SoD 100% determinístico
- [ ] Testes: guardrails impedem alucinação
- [ ] Testes: fuzzy thresholds respeitados
- [ ] Documentação de cada validador
- [ ] Monitoramento de confiança média

---

**Status:** ✅ POLICY OFICIAL PUBLICADA  
**Obrigatoriedade:** TOTAL (todos endpoints, validadores)  
**Não Negociável:** 3 Guardrails + Fuzzy Thresholds + Auditoria Imutável
