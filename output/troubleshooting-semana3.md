# 🔧 TROUBLESHOOTING SEMANA 3
## Erros Comuns + Soluções + Fallbacks

**Atualizado:** 2026-10-16  
**Para:** IDE Antigravity + Dev Semana 3

---

## 📋 ÍNDICE

1. **PostgreSQL Connection Errors**
2. **Ollama LLM Cascata Issues**
3. **Docker / Container Problems**
4. **Node.js / npm Issues**
5. **DIFY Frontend Issues**
6. **Maker/Checker Auth Failures**
7. **RAG Embedding Problems**
8. **Performance / Timeout Issues**

---

## 1️⃣ PostgreSQL Connection Errors

### ❌ Error: "ECONNREFUSED 127.0.0.1:5432"

**Causa:** PostgreSQL container não está rodando ou porta está bloqueada

**Solução:**
```bash
# Verificar se container está rodando
docker ps | grep postgres

# Se não estiver, iniciar
docker-compose -f output/02_docker-compose-sugoi-oracle.yml up -d

# Verificar logs
docker logs dai_postgres_vector

# Testar conexão
nc -zv localhost 5432

# Reset: parar e remover
docker stop dai_postgres_vector
docker rm dai_postgres_vector
docker-compose -f output/02_docker-compose-sugoi-oracle.yml up -d
```

---

### ❌ Error: "FATAL: password authentication failed for user "admin""

**Causa:** Senha errada em DATABASE_URL

**Solução:**
```bash
# Verificar .env.production
cat app/backend/.env.production | grep DATABASE_URL

# Esperado:
# DATABASE_URL=postgresql://admin:masterkey123_daisugi_segura@localhost:5432/memoria_vetorial?schema=sugoi

# Se errado, editar:
nano app/backend/.env.production
# Alterar senha para: masterkey123_daisugi_segura

# Restart backend
npm run dev
```

---

### ❌ Error: "relation \"sugoi.processo_bpm\" does not exist"

**Causa:** Schema sugoi_* não foi criado

**Solução:**
```bash
# Rodar schema setup (Semana 2)
psql -h localhost -U admin -d memoria_vetorial \
  -f output/01_SETUP_SCHEMA_SUGOI_ORACLE.sql

# Verificar se tabelas foram criadas
psql -h localhost -U admin -d memoria_vetorial -c "\\dt sugoi_*"

# Se ainda falhando, verificar se user admin tem permissões
psql -h localhost -U admin -d memoria_vetorial -c "GRANT ALL ON SCHEMA sugoi TO admin;"
```

---

## 2️⃣ Ollama LLM Cascata Issues

### ❌ Error: "Cannot connect to Ollama on http://localhost:11434"

**Causa:** Ollama container não está rodando ou porta 11434 está bloqueada

**Solução:**
```bash
# Verificar container
docker ps | grep ollama

# Se não estiver rodando
docker run -d --name sugoi-ollama -p 11434:11434 \
  -v /opt/daisugi/ollama/models:/root/.ollama/models \
  ollama/ollama:latest

# Teste conexão
curl http://localhost:11434/api/tags

# Ver logs
docker logs sugoi-ollama
```

---

### ❌ Error: "Model deepseek-r1:7b not found"

**Causa:** Modelos não foram puxados ainda

**Solução:**
```bash
# Puxar modelos (pode demorar 5-30 min cada)
docker exec sugoi-ollama ollama pull deepseek-r1:7b
docker exec sugoi-ollama ollama pull qwen2.5-coder:7b
docker exec sugoi-ollama ollama pull saullm:7b

# Ou no container (se acessando direto)
ollama pull deepseek-r1:7b

# Verificar quais estão disponíveis
curl http://localhost:11434/api/tags | jq '.models[].name'

# Esperado:
# "deepseek-r1:7b"
# "qwen2.5-coder:7b"
# "saullm:7b"
```

---

### ❌ Error: "Timeout waiting for DeepSeek response (>30s)"

**Causa:** Modelo está lento ou sistema sobrecarregado

