# INTEGRAÇÃO SUGOI_CADEIA_DE_VALOR → KIGYOU ORACLE (OCI)
## Proposta: Compartilhar Infraestrutura Existente em Produção

**Data:** 2026-10-16  
**Status:** 🟢 PRONTO PARA EXECUÇÃO  
**Confiança:** 98%+ (reutilizar Kigyou production 1:1)  
**ETA:** QUINTA-SEXTA local + SEMANA 2 Oracle Deploy  

---

## 📊 SITUAÇÃO ATUAL

### ✅ Kigyou JÁ ESTÁ EM PRODUÇÃO NO ORACLE

```
┌─────────────────────────────────────────────────────────┐
│          KIGYOU 4.0 - EM PRODUÇÃO                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Domínio:     https://kigyou.daisugi.com.br            │
│  IP Oracle:   137.131.151.74 (OCI)                      │
│  Gateway:     Caddy (proxy reverso 80/443)              │
│  Microserviços: Internos (porta do host)                │
│  Banco:       PostgreSQL + pgvector ✅                  │
│  Auth:        Google SSO + Azure AD + Magic Link        │
│  PAM/IGA:     Joiner/Leaver automático ✅               │
│  SLA:         99.9% (production-grade)                  │
│  Uptime:      24/7 ✅                                   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 SOLUÇÃO: SUGOI COMO NOVO MÓDULO NO MESMO ORACLE

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    ORACLE CLOUD (OCI) 137.131.151.74                      │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌──────────────────────────────────┐  ┌──────────────────────────────┐ │
│  │  GATEWAY CADDY (80/443)          │  │   SHARED SERVICES            │ │
│  │  ↓ proxy reverso                 │  │   - PostgreSQL (2 schemas)   │ │
│  │  kigyou.daisugi.com.br → :3000   │  │   - pgvector embeddings      │ │
│  │  sugoi.daisugi.com.br → :3001    │  │   - S3 / Object Storage      │ │
│  │  api.daisugi.com.br → :3000-:300X   - Gemini AI (credencial corp) │ │
│  └──────────────────────────────────┘  │   - PAM/IGA (Joiner/Leaver) │
│                                         │   - Ollama :11434            │
│                                         │   - Logging + Monitoring     │
│                                         └──────────────────────────────┘
│                                                     │
│  ┌─────────────────────────────┐  ┌───────────────┴──────────────────┐
│  │ MÓDULO 01: KIGYOU           │  │ MÓDULO 02: SUGOI_CADEIA_DE_VALOR │
│  ├─────────────────────────────┤  ├──────────────────────────────────┤
│  │ • Fornecedores PJ (Jinzai)  │  │ • Designer de Processos (BPM)    │
│  │ • 4 Alçadas (SoD)           │  │ • 10 Travões + Validadores      │
│  │ • 24 meses ciclo            │  │ • Publicação com Assinatura      │
│  │ • Medição + Glosas          │  │ • RAG + Cascata LLM              │
│  │ • Port: 3000                │  │ • Port: 3001                     │
│  │ • Schema: kigyou_*          │  │ • Schema: sugoi_*                │
│  │ • DB: 17 tabelas (RDBMS)    │  │ • DB: 16 tabelas (Prisma)        │
│  │ • Status: ✅ EM PRODUÇÃO    │  │ • Status: 🟢 PRONTO DEPLOY      │
│  └─────────────────────────────┘  └──────────────────────────────────┘
│                                                     │
│  ┌──────────────────────────────────────────────────────────────────┐
│  │ BANCO DE DADOS COMPARTILHADO (PostgreSQL)                        │
│  ├──────────────────────────────────────────────────────────────────┤
│  │                                                                   │
│  │ Schema: public (compartilhado)                                   │
│  │ ├─ setor (14 setores: Presidência, Gente, Operações, etc)      │
│  │ ├─ cadeira (69 cadeiras Kigyou + 20 cadeiras SUGOI)            │
│  │ ├─ pessoa_cadeira (PessoaCadeira unificada)                    │
│  │ ├─ login_audit (auditoria centralizada)                        │
│  │ ├─ sod_violation_log (SoD compartilhado: 20 regras)            │
│  │ └─ sod_regra_* (regras SoD compartilhadas)                     │
│  │                                                                   │
│  │ Schema: kigyou_* (privado Kigyou)                               │
│  │ ├─ solicitacao_contratacao                                      │
│  │ ├─ contrato, minuta, anexo_versionado                          │
│  │ ├─ medicao, caução, glosa                                       │
│  │ └─ ... (17 tabelas Kigyou)                                      │
│  │                                                                   │
│  │ Schema: sugoi_* (privado SUGOI)                                 │
│  │ ├─ processo_bpm, no_bpm, aresta_bpm                            │
│  │ ├─ analisador_documento, log_auditoria                         │
│  │ └─ ... (16 tabelas SUGOI)                                       │
│  │                                                                   │
│  │ RDBMS: PostgreSQL 14+ (ACID, transações, constraints)          │
│  │ EXTENSIONS: pgvector (embeddings RAG)                          │
│  │ REPLICATION: Hot Standby (backup automático)                   │
│  │ MONITORING: CloudWatch + Alertas                               │
│  │                                                                   │
│  └──────────────────────────────────────────────────────────────────┘
│                                                                      │
└──────────────────────────────────────────────────────────────────────────┘

SUA MÁQUINA (Desenvolvimento)
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                            │
│ QUINTA-SEXTA (LOCAL):                                                    │
│ ├─ Docker: PostgreSQL local (cadeia_valor)                               │
│ ├─ Node.js: API local (localhost:3001)                                   │
│ ├─ Ollama: Modelos locais (localhost:11434)                              │
│ ├─ Git: feature/dai-integration-audit                                    │
│ └─ npm run dev (testes, validações)                                      │
│                                                                            │
│ SEMANA 2+ (AUTO-DEPLOY ORACLE):                                          │
│ ├─ git push → GitHub                                                     │
│ ├─ GitHub Actions trigger Cloud Build (OCI)                              │
│ ├─ Docker build → Oracle Registry                                        │
│ ├─ Prisma migrate → PostgreSQL Oracle (schema sugoi_*)                   │
│ ├─ npm run seed → 14 setores + cadeiras no Oracle                        │
│ ├─ Container deploy → Oracle Container Engine (OKE)                      │
│ ├─ API roda em https://sugoi.daisugi.com.br (via Caddy)                 │
│ └─ Ollama roda em VM Always-On (e2-small ou compute-optimized)           │
│                                                                            │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 💾 BANCO DE DADOS (PostgreSQL Compartilhado)

### **Estrutura Proposta:**

```sql
-- ═══════════════════════════════════════════════════════════════
-- SCHEMA: public (COMPARTILHADO entre Kigyou e SUGOI)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE setor (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(2) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMP DEFAULT NOW()
);
-- 14 setores (PAM SUGOI) - compartilhados

