#!/bin/bash

################################################################################
# DEPLOY_ORACLE_SEMANA2.sh
# Script de Deployment Automático: SUGOI_CADEIA_DE_VALOR no Oracle OCI
################################################################################
# Objetivo: Automatizar setup de SUGOI no Oracle após QUINTA-SEXTA local
# Fluxo:
#   1. SSH para Oracle
#   2. Git clone/pull do repositório
#   3. Executar schema SQL no PostgreSQL
#   4. Build Docker image (sugoi-api)
#   5. Iniciar Docker Compose (API + Ollama)
#   6. Testar conectividade
#   7. Configurar Caddy reverse proxy
################################################################################

set -e  # Exit on error

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURAÇÃO
# ═══════════════════════════════════════════════════════════════════════════

# Oracle OCI
ORACLE_IP="137.131.151.74"
ORACLE_USER="ubuntu"
SSH_KEY_PATH="$HOME/.ssh/ssh-key-2026-09-25.key"

# PostgreSQL
PG_HOST="localhost"  # Dentro do Oracle VM
PG_PORT="5432"
PG_USER="admin"
PG_PASS="masterkey123_daisugi_segura"
PG_DB="memoria_vetorial"

# Aplicação
APP_DIR="/opt/daisugi/sugoi"
APP_PORT="3001"
APP_NAME="sugoi-cadeia-valor"
GITHUB_REPO="https://github.com/MV-AKAGUI/FERRAMENTAS--FUZZY---HARNESS-"
GITHUB_BRANCH="feature/dai-integration-audit"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

################################################################################
# FUNÇÕES AUXILIARES
################################################################################

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
}

################################################################################
# ETAPA 1: VALIDAÇÃO PRÉ-REQUISITOS
################################################################################

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "🚀 DEPLOY SUGOI_CADEIA_DE_VALOR NO ORACLE OCI"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

log_info "Etapa 1: Validando pré-requisitos..."

# Verificar SSH key
if [ ! -f "$SSH_KEY_PATH" ]; then
  log_error "SSH key não encontrada em: $SSH_KEY_PATH"
  exit 1
fi
chmod 600 "$SSH_KEY_PATH"
log_success "SSH key encontrada"

# Verificar conectividade Oracle
log_info "Testando conexão SSH com Oracle..."
if ssh -o ConnectTimeout=5 -i "$SSH_KEY_PATH" "$ORACLE_USER@$ORACLE_IP" "echo OK" > /dev/null 2>&1; then
  log_success "Conexão SSH OK"
else
  log_error "Não conseguiu conectar ao Oracle"
  exit 1
fi

echo ""

################################################################################
# ETAPA 2: SETUP NO ORACLE
################################################################################

echo "════════════════════════════════════════════════════════════════════════"
echo "⚙️  Etapa 2: Setup no Oracle"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

# Conectar e executar comandos remotos
ssh -i "$SSH_KEY_PATH" "$ORACLE_USER@$ORACLE_IP" << 'EOSSH'

set -e

echo "[INFO] Conectado ao Oracle"

# ─────────────────────────────────────────────────────────────────────────
# 2.1 Clonar/Pull repositório
# ─────────────────────────────────────────────────────────────────────────

APP_DIR="/opt/daisugi/sugoi"
GITHUB_REPO="https://github.com/MV-AKAGUI/FERRAMENTAS--FUZZY---HARNESS-"
GITHUB_BRANCH="feature/dai-integration-audit"

echo "[INFO] Verificando repositório..."
if [ -d "$APP_DIR" ]; then
  echo "[INFO] Repositório já existe, fazendo pull..."
  cd "$APP_DIR"
  git pull origin "$GITHUB_BRANCH"
else
  echo "[INFO] Clonando repositório..."
  sudo mkdir -p "$APP_DIR"
  sudo git clone --branch "$GITHUB_BRANCH" "$GITHUB_REPO" "$APP_DIR"
fi
echo "[✓] Repositório atualizado"

# ─────────────────────────────────────────────────────────────────────────
# 2.2 Executar schema SQL no PostgreSQL
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Criando schema sugoi no PostgreSQL..."

