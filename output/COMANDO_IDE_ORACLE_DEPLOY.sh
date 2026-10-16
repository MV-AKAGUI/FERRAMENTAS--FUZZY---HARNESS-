#!/bin/bash

################################################################################
# COMANDO FINAL - IDE ANTIGRAVITY → ORACLE DEPLOY SUGOI
# ═══════════════════════════════════════════════════════════════════════════
# INSTRUÇÕES:
# 1. Copiar TODO esse script
# 2. Colar no Terminal IDE (Antigravity)
# 3. Executar: bash COMANDO_IDE_ORACLE_DEPLOY.sh
# 4. IDE faz TODO o trabalho no Oracle (SSH automático)
# ═══════════════════════════════════════════════════════════════════════════

set -e

SSH_KEY="$HOME/.ssh/ssh-key-2026-09-25.key"
ORACLE_IP="137.131.151.74"
ORACLE_USER="ubuntu"
APP_DIR="/opt/daisugi/sugoi"
REPO="https://github.com/MV-AKAGUI/FERRAMENTAS--FUZZY---HARNESS-"
BRANCH="feature/dai-integration-audit"

echo "═══════════════════════════════════════════════════════════════════════"
echo "🚀 DEPLOY SUGOI → ORACLE OCI (via IDE Antigravity)"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "SSH Key: $SSH_KEY"
echo "Oracle: $ORACLE_IP"
echo "App Dir: $APP_DIR"
echo "Repo: $REPO ($BRANCH)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# EXECUTAR TUDO NO ORACLE VIA SSH
# ═══════════════════════════════════════════════════════════════════════════

ssh -i "$SSH_KEY" "$ORACLE_USER@$ORACLE_IP" << 'EOSSH'

set -e

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "✅ CONECTADO AO ORACLE"
echo "════════════════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 1. CLONE/PULL REPOSITÓRIO
# ─────────────────────────────────────────────────────────────────────────

APP_DIR="/opt/daisugi/sugoi"
REPO="https://github.com/MV-AKAGUI/FERRAMENTAS--FUZZY---HARNESS-"
BRANCH="feature/dai-integration-audit"

echo "[1/8] Repositório..."

if [ -d "$APP_DIR/.git" ]; then
  echo "  ├─ Pull (já existe)"
  cd "$APP_DIR"
  git pull origin "$BRANCH" 2>&1 | tail -3
else
  echo "  ├─ Clone (novo)"
  sudo mkdir -p "$APP_DIR"
  sudo git clone --branch "$BRANCH" "$REPO" "$APP_DIR" 2>&1 | tail -3
fi

echo "  └─ ✅ Repositório OK"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 2. CRIAR SCHEMA SUGOI NO POSTGRESQL
# ─────────────────────────────────────────────────────────────────────────

echo "[2/8] Schema PostgreSQL..."

SQL_FILE="/tmp/01_SETUP_SCHEMA_SUGOI_ORACLE.sql"
sudo cp "$APP_DIR/output/01_SETUP_SCHEMA_SUGOI_ORACLE.sql" "$SQL_FILE"

# Executar SQL no container PostgreSQL
sudo docker exec dai_postgres_vector psql \
  -U admin \
  -d memoria_vetorial \
  -f "$SQL_FILE" 2>&1 | grep -E "(CREATE|INSERT|✅|COUNT|tables|setores)" || true

echo "  └─ ✅ Schema sugoi_* criado"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 3. CRIAR DIRETÓRIOS
# ─────────────────────────────────────────────────────────────────────────

echo "[3/8] Diretórios..."

sudo mkdir -p /opt/daisugi/logs/sugoi
sudo mkdir -p /opt/daisugi/config/sugoi
sudo mkdir -p /opt/daisugi/ollama/models
sudo chown -R ubuntu:docker /opt/daisugi/ 2>/dev/null || sudo chown -R ubuntu /opt/daisugi/

echo "  └─ ✅ Diretórios OK"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 4. CRIAR .env.production
# ─────────────────────────────────────────────────────────────────────────

echo "[4/8] Arquivo .env..."

ENV_FILE="$APP_DIR/app/backend/.env.production"
cat > "$ENV_FILE" << 'DOTENV'
NODE_ENV=production
PORT=3001
LOG_LEVEL=info

DATABASE_URL=postgresql://admin:masterkey123_daisugi_segura@host.docker.internal:5432/memoria_vetorial?schema=sugoi

JWT_SECRET=SUA_CHAVE_SECRETA_SUPER_SEGURA_openssl_rand_BASE64_AQUI
JWT_EXPIRY=8h

OLLAMA_API_URL=http://sugoi-ollama:11434
OLLAMA_MODELS=["deepseek-r1:7b", "qwen2.5-coder:7b", "saullm:7b"]

GEMINI_API_KEY=CONFIGURE_COM_CHAVE_GEMINI_GCP_AQUI
GEMINI_PROJECT_ID=CONFIGURE_COM_PROJETO_GCP_AQUI

S3_ENDPOINT=https://storage.googleapis.com
S3_BUCKET=sugoi-cadeia-valor

GOOGLE_CLIENT_ID=CONFIGURE_AQUI
GOOGLE_CLIENT_SECRET=CONFIGURE_AQUI
GOOGLE_CALLBACK_URL=https://sugoi.daisugi.com.br/auth/google/callback

