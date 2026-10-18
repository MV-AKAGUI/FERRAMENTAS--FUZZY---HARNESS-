# 🔄 DOCUMENTO INTERMEDIÁRIO: Pivô de Comunicação - Correção de Requisitos

**Data:** 2026-10-16  
**Status:** Registro de Erro Inicial & Correção Necessária  
**Autoria:** Ronaldo Akagui + Dai_Vibe_Code

---

## ❌ ERRO INICIAL (O que o Dai_Vibe_Code entendeu)

### Visão Proposta Inicialmente
O sistema seria um **gestor/executor de processos já definidos**:
- Zeev como hub orquestrador central
- SUGOI_CADEIA_DE_VALOR como camada de execução
- Sincronização automática com SIENGE, CRM, PAM
- **Foco:** Rodar processos que já existem

### Problema
- ✗ Assumiu que os processos estavam **já desenhos e documentados**
- ✗ Ignorou que o G&G **ainda está criando** a cadeia de valor
- ✗ Pulou a fase de **design + guia + validação**
- ✗ Tratou como "próximo passo" o que é na verdade **este passo**

---

## ✅ CORREÇÃO (O que o usuário realmente quer)

### Nova Visão: Expert System Condutor
O sistema é um **guia + validador + condutor inteligente** para o G&G e TI-Processos **terminarem de desenhar** a cadeia de valor da SUGOI:

**Objetivo Primário:**
> Conduzir o G&G (que não é sênior em processos/BPM/HAP) através da construção correta da Cadeia de Valor, travando desvios, validando em tempo real, educando, e garantindo qualidade antes de publicar.

**Objetivos Secundários:**
1. Mapear a cadeia de valor seguindo método HAP (4 níveis)
2. Estruturar EAP conciliada (5 níveis: UC → CC → ET → SET → COMP)
3. Desenhar BPM (fluxos, nós, transições)
4. Documentar POPs, ITs, Checklists (fora de planilhas)
5. Validar RACI (quem faz o quê)
6. Detectar rupturas, duplicidades, gargalos
7. Garantir SLA, Entregáveis, Criticidade
8. Detectar anti-ociosidade (ninguém fica parado)
9. Rastrear passivos (contratos, assessorias não entregues)
10. Exportar para 4 sistemas downstream (PJ, Zeev, PAM, Portal)

---

## 🔒 TRAVÕES (Constraints/Validators Embarcados)

O sistema **trava** o G&G em desvios gritantes usando lógica fuzzy + harness protocol:

### Travão 1: BPM Estrutural
```
IF nó_desenhado WITHOUT cadeira_responsavel
THEN BLOQUEIA aprovação
ALERT "Nó #{id}: Cadeira responsável obrigatória"
CONFIDENCE 99%
```

### Travão 2: HAP (4 Níveis)
```
IF composição_eap NOT MATCHES UC→CC→ET→SET→COMP
THEN WARN "Estrutura EAP fora do padrão HAP"
SUGGESTION "Deseja reestruturar?"
CONFIDENCE 95%
```

### Travão 3: SoD (20 Regras)
```
IF cadeira_A = Maker AND cadeira_A = Checker (mesmo nó)
THEN BLOQUEIA
ERROR "Violação SoD-003: Maker ≠ Checker"
CONFIDENCE 98%
```

### Travão 4: Documentação
```
IF nó_atividade_criado WITHOUT tipo_doc_associado
THEN DIRECIONA "Próximo: Qual é o tipo de doc? POP / IT / Checklist?"
GUIDANCE "POP = procedimento completo, IT = instruções técnicas, Checklist = itens verificáveis"
```

### Travão 5: Entregáveis Vinculados
```
IF nó_saída_entregavel = VAZIO
THEN ALERTA "Atividade #{id} não tem entregável vinculado"
SUGGESTION "Escolha entre 75 entregáveis oficiais ou crie novo"
CONFIDENCE 92%
```

### Travão 6: Duplicidade
```
IF setor_A.tarefa_X ≈ setor_B.tarefa_Y (similar_score > 0.85)
THEN ALERTA "Possível duplicidade entre Setor A e B"
ASKS "É a mesma tarefa ou variação?"
GUIDES "Centralizar ou criar especialização?"
```

