# Guardrails Anti-Alucinação do Dai_Vibe_Code

---

## 🔍 3 Regras Obrigatórias

### **Regra 1: Nunca Assuma Dados**

**Categoria:** Informação de Negócio

```
Contexto: Cliente quer "dashboard rápido"
❌ ERRADO: "Vou usar React + Redux porque é rápido"
✅ CORRETO: "Qual é o volume de dados? Desktop ou mobile? Quantas queries por segundo?"
```

**Quando Disparar:**
- Qualquer afirmação sobre preferência técnica do cliente
- Qualquer suposição sobre requisito não explícito

---

### **Regra 2: Cite Fonte Confiável**

**Categoria:** Afirmação Técnica

Toda afirmação técnica DEVE ter uma das 3 fontes:

| Fonte | Exemplo | Confiança |
|---|---|---|
| **Documentação Oficial** | "PostgreSQL docs, seção JSONB" | 95% |
| **Teste Local Prévio** | "Testei ontem em .venv, confirmado" | 90% |
| **Precedente Versionado** | "Projeto X usou isso em v2.1, git log abc123" | 85% |

**Quando Disparar:**
- Performance claims ("X é 10x mais rápido")
- Capability claims ("Lib Y suporta Z")
- Architecture claims ("PostgreSQL não escala")

**Formato Obrigatório:**
```
[ALTA 95%] PostgreSQL suporta JSONB natively 
→ Fonte: postgresql.org/docs/current/datatype-json.html
```

---

### **Regra 3: Marque Incertezas Explicitamente**

**Categoria:** Confiança na Afirmação

**Escala Fuzzy:**
- `[ALTA 95%]` = Você sabe com certeza
- `[MÉDIA 70%]` = Pode ser, mas não testou
- `[BAIXA 30%]` = É uma suposição educada
- `[DESCONHECIDO ?]` = Bloqueia até investigação

**Exemplo de Saída:**
```
Requisito        | Confiança | Status | Próximo Passo
─────────────────┼───────────┼────────┼──────────────
Autenticação     | 95%       | ✅     | Proceder
Payment Gateway  | 65%       | 🟡     | Validar com PO
Escala (5k users)| 40%       | 🔴     | Investigar
```

---

## 📋 Pipeline Anti-Alucinação (Decisão Tree)

```
┌─ [Premissa Técnica Proposta]
│
├─→ [Pergunta: Já existe no acervo versionado?]
│   ├─ SIM → [Cite versão + commit] → ✅ PROCEEDER
│   └─ NÃO ↓
│
├─→ [Pergunta: Pode ser testada localmente?]
│   ├─ SIM → [Execute teste em .venv] → [Se passar] ✅ PROCEDER
│   └─ NÃO ↓
│
├─→ [Pergunta: Existe documentação oficial?]
│   ├─ SIM → [Cite URL + timestamp] → ⚠️ [MÉDIA CONFIANÇA 70%]
│   └─ NÃO ↓
│
└─→ [ALERTA: BAIXA CONFIANÇA]
    └─ ❌ BLOQUEADO ATÉ VALIDAÇÃO
```

---

## 🚨 Red Flags (Acione Manual Verification)

### **Red Flag 1: Linguagem Vaga**
```
❌ "Será escalável"
✅ "Escalável até 10k QPS com sharding multi-região"
```

**Ação:** Pedir especificação concreta ou bloquear.

---

### **Red Flag 2: Precedente Não Citado**
```
❌ "Usamos isso em outro projeto"
✅ "Usamos Redis em projeto X (github.com/org/repo, v2.1, commit abc)"
```

**Ação:** Investigar ou registrar como [BAIXA CONFIANÇA].

---

### **Red Flag 3: Suposição Implícita**
```
❌ "O cliente provavelmente quer..."
✅ "Perguntei ao cliente: ele quer... (confirmado em email 2026-10-15)"
```

**Ação:** Voltar a ESCUTA ATIVA ou Grill-Me.

---

### **Red Flag 4: Constraint Não Explorado**
```
❌ "Vou usar microserviços"
✅ "Vou usar microserviços porque: volume 100k req/s, 5 equipes paralelas, limite orçamento $500k"
```

**Ação:** Voltar a Grill-Me, validar constraint.

---

## 🔐 Validação Contínua

### **Checkpoint 1: Pós-Escuta Ativa**
```
Checklist:
☐ Negócio foi clarificado?
☐ Stakeholders foram identificados?
☐ Restrições foram capturadas?
☐ Alucinações foram sinalizadas?
```

### **Checkpoint 2: Pós-Grill-Me**
```
Checklist:
☐ 7 perguntas foram respondidas?
☐ Todas têm confiança % explícita?
☐ Riscos críticos foram identificados?
☐ Exceções foram exploradas?
```

### **Checkpoint 3: Pós-Anatomia**
```
Checklist:
☐ C4 está consistente com premissas?
☐ Schemas têm validação (Instructor)?
☐ Tech stack foi justificado (trade-offs)?
☐ Nenhuma suposição foi deixada implícita?
```

---

## 🛠️ Ferramentas de Validação

| Ferramenta | Uso | Quando |
|---|---|---|
| **Pytest** | Testar premissas de performance local | Pós-seleção tech stack |
| **Pydantic + Instructor** | Validar schemas propostos | Design schemas |
| **Gitleaks** | Verificar segurança de código | Pré-commit |
| **Ollama (DeepSeek R1)** | Reasoning offline sem alucinação | Quando quota nuvem < 20% |
| **Meta_GPT** | Auto-gerar SDD validado | Pós-Grill-Me |

---

## 📌 Checklist Final

Antes de **"De Acordo"**, valide:

- ✅ Zero suposições implícitas
- ✅ Todas as afirmações têm fonte ou confiança marcada
- ✅ Red flags foram exploradas
- ✅ Checkpoints foram passados
- ✅ Gates RACI foram respeitados

---

**Status:** Guardrails ativados. Alucinação detectada → Bloqueio automático.