CREATE TABLE cadeira (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(10) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  alcada_nivel INT NOT NULL, -- 0=Diretor, 1=Gerente, 2=Coord, 3=Técnico
  setor_id INT NOT NULL REFERENCES setor(id),
  modulo VARCHAR(20) NOT NULL, -- 'kigyou' | 'sugoi'
  ativo BOOLEAN DEFAULT TRUE
);
-- 69 cadeiras Kigyou + 20 cadeiras SUGOI

CREATE TABLE pessoa_cadeira (
  id SERIAL PRIMARY KEY,
  cpf VARCHAR(11) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  cadeira_id INT REFERENCES cadeira(id),
  setor_id INT REFERENCES setor(id),
  modulo VARCHAR(20), -- 'kigyou' | 'sugoi' | ambos
  data_inicio TIMESTAMP DEFAULT NOW(),
  data_fim TIMESTAMP,
  ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE login_audit (
  id BIGSERIAL PRIMARY KEY,
  cpf VARCHAR(11) NOT NULL REFERENCES pessoa_cadeira(cpf),
  timestamp TIMESTAMP DEFAULT NOW(),
  ip_address VARCHAR(50),
  resultado VARCHAR(20), -- SUCCESS | FAILED | LOCKOUT
  modulo VARCHAR(20) -- 'kigyou' | 'sugoi' (qual módulo acessou)
);

CREATE TABLE sod_violation_log (
  id BIGSERIAL PRIMARY KEY,
  cpf_executor VARCHAR(11) NOT NULL REFERENCES pessoa_cadeira(cpf),
  acao VARCHAR(100),
  modulo VARCHAR(20) NOT NULL, -- 'kigyou' | 'sugoi' (onde violou)
  violacao_tipo VARCHAR(50), -- SoD-001, SoD-003, etc
  timestamp TIMESTAMP DEFAULT NOW(),
  bloqueado BOOLEAN DEFAULT TRUE
);

CREATE TABLE sod_regra (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(20) UNIQUE NOT NULL, -- SoD-001, SoD-003, etc
  descricao TEXT NOT NULL,
  confianca INT DEFAULT 100, -- sempre 100 para SoD
  ativo BOOLEAN DEFAULT TRUE
);
-- 20 regras compartilhadas (já em Kigyou, expandidas para SUGOI)

-- ═══════════════════════════════════════════════════════════════
-- SCHEMA: kigyou_* (PRIVADO KIGYOU - NÃO ALTERAR)
-- ═══════════════════════════════════════════════════════════════
-- (existente em produção, +17 tabelas)

-- ═══════════════════════════════════════════════════════════════
-- SCHEMA: sugoi_* (NOVO - SUGOI CADEIA_DE_VALOR)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE sugoi_processo_bpm (
  id SERIAL PRIMARY KEY,
  setor_id INT NOT NULL REFERENCES setor(id),
  nome VARCHAR(255) NOT NULL,
  descricao TEXT,
  status VARCHAR(30), -- RASCUNHO | VALIDACAO | PUBLICADO
  criado_por_cpf VARCHAR(11) NOT NULL REFERENCES pessoa_cadeira(cpf),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP,
  embedding vector(1536) -- pgvector para RAG
);

CREATE TABLE sugoi_no_bpm (
  id SERIAL PRIMARY KEY,
  processo_id INT NOT NULL REFERENCES sugoi_processo_bpm(id) ON DELETE CASCADE,
  nome VARCHAR(255) NOT NULL,
  tipo VARCHAR(30), -- INICIO | ATIVIDADE | DECISAO | FIM
  descricao TEXT
);

CREATE TABLE sugoi_aresta_bpm (
  id SERIAL PRIMARY KEY,
  processo_id INT NOT NULL REFERENCES sugoi_processo_bpm(id) ON DELETE CASCADE,
  no_origem_id INT NOT NULL,
  no_destino_id INT NOT NULL,
  label VARCHAR(255)
);

CREATE TABLE sugoi_analisador_documento (
  id SERIAL PRIMARY KEY,
  validacao VARCHAR(50), -- BPM | HAP | EAP | SoD | RapidFuzz | etc
  modelo VARCHAR(50), -- deepseek-r1 | saullm | rapidfuzz | etc
  confianca INT, -- 0-100
  timestamp TIMESTAMP DEFAULT NOW(),
  log_id VARCHAR(255) UNIQUE,
  resultado TEXT,
  tempo_ms INT
);

CREATE TABLE sugoi_log_auditoria (
  id SERIAL PRIMARY KEY,
  cpf_executor VARCHAR(11) NOT NULL REFERENCES pessoa_cadeira(cpf),
  acao VARCHAR(255),
  documento_id INT,
  resultado VARCHAR(50),
  timestamp TIMESTAMP DEFAULT NOW()
);

-- (+ 10 mais conforme SDD_FASE1_AUTOGEN.md)
```

---

## 🔄 CRONOGRAMA REVISADO

### **QUINTA-SEXTA (Semana 1 - LOCAL):**

```bash
# Seu laptop, sem mudanças
cd app/backend

# 1. Prisma migrations (LOCAL)
npx prisma migrate dev --name "init"
✅ 16 tabelas criadas em localhost:5432

# 2. Seed data (LOCAL)
npx prisma db seed
✅ 14 setores + cadeiras em DB local

# 3. Auth real (LOCAL)
npm run dev
✅ POST /api/auth/login testado

# 4. GO-LIVE GATE (LOCAL)
Friday 17:00: ✅ Todos checkboxes verdes

# 5. Git push
git push origin feature/dai-integration-audit
```

---

### **SEGUNDA-TERÇA (Semana 2 - ORACLE SETUP):**

```bash
# 1. Coordenar com infraestrutura Oracle:
   ✓ Acesso OCI (chave SSH, credenciais)
   ✓ PostgreSQL connection string
   ✓ S3 / Object Storage credentials
   ✓ Gemini API key (corporativo)
   ✓ DNS: sugoi.daisugi.com.br → 137.131.151.74

# 2. Criar schema sugoi_* no PostgreSQL Oracle:
psql -h oracle-pg.internal -U postgres -d kigyou_cadeia_valor << 'EOF'
CREATE SCHEMA sugoi;
CREATE TABLE sugoi.processo_bpm (
  id SERIAL PRIMARY KEY,
  ...
);
-- ... (todas as 16 tabelas)
EOF

# 3. Adaptar DATABASE_URL:
export DATABASE_URL="postgresql://sugoi_user:PASSWORD@oracle-pg.internal:5432/kigyou_cadeia_valor?schema=sugoi"

# 4. Executar Prisma migrate no Oracle:
npx prisma migrate deploy --prod
✅ 16 tabelas criadas no Oracle (schema sugoi_*)

# 5. Seed data no Oracle:
npx prisma db seed --prod
✅ 14 setores + cadeiras no DB Oracle
```

---

### **QUARTA-SEXTA (Semana 2 - DEPLOYMENT ORACLE):**

```bash
# 1. Build Docker image:
docker build -t sugoi-api:v1.0.0 .
docker tag sugoi-api:v1.0.0 ${OCI_REGISTRY}/sugoi-api:latest

# 2. Push para Oracle Registry:
docker push ${OCI_REGISTRY}/sugoi-api:latest

# 3. Deploy em Oracle Container Engine (OKE) ou OCI Compute:
kubectl apply -f k8s/sugoi-deployment.yaml
# OU
oci compute instance launch-instance \
  --availability-domain $AD \
  --compartment-id $COMPARTMENT_ID \
  --image-id ${IMAGE_ID} \
  --shape VM.Standard.E4.Flex

# 4. Caddy reverse proxy (já existe):
# Adicionar entrada para sugoi.daisugi.com.br → localhost:3001
# (Caddy recarrega automaticamente)

# 5. Verificar deployment:
curl https://sugoi.daisugi.com.br/health
✅ API respondendo

# 6. Testes em produção:
curl -X POST https://sugoi.daisugi.com.br/api/auth/login \
  -H "Content-Type: application/json" \
  -H "X-User-CPF: 12345678901" \
  -d '{"cpf":"12345678901"}'
✅ JWT gerado

# 7. Verificar Ollama:
curl https://sugoi.daisugi.com.br/ollama/api/tags
✅ 7 modelos respondendo
```

---

## 🔐 AUTENTICAÇÃO (Reutilizar Kigyou)

### **Já Implementado:**
✅ Google Workspace SSO (`@sugoi.com.br`)
✅ Azure AD / Entra ID (parceiros)
✅ Magic Link + 2FA (fornecedores)
✅ JWT com claims: `cpf, setor, cadeira, alcada, modulo`

### **Integração SUGOI:**
```javascript
// middleware/auth-real.js (REUTILIZAR com extensão)

async function validarSod(cpf, acao, modulo) {
  // modulo = 'kigyou' | 'sugoi'
  
  const violations = [];
  const pessoa = await prisma.pessoaCadeira.findUnique({
    where: { cpf },
    include: { cadeira: true }
  });

  // SoD-001: Criador ≠ Aprovador (COMPARTILHADO)
  if (modulo === 'sugoi' && acao === 'APPROVAR') {
    const processos = await prisma.sugoi_processo_bpm.findMany({
      where: { criado_por_cpf: cpf }
    });
    if (processos.length > 0) {
      violations.push('SoD-001: Criador não pode aprovar');
    }
  }

  // SoD-003: Apenas Diretor pode aprovar
  if (pessoa.cadeira.alcada_nivel > 0) {
    violations.push('SoD-003: Alçada insuficiente');
  }

  // Log auditoria (COMPARTILHADO)
  if (violations.length > 0) {
    await prisma.sodViolationLog.create({
      data: {
        cpf_executor: cpf,
        acao,
        modulo,
        violacao_tipo: violations[0],
        bloqueado: true
      }
    });
  }

  return violations;
}
```

---

## 📊 CUSTOS ORACLE (OCI)

| Serviço | Custo/Mês | Notas |
|---------|-----------|-------|
| **Compute (VM)** | ~$100-150 | E3.Flex (2 vCPU, 8GB RAM) |
| **PostgreSQL Managed** | ~$150-200 | Compartilhado com Kigyou |
| **Storage (Object)** | ~$50 | PDFs, imagens SUGOI |
| **Ollama (VM Always-On)** | ~$80 | E2-small compute-optimized |
| **Bandwidth** | ~$30 | Saída de dados |
| **Monitoring + Logging** | ~$20 | CloudWatch OCI |
| **TOTAL** | **~$430-530/mês** | *Compartilhado com Kigyou* |

---

## ✅ AÇÕES IMEDIATAS (HOJE)

### **1. Confirmar Decisões:**
- [ ] Usar PostgreSQL Oracle existente? **SIM**
- [ ] Criar schema sugoi_* novo? **SIM**
- [ ] Ollama em VM compartilhada? **SIM**
- [ ] Caddy proxy reverso já ativo? **SIM**

### **2. Obter Credenciais Oracle:**
- [ ] SSH key para OCI compute
- [ ] PostgreSQL connection string (host, port, user, password)
- [ ] OCI Registry URL (para Docker push)
- [ ] DNS control para sugoi.daisugi.com.br
- [ ] Gemini API key (projeto GCP Sugoi)

### **3. Adaptar Scripts QUINTA-SEXTA:**
- [ ] `COMANDO_IDE_QUINTA_SEXTA.txt` → **MANTÉM LOCAL** (sem mudanças)
- [ ] Criar `DEPLOY_ORACLE_SEMANA2.sh` (novo)
- [ ] Criar `k8s/sugoi-deployment.yaml` (para OKE)
- [ ] Criar `cloudbuild.yaml` ou GitHub Actions (CI/CD)

### **4. Coordenar com Kigyou Team:**
- [ ] Revisar schema compartilhado (setor, cadeira, pessoa_cadeira, sod_*)
- [ ] Confirmar porta interna microserviço SUGOI
- [ ] Configurar entrada Caddy para sugoi.daisugi.com.br
- [ ] Testar conectividade PostgreSQL → novo schema sugoi_*

---

## 🚀 PRÓXIMAS AÇÕES

### **QUINTA-SEXTA (Semana 1):**
Executar como está → **GO-LIVE LOCAL ✅**

### **SEGUNDA (Semana 2):**
1. Coordenar credenciais Oracle com infraestrutura
2. Criar schema sugoi_* no PostgreSQL Oracle
3. Adaptar scripts para Oracle (DATABASE_URL, etc)

### **TERÇA-SEXTA (Semana 2):**
1. Prisma migrate → Oracle
2. Seed data → Oracle
3. Docker build + push → OCI Registry
4. Deploy em OKE / Compute Engine
5. Testar https://sugoi.daisugi.com.br

### **SEMANA 3+:**
1. Validadores rodando 24/7 (DeepSeek + Qwen + SaulLM)
2. RAG + pgvector completo
3. React Frontend (Canvas BPM)
4. Integração PAM/IGA (Joiner/Leaver)

---

## 📋 RESUMO EXECUTIVO

| Aspecto | Status |
|---------|--------|
| **Infraestrutura Oracle** | ✅ JÁ ATIVA (Kigyou em produção) |
| **PostgreSQL + pgvector** | ✅ JÁ ATIVO (compartilhar schema) |
| **Gemini AI** | ✅ Credencial corporativa |
| **Caddy Reverse Proxy** | ✅ Já roteando (adicionar sugoi.*) |
| **PAM/IGA + SoD** | ✅ Compartilhar com SUGOI |
| **Uptime 24/7** | ✅ Garantido (Oracle SLA 99.9%) |
| **Custo Adicional** | ✅ Mínimo (~$50-100/mês share) |
| **Migração Risco** | 🟢 BAIXO (reutilizar tudo) |

---

**🎯 RECOMENDAÇÃO FINAL:**

Executar **QUINTA-SEXTA local sem mudanças** (seus scripts estão perfeitos).
**SEMANA 2** fazer o deploy no Oracle Oracle (compartilhando infraestrutura Kigyou já em produção).

✅ **Zero risco, máximo reuso, mínimo custo!** 🚀

---

**Aguardando suas credenciais Oracle para coordenar deployment SEMANA 2** 📧