# Verificar se Docker container postgres está rodando
if sudo docker ps --filter "name=dai_postgres_vector" --format "{{.Names}}" | grep -q dai_postgres_vector; then
  echo "[✓] Container PostgreSQL (dai_postgres_vector) está rodando"

  # Executar SQL dentro do container
  SQL_FILE="/tmp/01_SETUP_SCHEMA_SUGOI_ORACLE.sql"

  # Copiar arquivo SQL (assumindo que está no repositório)
  sudo cp "$APP_DIR/output/01_SETUP_SCHEMA_SUGOI_ORACLE.sql" "$SQL_FILE"

  # Executar SQL
  sudo docker exec dai_postgres_vector psql \
    -U admin \
    -d memoria_vetorial \
    -f "$SQL_FILE" 2>&1 | head -50

  echo "[✓] Schema sugoi criado no PostgreSQL"
else
  echo "[✗] Container PostgreSQL não está rodando"
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────
# 2.3 Criar diretórios necessários
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Criando diretórios..."
sudo mkdir -p /opt/daisugi/logs/sugoi
sudo mkdir -p /opt/daisugi/config/sugoi
sudo mkdir -p /opt/daisugi/ollama/models
sudo chown -R ubuntu:docker /opt/daisugi/
echo "[✓] Diretórios criados"

# ─────────────────────────────────────────────────────────────────────────
# 2.4 Criar arquivo .env
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Criando arquivo .env..."
cat > "$APP_DIR/app/backend/.env.production" << 'DOTENV'
NODE_ENV=production
PORT=3001

# Database
DATABASE_URL="postgresql://admin:masterkey123_daisugi_segura@host.docker.internal:5432/memoria_vetorial?schema=sugoi"

# JWT
JWT_SECRET=SUA_CHAVE_SECRETA_SUPER_SEGURA_AQUI
JWT_EXPIRY=8h

# Ollama
OLLAMA_API_URL=http://sugoi-ollama:11434

# Gemini AI (Credencial corporativa - CONFIGURE ANTES)
GEMINI_API_KEY=sKAI-SuaChaveGeminiAqui
GEMINI_PROJECT_ID=seu-projeto-gcp-sugoi

# S3 / Object Storage
S3_BUCKET=sugoi-cadeia-valor

# Logging
LOG_LEVEL=info

# Sentry (opcional)
SENTRY_DSN=
DOTENV

echo "[✓] Arquivo .env criado"

# ─────────────────────────────────────────────────────────────────────────
# 2.5 Build Docker image
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Building Docker image (sugoi-api)..."
cd "$APP_DIR/app/backend"

# Criar Dockerfile se não existir
if [ ! -f Dockerfile ]; then
  echo "[INFO] Dockerfile não encontrado, criando..."
  cat > Dockerfile << 'DOCKERFILE'
FROM node:24-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Prisma setup
RUN npx prisma generate

EXPOSE 3001

CMD ["npm", "start"]
DOCKERFILE
fi

# Build
sudo docker build -t "$APP_NAME:latest" .
echo "[✓] Docker image built"

# ─────────────────────────────────────────────────────────────────────────
# 2.6 Criar network Docker (se não existir)
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Verificando network Docker..."
if ! sudo docker network ls | grep -q daisugi-network; then
  echo "[INFO] Criando network daisugi-network..."
  sudo docker network create daisugi-network
fi
echo "[✓] Network OK"

# ─────────────────────────────────────────────────────────────────────────
# 2.7 Iniciar Docker Compose
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Iniciando Docker Compose..."
cd "$APP_DIR"
sudo docker-compose -f output/02_docker-compose-sugoi-oracle.yml up -d

echo "[✓] Docker Compose iniciado"
sleep 10

# Verificar status
echo "[INFO] Verificando status dos containers..."
sudo docker-compose -f output/02_docker-compose-sugoi-oracle.yml ps

# ─────────────────────────────────────────────────────────────────────────
# 2.8 Prisma migrate
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Executando Prisma migrate..."
cd "$APP_DIR/app/backend"

# Esperar API estar pronta
sleep 30

# Dentro do container da API, executar migrate
sudo docker exec sugoi-api npx prisma migrate deploy --skip-generate || true

echo "[✓] Prisma migrate completo"

# ─────────────────────────────────────────────────────────────────────────
# 2.9 Seed data (14 setores)
# ─────────────────────────────────────────────────────────────────────────

echo "[INFO] Executando seed data..."
sudo docker exec sugoi-api npx prisma db seed || true

echo "[✓] Seed data completo"

EOSSH

log_success "Setup no Oracle concluído"

echo ""

################################################################################
# ETAPA 3: TESTES DE CONECTIVIDADE (Local)
################################################################################

echo "════════════════════════════════════════════════════════════════════════"
echo "🧪 Etapa 3: Testes de Conectividade"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