### Travão 7: Gargalo de SLA
```
IF nó.sla_prazo > setor.sla_medio * 1.5
THEN AVISO "SLA desta atividade está 50% acima da média"
ASKS "É intencional? Há motivo?"
SUGGESTS "Considere dividir em sub-atividades"
```

### Travão 8: Anti-Ociosidade
```
IF cadeira.atividades_atribuidas = 0
THEN AVISO "Cadeira #{cadeira_id} não tem atividades"
GUIDES "Revise a estrutura ou adicione atividades"
```

### Travão 9: RACI Incompleta
```
IF nó WITHOUT (Responsável OR Aprovador)
THEN BLOQUEIA "RACI obrigatória: mínimo Responsável + Aprovador"
GUIDANCE "R = Responsible, A = Accountable, C = Consulted, I = Informed"
```

### Travão 10: Passivos Não Rastreados
```
IF nó_gera_contrato OR nó_gera_assessoria
THEN EXIGE vincular "Objeto + Entregáveis + SPE"
TRAVA "Não pode aprovar sem rastreamento de passivo"
```

---

## 🧠 Papel do Dai_Vibe_Code (LLM Expert)

**Antes:** Dai pensava em "sistema executivo" (rodar processos)  
**Agora:** Dai pensa em "sistema educador + validador" (criar processos certos)

### O que Dai fará:
1. ✅ Propor LLMs específicos para cada validação
2. ✅ Desenhar a fuzzy logic dos alertas (0-100% confiança)
3. ✅ Harness protocol: gates, alçadas de aprovação
4. ✅ Knowledge base integrada (dicas, templates, educação)
5. ✅ Auditoria do trabalho ANTES de publicar (não depois)
6. ✅ Sugestões automáticas baseadas em padrões HAP/BPM
7. ✅ Detecção de rupturas e gargalos em tempo real

---

## 📋 Base Fixa (O que NÃO muda)

Essas definições já estão prontas e **imutáveis** no sistema:

- ✅ **14 Setores** (lista oficial, codificação fixa)
- ✅ **PAM-IGA** (estrutura de acesso, cadeiras base)
- ✅ **Cadeiras** (lista oficial, alçadas)
- ✅ **Fluxograma V10** (em evolução, diagramas de referência)
- ✅ **EAP Orçamento** (Admin + Obras, em finalização)
- ✅ **Material HAP** (sharepoint, método consolidado)
- ✅ **Políticas Corporativas** (SoD, compliance, já definidas)

---

## 🎯 Próximos Passos

1. **Fase 0 (Agora):** Dai_Vibe_Code em modo "análise + design"
   - Propor arquitetura de validadores
   - Mapear LLMs específicos
   - Desenhar fuzzy logic + harness
   
2. **Fase 1 (Próximo):** Compilar "FASE 1 REVISADO"
   - Prisma schema (com validators)
   - APIs (com regras de negócio)
   - Backend logic (validações + guias)

3. **Fase 2 (Depois):** Frontend + Canvas
   - Home page com 14 Setores
   - Design canvas para desenhar processos
   - Documentação estruturada

4. **Fase 3 (Finalmente):** Exportadores
   - → Contratação PJ
   - → Zeev
   - → PAM-IGA
   - → Portal SUGOI

---

## 📌 Síntese da Correção

| Aspecto | ❌ Antes | ✅ Agora |
|---|---|---|
| **Fase** | Downstream (executar) | Upstream (desenhar) |
| **Usuário** | Operadores | G&G + TI-Processos |
| **Objetivo** | Rodar processos | Criar processos corretos |
| **Abordagem** | Integração com Zeev | Expert system condutor |
| **Validação** | Pós-execução | Em tempo real |
| **LLM Role** | Executor | Pensador + Validador |
| **Travões** | 5 (SoD, auditoria) | 10+ (BPM, HAP, EAP, duplicidade, gargalo, etc) |

---

**Status:** Documento de Referência Histórica  
**Próximo:** Invocar Dai_Vibe_Code para FASE 1 REVISADO
