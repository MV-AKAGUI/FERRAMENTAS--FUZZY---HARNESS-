# Prompt Padrão: Dai via Claude Code

**Uso:** Invoke Dai_Vibe_Code pelo Claude Code para discovery, grill-me, anatomia.

---

## 🎯 Template Básico

```bash
claude /dai-vibe-code \
  --mode "discovery" \
  --briefing "[SEU BRIEFING AQUI]" \
  --backend "ollama-deepseek-r1"
```

---

## 📋 Elementos Obrigatórios do Briefing

Sempre forneça (mesmo que resumido):

```
O QUÊ:     [Tipo de aplicação/sistema]
POR QUÊ:   [Motivação/problema que resolve]
PARA QUEM: [Usuários/personas]
RESTRIÇÃO: [Budget / Tempo / Compliance / Tech]
VOLUME:    [Usuários, QPS, dados/mês]
```

---

## 📚 Exemplos de Invocação

### **Exemplo 1: MVP Simples**
```bash
claude /dai-vibe-code \
  --mode "discovery" \
  --briefing "
    O QUÊ: Plataforma SaaS de gestão de tarefas
    POR QUÊ: Centralizar work items do time
    PARA QUEM: 50 startups (5 users cada)
    RESTRIÇÃO: Budget $10k MVP, 2 semanas
    VOLUME: 250 usuarios, 100 QPS pico
  " \
  --backend "ollama-deepseek-r1"
```

### **Exemplo 2: Enterprise com Compliance**
```bash
claude /dai-vibe-code \
  --mode "discovery" \
  --briefing "
    O QUÊ: Sistema de gestão de portfolios com LGPD
    POR QUÊ: Compliance + análise de startups
    PARA QUEM: Fundos de VC, 100 gestores
    RESTRIÇÃO: LGPD obrigatória, $50k MVP
    VOLUME: 1k simultâneos, dados sensíveis
  " \
  --backend "ollama-deepseek-r1"
```

---

## 🎬 Fluxo de Execução Esperado

**Passo 1: Dai Escuta Ativa** (~2 min)
```
📊 CONTEXTO CAPTURADO
├── Negócio: [descrição]
├── Stakeholders: [lista]
├── Restrições: [lista]
└── Incertezas: [com confiança %]
```

**Passo 2: Dai Grill-Me** (~5 min)
```
✅ PREMISSAS VALIDADAS
├── Pergunta 1: [resposta] | Confiança X%
├── Pergunta 2: [resposta] | Confiança Y%
└── ... até 7 perguntas
```

**Passo 3: Dai Anatomia** (~10 min, SE confiança > 70%)
```
🏗️ ANATOMIA DESENHADA
├── C4 Diagram
├── SDD
├── Schemas Pydantic
├── RACI Matrix
└── Tech Stack
```

---

## 🛡️ Audição Claude Automática

Claude vai:
1. ✅ Receber output do Dai
2. ✅ Validar confiança % (está > 70%?)
3. ✅ Identificar RED FLAGS não explorados
4. ✅ Sugerir refinements se necessário
5. ✅ Marcar "Ready for Antigravity" ou "Needs Refinement"

---

## 🚨 Quando Usar Este Prompt

- ✅ MVP/conceitual rápido
- ✅ Cloud quota baixa
- ✅ Precisa reasoning offline
- ✅ **Recomendado para GRILL-ME** (sem alucinação)

---

## ❌ Quando NÃO Usar

- ❌ Produção sem aprovação RACI
- ❌ Dados sensíveis sem legal review
- ❌ Gates críticos (PostgreSQL, Docker, Prod)

Use **Antigravity** para esses cenários.

---

**Status:** Pronto para usar. Copie template + customize briefing.