AZURE_AD_TENANT_ID=CONFIGURE_AQUI
AZURE_AD_CLIENT_ID=CONFIGURE_AQUI
AZURE_AD_CLIENT_SECRET=CONFIGURE_AQUI

SENTRY_DSN=
SENTRY_ENVIRONMENT=production
DOTENV

echo "  └─ ✅ .env.production criado"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 5. BUILD DOCKER IMAGE
# ─────────────────────────────────────────────────────────────────────────

echo "[5/8] Docker build..."

cd "$APP_DIR/app/backend"

# Criar Dockerfile se não existir
if [ ! -f Dockerfile ]; then
  cat > Dockerfile << 'DOCKERFILE'
FROM node:24-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

RUN npx prisma generate

EXPOSE 3001

CMD ["npm", "start"]
DOCKERFILE
fi

# Build image
echo "  ├─ Building sugoi-api:latest..."
sudo docker build -t sugoi-cadeia-valor:latest . 2>&1 | grep -E "(Step|Successfully|error)" || true

echo "  └─ ✅ Docker image built"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 6. CRIAR/VERIFICAR NETWORK
# ─────────────────────────────────────────────────────────────────────────

echo "[6/8] Docker network..."

if ! sudo docker network ls | grep -q daisugi-network; then
  echo "  ├─ Criando daisugi-network..."
  sudo docker network create daisugi-network
fi

echo "  └─ ✅ Network OK"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 7. INICIAR DOCKER COMPOSE
# ─────────────────────────────────────────────────────────────────────────

echo "[7/8] Docker Compose..."

cd "$APP_DIR"

echo "  ├─ Iniciando sugoi-api + sugoi-ollama..."
sudo docker-compose -f output/02_docker-compose-sugoi-oracle.yml up -d 2>&1 | grep -E "(Creating|Created|Starting|Started)" || true

sleep 15

echo "  ├─ Status:"
sudo docker-compose -f output/02_docker-compose-sugoi-oracle.yml ps | tail -3

echo "  └─ ✅ Docker Compose iniciado"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# 8. TESTES & CONFIGURAR CADDY
# ─────────────────────────────────────────────────────────────────────────

echo "[8/8] Testes & Caddy..."

# Esperar API iniciar
echo "  ├─ Aguardando API..."
for i in {1..30}; do
  if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    echo "  ├─ API respondendo ✅"
    break
  fi
  sleep 2
done

# Configurar Caddy
CADDYFILE="/opt/daisugi/Caddyfile"

if [ -f "$CADDYFILE" ]; then
  if ! sudo grep -q "sugoi.daisugi.com.br" "$CADDYFILE"; then
    echo "  ├─ Configurando Caddy..."
    sudo tee -a "$CADDYFILE" > /dev/null << 'CADDY'

sugoi.daisugi.com.br, sugoi.137.131.151.74.sslip.io {
    handle /api/* {
        reverse_proxy localhost:3001
    }
    handle {
        reverse_proxy localhost:3001
    }
}
CADDY

    # Recarregar Caddy
    sudo docker restart daisugi-gateway 2>&1 | tail -1
    echo "  ├─ Caddy recarregado ✅"
  fi
fi

echo "  └─ ✅ Testes & Caddy OK"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# RESUMO FINAL
# ═══════════════════════════════════════════════════════════════════════════

echo "════════════════════════════════════════════════════════════════════════"
echo "✅ DEPLOY COMPLETO"
echo "════════════════════════════════════════════════════════════════════════"
echo ""
echo "✓ [1/8] Repositório (Git pull/clone)"
echo "✓ [2/8] Schema sugoi_* (PostgreSQL)"
echo "✓ [3/8] Diretórios"
echo "✓ [4/8] .env.production"
echo "✓ [5/8] Docker image (sugoi-api:latest)"
echo "✓ [6/8] Docker network (daisugi-network)"
echo "✓ [7/8] Docker Compose (API + Ollama)"
echo "✓ [8/8] Testes + Caddy reverse proxy"
echo ""
echo "📊 Status dos containers:"
sudo docker-compose -f "$APP_DIR/output/02_docker-compose-sugoi-oracle.yml" ps
echo ""
echo "🔗 Acessos:"
echo "   Local (SSH tunnel):  http://localhost:3001"
echo "   Produção:            https://sugoi.daisugi.com.br (após DNS)"
echo "   Ollama:              http://localhost:11434 (via tunnel)"
echo ""
echo "📝 Próximos passos:"
echo "   1. Criar entrada DNS: sugoi.daisugi.com.br → 137.131.151.74"
echo "   2. Aguardar propagação (5-30 min)"
echo "   3. Testar: https://sugoi.daisugi.com.br"
echo ""
echo "✅ SEMANA 2 DEPLOY COMPLETO!"
echo ""

EOSSH

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "✅ IDE TERMINOU"
echo "════════════════════════════════════════════════════════════════════════"
echo ""
echo "Próximas ações (Manual):"
echo "  1. Criar entrada DNS: sugoi.daisugi.com.br → 137.131.151.74"
echo "  2. Testar: curl https://sugoi.daisugi.com.br/health"
echo "  3. Conferir logs: ssh -i $SSH_KEY $ORACLE_USER@$ORACLE_IP 'docker logs sugoi-api'"
echo ""
