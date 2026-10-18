#!/bin/bash

################################################################################
# auto-setup-semana3.sh
# Execução automática: SEGUNDA 08:00 (IDE Antigravity)
# Prepara backend + frontend para desenvolvimento Semana 3
################################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Config
REPO_DIR="/opt/daisugi/sugoi"
BRANCH="feature/dai-integration-audit"
BACKEND_DIR="$REPO_DIR/app/backend"
DIFY_DIR="$REPO_DIR/dify"

echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🚀 AUTO-SETUP SEMANA 3${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 1: Git Setup
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}[1/6] Git Repository...${NC}"
cd "$REPO_DIR"

if ! git branch | grep -q "$BRANCH"; then
  echo -e "${RED}❌ Branch $BRANCH não encontrado${NC}"
  git fetch origin "$BRANCH"
fi

git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
git pull origin "$BRANCH"

echo -e "${GREEN}✅ Git pronto (branch: $BRANCH)${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 2: Node.js + npm
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}[2/6] Node.js + npm...${NC}"

NODE_VERSION=$(node -v | cut -d'v' -f2)
NPM_VERSION=$(npm -v)

if [[ ! "$NODE_VERSION" =~ ^24 ]]; then
  echo -e "${RED}⚠️  Node.js 24.x esperado, encontrado: $NODE_VERSION${NC}"
fi

echo -e "${GREEN}✅ Node $NODE_VERSION, npm $NPM_VERSION${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 3: Backend (npm install + Prisma)
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}[3/6] Backend Setup...${NC}"
cd "$BACKEND_DIR"

# npm install
echo "  ├─ npm install..."
npm install --silent 2>/dev/null || npm install

# Prisma generate
echo "  ├─ Prisma generate..."
npx prisma generate --silent

# Create .env.production if not exists
if [ ! -f ".env.production" ]; then
  echo "  ├─ Criando .env.production..."
  cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3001
LOG_LEVEL=info

DATABASE_URL=postgresql://admin:masterkey123_daisugi_segura@localhost:5432/memoria_vetorial?schema=sugoi

JWT_SECRET=dev-secret-change-in-prod-ORACLE
JWT_EXPIRY=8h

OLLAMA_API_URL=http://localhost:11434
OLLAMA_MODELS=["deepseek-r1:7b", "qwen2.5-coder:7b", "saullm:7b"]

GEMINI_API_KEY=your-gemini-key-here
GEMINI_PROJECT_ID=your-gcp-project-id

S3_ENDPOINT=https://storage.googleapis.com
S3_BUCKET=sugoi-cadeia-valor

GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

AZURE_AD_TENANT_ID=your-azure-tenant-id
AZURE_AD_CLIENT_ID=your-azure-client-id
AZURE_AD_CLIENT_SECRET=your-azure-client-secret

LOG_LEVEL=info
SENTRY_DSN=
EOF
fi

echo -e "${GREEN}✅ Backend pronto${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 4: PostgreSQL Connection Test
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}[4/6] PostgreSQL Connection...${NC}"

if node -e "
const { Client } = require('pg');
const client = new Client({
  user: 'admin',
  password: 'masterkey123_daisugi_segura',
  host: 'localhost',
  port: 5432,
  database: 'memoria_vetorial'
});
client.connect().then(() => {
  console.log('OK');
  client.end();
}).catch(e => {
  console.error('FAIL');
  process.exit(1);
});
" > /tmp/pg_test.log 2>&1; then
  echo -e "${GREEN}✅ PostgreSQL conectado${NC}"
else
  echo -e "${RED}❌ PostgreSQL falhou (verifique container dai_postgres_vector)${NC}"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 5: Ollama Validation
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}[5/6] Ollama Models...${NC}"

MODELS_COUNT=$(curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name"' | wc -l)

if [ "$MODELS_COUNT" -ge 5 ]; then
  echo -e "${GREEN}✅ Ollama OK ($MODELS_COUNT modelos)${NC}"
else
  echo -e "${YELLOW}⚠️  Ollama pode estar iniciando (encontrados: $MODELS_COUNT modelos)${NC}"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 6: DIFY Docker Build
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}[6/6] DIFY Frontend...${NC}"

if [ -d "$DIFY_DIR" ]; then
  echo "  ├─ Docker build DIFY..."
  cd "$DIFY_DIR"
  docker build -t dify:semana3 . > /tmp/dify_build.log 2>&1 &
  DIFY_BUILD_PID=$!
  echo "  └─ Build iniciado (em background, PID: $DIFY_BUILD_PID)"
  echo -e "${GREEN}✅ DIFY build queued${NC}"
else
  echo -e "${RED}❌ DIFY não encontrado em $DIFY_DIR${NC}"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ AUTO-SETUP COMPLETO${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}PRONTO PARA DESENVOLVIMENTO SEMANA 3${NC}"
echo ""
echo "Próximos passos (em dois terminais paralelos):"
echo ""
echo -e "${YELLOW}Terminal 1 (Backend):${NC}"
echo "  cd $BACKEND_DIR"
echo "  npm run dev"
echo "  → Esperado: Server listening on http://localhost:3001"
echo ""
echo -e "${YELLOW}Terminal 2 (Frontend):${NC}"
echo "  docker run -p 3002:3000 --network daisugi-network dify:semana3"
echo "  → Esperado: DIFY UI em http://localhost:3002"
echo ""
echo -e "${GREEN}Validação:${NC}"
echo "  curl http://localhost:3001/health  (API)"
echo "  curl http://localhost:3002/health  (DIFY)"
echo ""
echo -e "${YELLOW}Logs:${NC}"
echo "  DIFY build: tail -f /tmp/dify_build.log"
echo "  PostgreSQL: docker logs dai_postgres_vector"
echo "  Ollama: docker logs sugoi-ollama"
echo ""
echo -e "${GREEN}🚀 GO-LIVE GATE SEMANA 3 ATIVADO${NC}"
echo ""
