# Prompt Padrão: Dai via Antigravity IDE

**Uso:** Invoke Dai_Vibe_Code pelo Antigravity PMO para discovery com governança RACI.

---

## 🎯 Template de Invocação

```bash
# No chat do Antigravity IDE
/agent dai-vibe-code \
  --mode "discovery" \
  --input "[SEU BRIEFING]" \
  --backend "ollama" \
  --governance "raci" \
  --webhook "enabled"
```

---

## 📋 Elementos Obrigatórios do Briefing

```
PROJETO:   [Nome do projeto]
O QUÊ:     [Tipo de sistema]
POR QUÊ:   [Motivação/OKR]
PARA QUEM: [Personas/stakeholders]
PO:        [Nome do Product Owner]
RESTRIÇÃO: [Budget / Prazo / Compliance]
VOLUME:    [Usuários / QPS / Data/mês]
```

---

## 📚 Exemplos de Invocação

### **Exemplo 1: Sprint Discovery**
```bash
/agent dai-vibe-code \
  --mode "discovery" \
  --input "
    PROJETO: Portfolio Management Platform (MVP)
    O QUÊ: Plataforma SaaS gestão de portfolios de startups
    POR QUÊ: Centralizar valuation + análise de investimentos
    PARA QUEM: Gestores de fundo, 100 users
    PO: João Silva (Product)
    RESTRIÇÃO: Budget $50k MVP, 6 semanas, LGPD compliance
    VOLUME: 1k simultâneos, 500 QPS, 50MB/mês dados
  " \
  --backend "ollama" \
  --governance "raci" \
  --webhook "enabled"
```

### **Exemplo 2: Enterprise com Compliance**
```bash
/agent dai-vibe-code \
  --mode "discovery" \
  --input "
    PROJETO: Regulatory Reporting System
    O QUÊ: Sistema de reportes para CVM/BACEN
    POR QUÊ: Automatizar compliance + reduzir risco regulatório
    PARA QUEM: Compliance team (20 users)
    PO: Maria Oliveira (Compliance Lead)
    RESTRIÇÃO: SOC2 required, zero downtime, $200k budget
    VOLUME: 100 users, 50 QPS, 1GB/mês dados sensíveis
  " \
  --backend "ollama" \
  --governance "raci" \
  --webhook "enabled"
```

---

## 🎬 Fluxo com Antigravity Gates

### **Fase 1: ESCUTA ATIVA** (2 min)
```
📊 CONTEXTO CAPTURADO
├── Negócio: [descrição]
├── Stakeholders + RACI preliminar
├── Restrições capturadas
└── Incertezas com confiança %
```
**Gate:** Continue? [Sim / Refinement / Cancelar]

### **Fase 2: GRILL-ME** (5 min)
```
✅ PREMISSAS VALIDADAS
├── 7 Perguntas socrática respondidas
├── Matriz de confiança preenchida
├── RED FLAGS identificados
└── Bloqueadores mapeados
```
**Gate:** "De Acordo?" [Sim / Refinement / Escalate]

### **Fase 3: ANATOMIA** (10 min, se confiança > 70%)
```
🏗️ ANATOMIA DESENHADA
├── C4 Diagram
├── SDD Document
├── Pydantic Schemas
├── RACI Matrix FINAL
├── Tech Stack + Trade-offs
└── Timeline + Fases
```
**Gate:** "De Acordo com Anatomia?" [Sim / Ajustes / Não]

### **Fase 4: AUTO-GERAÇÃO SDD** (5 min, se "De Acordo")
```
🤖 META_GPT ATIVADO
├── SDD completa auto-gerada
├── C4 refinado
├── Requisitos estruturados
└── Specs prontas para Dev
```
**Gate:** [Liberar para Dev / Ajustes / Rejeitar]

---

## 🔐 Governança RACI Automática

Antigravity **registra automaticamente:**

| Atividade | Responsável | Accountable | Consulted | Informado |
|---|---|---|---|---|
| Escuta Ativa | Dai | PO | Arquiteto | Dev |
| Grill-Me | Dai | PO | Tech Lead | Dev |
| Anatomia | Dai | Arquiteto | PO | Dev |
| SDD Auto | Meta_GPT | Arquiteto | - | Dev |
| Approval | PO | - | - | - |

---

## 🚨 RED FLAGS & Escalations

Dai detecta RED FLAG → Antigravity **bloqueia automaticamente**:

```
SEVERITY: CRITICAL (ex: LGPD sem DPO)
ESCALATE_TO: Legal/CISO/CFO
ACTION: Bloqueado até "De Acordo"
TIMELINE: Urgent (< 24h)
```

---

## 📊 Dashboard Antigravity

Após ativação, você verá:

```
┌─────────────────────────────────────────┐
│ DAI_VIBE_CODE EXECUTION DASHBOARD       │
├─────────────────────────────────────────┤
│ Projeto: Portfolio MVP                  │
│ Status: GRILL_ME_IN_PROGRESS            │
│ Confiança Média: 65% 🟡                 │
│ RED FLAGS: 2 (LGPD, Security)           │
│ Gate Status: AWAITING_REFINEMENT        │
│ Próximo Gate: "De Acordo?"              │
│ Timeline: Estimado 15 min               │
└─────────────────────────────────────────┘
```

---

## 🛡️ Validação Claude Paralela

Claude audita em paralelo:

- ✅ Confere confiança % (está consistente?)
- ✅ Identifica gaps não explorados
- ✅ Valida RED FLAGS
- ✅ Propõe ajustes se necessário
- ✅ Libera para próxima fase

---

## 🚀 Quando Usar Este Prompt

- ✅ Produção / Sprints reais
- ✅ Precisa governança RACI
- ✅ Dados sensíveis / Compliance
- ✅ **Recomendado para DISCOVERY oficial**
- ✅ Precisa rastreabilidade completa

---

## ❌ Quando NÃO Usar

- ❌ Prototipagem rápida
- ❌ Offline / sem internet
- ❌ Just a quick check

Use **Claude Template** para esses casos.

---

**Status:** Pronto para usar em Antigravity IDE. Copie template + customize input.
