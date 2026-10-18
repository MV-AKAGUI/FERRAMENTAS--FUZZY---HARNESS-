# Grill-Me Protocol: 7 Perguntas Socrática Obrigatórias

**Propósito:** Validar premissas antes de desenhar. Explorar edge-cases. Expor falhas de lógica.

---

## 📋 As 7 Perguntas

### **1️⃣ VALIDAÇÃO DE REQUISITOS (Edge-Cases)**

**Pergunta Núcleo:**
> *"O que acontece se [evento raro]? Como o sistema se comporta? Qual é o error handling?"*

**Exemplos Concretos:**
- "O que acontece se a API de pagamento cai por 1 hora?"
- "E se um usuário fizer 10k requisições simultâneas?"
- "E se a base de dados fica offline durante 5 minutos?"

**Saída Esperada:**
```
Cenário              | Comportamento Esperado | Confiança
─────────────────────┼───────────────────────┼──────────
API Payment down     | [sua resposta]        | X%
10k req simultâneos  | [sua resposta]        | Y%
DB offline 5min      | [sua resposta]        | Z%
```

**Red Flag:**
```
❌ "Não vai acontecer"
✅ "Graceful degradation: mostra msg, tenta retry, logs tudo"
```

---

### **2️⃣ DADOS & PRIVACY (Origem, Volume, Sensibilidade)**

**Pergunta Núcleo:**
> *"Qual é a origem dos dados? Qual é o volume? Que nível de sensibilidade? LGPD/GDPR/PCI?"*

**Sub-Perguntas:**
- Dados vêm de API externa ou user input?
- Volume: MB/mês, GB/ano, TB/3anos?
- Dados sensíveis? (PII, payment, health)
- Compliance: LGPD, GDPR, PCI-DSS, SOC2?

**Saída Esperada:**
```
Dado         | Origem    | Volume  | Sensibilidade | Compliance
─────────────┼───────────┼─────────┼───────────────┼────────────
User Profile | User input| 500MB/y | PII           | LGPD
Transactions | API ext   | 100GB/y | Payment       | PCI-DSS
Analytics    | Backend   | 50GB/y  | Agregado      | Nenhum
```

**Red Flag:**
```
❌ "Dados sensíveis, mas sem compliance plan"
✅ "PII data → encrypted at rest (AES-256), logs excluídos após 90 dias, LGPD audit ready"
```

---

### **3️⃣ ESCALABILIDADE (Usuários, SLA, Throughput)**

**Pergunta Núcleo:**
> *"Qual é o volume esperado em 12 meses? Qual é o SLA (uptime, latência)? Como você escalaria?"*

**Sub-Perguntas:**
- Usuários simultâneos hoje vs. 12 meses?
- QPS (queries per second) esperado?
- SLA de uptime (99.9%? 99.99%)?
- Latência aceitável (p99)?
- Como escala? Horizontal (replicas) ou vertical (instância maior)?

**Saída Esperada:**
```
Métrica          | Hoje  | 12 Meses | SLA    | Estratégia de Escala
─────────────────┼───────┼──────────┼────────┼─────────────────────
Usuários simul   | 100   | 5,000    | 99.9%  | K8s Horizontal
QPS              | 1,000 | 50,000   | p99<1s | DB sharding + cache
Uptime           | 99%   | 99.99%   | 52min  | Multi-region failover
```

**Red Flag:**
```
❌ "Vai escalar quando precisar"
✅ "Hoje 1k QPS com Postgres, em 12 meses 50k QPS → sharding por tenant_id, read replicas, Redis cache"
```

---

### **4️⃣ FALHAS & RECUPERAÇÃO (Resiliência)**

**Pergunta Núcleo:**
> *"Como o sistema recupera se [componente crítico] falha? Qual é o RTO/RPO?"*

**Sub-Perguntas:**
- Qual é o componente mais crítico (DB, cache, auth)?
- Se falhar, qual é o RTO (Recovery Time Objective)?
- Qual é o RPO (Recovery Point Objective)?
- Tem backup? Com que frequência? Testados?

**Saída Esperada:**
```
Componente   | Crítico? | RTO   | RPO    | Estratégia de Recuperação
─────────────┼──────────┼───────┼────────┼──────────────────────────
DB Postgres  | Sim      | 5min  | 1min   | Replicação síncr, failover automático
Redis Cache  | Não      | 10s   | 0 (ok) | Reconstruir do DB
Auth Service | Sim      | 2min  | 0 (ok) | Fallback para cache, JWT válido
```

**Red Flag:**
```
❌ "Se o DB cai, perdemos tudo"
✅ "DB em Multi-AZ, replicação síncrona, RTO 5min, backups diários + testamos restore mensalmente"
```

---

### **5️⃣ INTEGRAÇÕES (APIs Externas, Fallbacks)**

**Pergunta Núcleo:**
> *"Quais APIs externas são críticas? O que fazer se elas falharem?"*

**Sub-Perguntas:**
- Que APIs externas você depende?
- Qual é o SLA delas? (99%? 99.9%?)
- O que o sistema faz se uma API cai?
- Você tem cache local ou fallback?