**Fallback Automático:**
```javascript
// Em OllamaService, timeout é capturado e fallback automático ocorre:
// DeepSeek (30s) → Qwen (20s) → SaulLM (15s) → ERROR

// Se quer aumentar timeouts manualmente:
// OLLAMA_DEEPSEEK_TIMEOUT=60000  # ms
// OLLAMA_QWEN_TIMEOUT=40000
// OLLAMA_SAULLM_TIMEOUT=30000
```

---

### ❌ Error: "Ollama out of memory / GPU exhausted"

**Causa:** Muitas requisições paralelas ou modelo muito grande

**Mitigação:**
```bash
# Verificar recursos
docker stats sugoi-ollama

# Limitar concorrência (em app/backend/.env)
OLLAMA_MAX_CONCURRENT=2  # máximo 2 requisições ao mesmo tempo

# Reduzir tamanho modelo
# Em vez de deepseek-r1:7b, usar deepseek-r1:1.5b (menor, mais rápido)
```

---

## 3️⃣ Docker / Container Problems

### ❌ Error: "Docker daemon not running"

**Solução:**
```bash
# Iniciar Docker Desktop (se em Mac/Windows)
# Ou em Linux:
sudo systemctl start docker

# Verificar status
docker ps
```

---

### ❌ Error: "Network daisugi-network not found"

**Causa:** Network Docker compartilhada não foi criada

**Solução:**
```bash
# Criar network
docker network create daisugi-network

# Verificar
docker network ls | grep daisugi
```

---

### ❌ Error: "Port 3001 already in use"

**Causa:** Outro processo usando porta 3001

**Solução:**
```bash
# Encontrar processo
lsof -i :3001  # macOS/Linux
netstat -ano | findstr :3001  # Windows

# Matar processo (macOS/Linux)
kill -9 <PID>

# Ou usar porta diferente
PORT=3003 npm run dev
```

---

## 4️⃣ Node.js / npm Issues

### ❌ Error: "node_modules corrupted / missing pg module"

**Solução:**
```bash
cd app/backend

# Limpar cache e reinstalar
rm -rf node_modules package-lock.json
npm install

# Verificar pg module
npm list pg
```

---

### ❌ Error: "Prisma client out of date"

**Solução:**
```bash
cd app/backend
npx prisma generate
```

---

### ❌ Error: "npm ERR! code ERESOLVE"

**Causa:** Conflito de dependências

**Solução:**
```bash
npm install --legacy-peer-deps
```

---

## 5️⃣ DIFY Frontend Issues

### ❌ Error: "DIFY container fails to start"

**Causa:** Docker image não foi built ou porta já em uso

**Solução:**
```bash
# Rebuild image
cd dify
docker build -t dify:semana3 .

# Verificar image
docker images | grep dify

# Se porta 3002 em uso
docker run -p 3003:3000 --network daisugi-network dify:semana3

# Ver logs
docker logs dify-semana3
```

---

### ❌ Error: "DIFY cannot connect to SUGOI-API"

**Causa:** API não está rodando ou URL errada em .env

**Solução:**
```bash
# 1. Verificar se API está rodando
curl http://localhost:3001/health

# 2. Verificar DIFY .env
cat dify/.env | grep SUGOI_API_URL

# 3. Se está rodando em container diferente, pode ser network issue
# Usar host.docker.internal ao invés de localhost:
SUGOI_API_URL=http://host.docker.internal:3001
```

---

## 6️⃣ Maker/Checker Auth Failures

### ❌ Error: "Unauthorized: Maker/Checker role not found"

**Causa:** pessoa_cadeira não foi criada ou user não tem role

**Solução:**
```bash
# Verificar se pessoa_cadeira foi criado em Kigyou shared schema
psql -h localhost -U admin -d memoria_vetorial \
  -c "SELECT * FROM public.pessoa_cadeira WHERE id='<user-id>';"

# Se vazio, criar teste pessoa_cadeira
psql -h localhost -U admin -d memoria_vetorial << EOF
INSERT INTO public.pessoa_cadeira (id, cadeira_id, setor_id, data_inicio)
VALUES ('user-123', 'cadeira-456', 'setor-001', NOW());
EOF
```