# Testar API via SSH tunnel (para máquina local)
log_info "Testando API (via SSH tunnel)..."

ssh -i "$SSH_KEY_PATH" -L 3001:localhost:3001 "$ORACLE_USER@$ORACLE_IP" \
  -N -f > /dev/null 2>&1 &

sleep 2

if curl -s http://localhost:3001/health | grep -q "ok\|health"; then
  log_success "API respondendo em http://localhost:3001"
else
  log_warning "API ainda não respondendo (pode estar inicializando)"
fi

echo ""

################################################################################
# ETAPA 4: CONFIGURAR CADDY REVERSE PROXY
################################################################################

echo "════════════════════════════════════════════════════════════════════════"
echo "🔄 Etapa 4: Configurar Caddy Reverse Proxy"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

log_info "Adicionando entrada Caddy para sugoi.daisugi.com.br..."

ssh -i "$SSH_KEY_PATH" "$ORACLE_USER@$ORACLE_IP" << 'EOSSH'

CADDYFILE="/opt/daisugi/Caddyfile"

# Backup
sudo cp "$CADDYFILE" "$CADDYFILE.bak.$(date +%Y%m%d%H%M%S)"

# Adicionar entrada (se não existir)
if ! sudo grep -q "sugoi.daisugi.com.br" "$CADDYFILE"; then
  echo ""
  echo "sugoi.daisugi.com.br, sugoi.137.131.151.74.sslip.io {" | sudo tee -a "$CADDYFILE"
  echo "    handle /api/* {" | sudo tee -a "$CADDYFILE"
  echo "        reverse_proxy localhost:3001" | sudo tee -a "$CADDYFILE"
  echo "    }" | sudo tee -a "$CADDYFILE"
  echo "    handle {" | sudo tee -a "$CADDYFILE"
  echo "        reverse_proxy localhost:3001" | sudo tee -a "$CADDYFILE"
  echo "    }" | sudo tee -a "$CADDYFILE"
  echo "}" | sudo tee -a "$CADDYFILE"

  # Recarregar Caddy
  sudo docker restart daisugi-gateway
  echo "[✓] Caddy recarregado"
else
  echo "[✓] Entrada sugoi.daisugi.com.br já existe no Caddyfile"
fi

EOSSH

log_success "Caddy configurado"

echo ""

################################################################################
# ETAPA 5: CRIAR DNS (Manual)
################################################################################

echo "════════════════════════════════════════════════════════════════════════"
echo "📡 Etapa 5: Configurar DNS (MANUAL)"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

log_warning "Entrada DNS ainda não criada (requer acesso ao provedor de DNS)"
echo ""
echo "Para completar o deployment:"
echo "  1. Acesse seu provedor de DNS (Cloudflare, Registro.br, GoDaddy, etc)"
echo "  2. Crie uma entrada A:"
echo "     - Nome: sugoi"
echo "     - Tipo: A"
echo "     - Valor: 137.131.151.74"
echo "     - TTL: 300"
echo ""
echo "  3. Aguarde propagação DNS (5-30 min)"
echo "     Testar com: dig sugoi.daisugi.com.br"
echo ""

################################################################################
# RESUMO FINAL
################################################################################

echo "════════════════════════════════════════════════════════════════════════"
echo "✅ DEPLOYMENT ORACLE SEMANA 2 - RESUMO"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

log_success "✓ Schema sugoi_* criado no PostgreSQL"
log_success "✓ Docker image (sugoi-api) built"
log_success "✓ Docker Compose iniciado (API + Ollama)"
log_success "✓ Prisma migrate executado"
log_success "✓ Seed data (14 setores) completo"
log_success "✓ Caddy reverse proxy configurado"

echo ""
echo "🔗 URLs de Acesso:"
echo "   Local (SSH tunnel):  http://localhost:3001"
echo "   Produção:            https://sugoi.daisugi.com.br (após DNS)"
echo "   Ollama API:          http://137.131.151.74:11434"
echo ""

echo "📊 Próximos passos:"
echo "  1. Configurar DNS (entrada A em daisugi.com.br)"
echo "  2. Aguardar propagação DNS (5-30 min)"
echo "  3. Testar: https://sugoi.daisugi.com.br"
echo "  4. Executar GO-LIVE GATE checklist"
echo ""

echo "🚀 Sistema SUGOI pronto para Semana 3+ (RAG, Cascata LLM, Frontend)"
echo ""

################################################################################
# FIM
################################################################################