**Saída Esperada:**
```
API Externa     | Crítica? | SLA   | Fallback Strategy
────────────────┼──────────┼───────┼──────────────────
Stripe Payment  | Sim      | 99.9% | Queue offline, retry
Geo API         | Não      | 98%   | Use last known location
Email Service   | Não      | 99%   | Queue, retry em 5min
```

**Red Flag:**
```
❌ "Se Stripe cai, transações falham"
✅ "Se Stripe cai, enfileiram em Redis, webhook valida quando volta, cliente vê 'pendente'"
```

---

### **6️⃣ SEGURANÇA (Autenticação, Threat Model)**

**Pergunta Núcleo:**
> *"Qual é o modelo de threat? Como você protege dados sensíveis? Qual é a estratégia de autenticação?"*

**Sub-Perguntas:**
- Quem são os bad actors? (hackers, insiders, bots?)
- Dados são encrypted at rest? In transit?
- Qual é o modelo de autenticação? (OAuth2, SAML, custom?)
- Rate limiting? DDoS protection?
- Audit logs? Quem acessa o quê?

**Saída Esperada:**
```
Concern         | Threat Level | Mitigação
────────────────┼──────────────┼────────────────────────────
Insiders        | Médio        | RBAC + audit logs + data masking
External attack | Alto         | OAuth2 + rate limiting + WAF
Data breach     | Crítico      | AES-256 at rest, TLS in transit
Supply chain    | Médio        | Dependency scanning (Gitleaks)
```

**Red Flag:**
```
❌ "Segurança depois, MVP primeiro"
✅ "MVP com: OAuth2, encrypted passwords (bcrypt), HTTPS only, audit logs de tudo"
```

---

### **7️⃣ CUSTOS & ROI (Budget, Break-Even, TCO)**

**Pergunta Núcleo:**
> *"Qual é o orçamento? Qual é o break-even? Qual é o TCO em 3 anos?"*

**Sub-Perguntas:**
- Budget total para MVP?
- Custo recorrente (infra, licenças)?
- Break-even em quantos meses?
- TCO (Total Cost of Ownership) em 3 anos?

**Saída Esperada:**
```
Item            | Custo MVP | Custo Recorrente (mensal) | Break-Even
────────────────┼───────────┼──────────────────────────┼───────────
Dev (4 devs)    | $0        | $40,000                  | -
Infra (AWS)     | $500      | $5,000                   | -
Licenças        | $0        | $1,000                   | -
─────────────────┼───────────┼──────────────────────────┼───────────
TOTAL           | $500      | $46,000                  | 12 meses (@ $50k ARR)
```

**Red Flag:**
```
❌ "Não sabemos o orçamento ainda"
✅ "MVP budget $50k, recorrente $5k/mês, break-even em 12 meses com 20 clientes @ $250/mês"
```

---

## 📊 Matriz de Resposta (Confidence Scoring)

Após 7 perguntas, preencha:

| Pergunta | Resposta Clara? | Confiança | Status | Ação Necessária |
|---|---|---|---|---|
| 1. Requisitos | Sim / Parcial / Não | X% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |
| 2. Dados & Privacy | Sim / Parcial / Não | Y% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |
| 3. Escalabilidade | Sim / Parcial / Não | Z% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |
| 4. Falhas & Recuperação | Sim / Parcial / Não | A% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |
| 5. Integrações | Sim / Parcial / Não | B% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |
| 6. Segurança | Sim / Parcial / Não | C% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |
| 7. Custos & ROI | Sim / Parcial / Não | D% | ✅ / 🟡 / 🔴 | Continue / Refinement / Bloquear |

**Decisão Final:**
```
Média de Confiança: (X + Y + Z + A + B + C + D) / 7 = M%

Se M ≥ 80%: ✅ PROCEDER para Anatomia
Se 50% ≤ M < 80%: 🟡 REFINEMENT NECESSÁRIO (volte a Escuta Ativa)
Se M < 50%: 🔴 BLOQUEADO (impossível desenhar com tanta incerteza)
```

---

## 🎯 Template de Saída do Grill-Me

```markdown
# GRILL-ME EXECUTADO

## Resumo
[Breve resumo do briefing]

## Respostas às 7 Perguntas

### 1️⃣ Requisitos & Edge-Cases
[Sua resposta] | Confiança: X%

### 2️⃣ Dados & Privacy
[Sua resposta] | Confiança: Y%

### 3️⃣ Escalabilidade
[Sua resposta] | Confiança: Z%

### 4️⃣ Falhas & Recuperação
[Sua resposta] | Confiança: A%

### 5️⃣ Integrações
[Sua resposta] | Confiança: B%

### 6️⃣ Segurança
[Sua resposta] | Confiança: C%

### 7️⃣ Custos & ROI
[Sua resposta] | Confiança: D%

## Matriz de Confiança
[Tabela 7x5 acima]

## Decisão
Confiança Média: M% → [PROCEDER / REFINEMENT / BLOQUEADO]

## Próxima Ação
[Anatomia / Volta a Escuta / Aguarda Stakeholder]
```

---

**Status:** Grill-Me ativado. Nenhuma premissa passa despercebida.