---

### ❌ Error: "Hash mismatch: processo foi modificado após criação"

**Causa:** Processo foi alterado antes de aprovação, hash divergiu

**Solução:**
```bash
# Re-validar processo (vai recalcular hash)
POST /api/v1/validacoes/bpm { processo_id }

# Se falhar, pode descartar e recriar processo
DELETE /api/v1/processos-bpm/:id  (se endpoint existir)
```

---

## 7️⃣ RAG Embedding Problems

### ❌ Error: "LlamaIndex connection failed to pgvector"

**Causa:** pgvector extension não foi instalado ou índices não existem

**Solução:**
```bash
# Verificar pgvector
psql -h localhost -U admin -d memoria_vetorial \
  -c "CREATE EXTENSION IF NOT EXISTS vector;"

# Recriar índices
psql -h localhost -U admin -d memoria_vetorial \
  -c "CREATE INDEX IF NOT EXISTS ix_processo_embedding ON sugoi.processo_embedding USING hnsw (embedding vector_cosine_ops);"
```

---

### ❌ Error: "Embedding dimension mismatch (expected 1536, got X)"

**Causa:** Modelo nomic-embed-text retorna dimensão diferente

**Solução:**
```javascript
// Verificar dimensão atual
const embedding = await ollama.embed("test text");
console.log(embedding.length); // deve ser 1536

// Se diferente, ajustar schema:
// ALTER TABLE sugoi.processo_embedding ALTER COLUMN embedding TYPE vector(X);
```

---

### ❌ Error: "RAG search returns empty results"

**Causa:** Nenhum documento embedido ainda

**Solução:**
```bash
# Verificar se existem embeddings
psql -h localhost -U admin -d memoria_vetorial \
  -c "SELECT COUNT(*) FROM sugoi.processo_embedding;"

# Se COUNT = 0, carregar históricos
# (manual durante Quarta Semana 3)
# via: POST /api/v1/rag/load-historicos

# Teste temporário: criar embedding dummy
INSERT INTO sugoi.processo_embedding (processo_id, embedding, created_at)
VALUES ('test-123', '[0.1, 0.2, ..., 0.1]', NOW());
```

---

## 8️⃣ Performance / Timeout Issues

### ❌ Error: "Request timeout after 10s"

**Causa:** Ollama cascata demorando > 10s ou query muito grande

**Mitigação:**
```bash
# Aumentar timeout em .env
API_REQUEST_TIMEOUT=30000  # ms

# Ou limitar concorrência
OLLAMA_MAX_CONCURRENT=1  # sequencial, não paralelo
```

---

### ❌ Error: "Database connection pool exhausted"

**Causa:** Muitas conexões abertas simultaneamente

**Solução:**
```bash
# Verificar conexões ativas
psql -h localhost -U admin -d memoria_vetorial \
  -c "SELECT count(*) FROM pg_stat_activity;"

# Aumentar pool size em .env
DATABASE_POOL_SIZE=20  # default é 10

# Ou limitar requisições paralelas
API_MAX_CONCURRENT_REQUESTS=5
```

---

## 🆘 ESCALATION

| Problema | Contato | SLA |
|---|---|---|
| PostgreSQL / Banco | DBA (Kigyou) | 1h |
| Docker / Infra | DevOps | 2h |
| Node.js / Backend | Dev Lead | 30min |
| DIFY / Frontend | Frontend Team | 2h |
| Ollama / LLM | IA Team | 2h |
| Segurança / Auth | Security | 4h |

---

## 📞 QUICK REFERENCE

**Health checks rápidos:**
```bash
# API
curl http://localhost:3001/health

# DIFY
curl http://localhost:3002/health

# Ollama
curl http://localhost:11434/api/tags

# PostgreSQL
psql -h localhost -U admin -d memoria_vetorial -c "SELECT 1;"

# Verificar todos de uma vez
bash semana3-checklist-pre-monday.sh
```

---

**Última atualização:** 2026-10-16  
**Próximas atualizações:** Conforme erros encontrados em Semana 3
