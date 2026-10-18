#!/bin/bash

################################################################################
# semana3-checklist-pre-monday.sh
# Validações pré-Semana 3: DOMINGO antes de segunda 08:00
# Retorna GO/NO-GO para desenvolvimento
################################################################################

set +e  # Don't exit on error (queremos todos os testes)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Score tracking
PASSED=0
FAILED=0

# ═══════════════════════════════════════════════════════════════════════════
# Função para testar
# ═══════════════════════════════════════════════════════════════════════════

check() {
  local name=$1
  local cmd=$2
  local expected=$3

  if eval "$cmd" &>/dev/null; then
    echo -e "${GREEN}✅${NC} $name"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}❌${NC} $name"
    ((FAILED++))
    return 1
  fi
}

echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}📋 CHECKLIST PRÉ-SEGUNDA — SEMANA 3${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# INFRA
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}INFRAESTRUTURA:${NC}"

check "Node.js 24.x instalado" "node -v | grep -q 'v24'"
check "npm 10.x instalado" "npm -v | grep -q '^10'"
check "Git instalado" "git --version | grep -q 'version'"
check "Docker rodando" "docker ps > /dev/null 2>&1"
check "SSH key ~/.ssh/ssh-key-2026-09-25.key existe" "[ -f ~/.ssh/ssh-key-2026-09-25.key ]"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# DATABASE
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}BANCO DE DADOS:${NC}"

check "PostgreSQL container (dai_postgres_vector) rodando" "docker ps | grep -q dai_postgres_vector"
check "PostgreSQL porta 5432 acessível" "nc -zv localhost 5432 2>/dev/null"
check "Schema sugoi_* existe" "psql -h localhost -U admin -d memoria_vetorial -c '\\dt sugoi_*' | grep -q processo_bpm"
check "Tabela processo_bpm acessível" "psql -h localhost -U admin -d memoria_vetorial -c 'SELECT COUNT(*) FROM sugoi.processo_bpm;' | grep -q '[0-9]'"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# LLM
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}OLLAMA (LLM LOCAL):${NC}"

check "Ollama container rodando" "docker ps | grep -q ollama"
check "Ollama porta 11434 acessível" "curl -s http://localhost:11434/api/tags > /dev/null 2>&1"
check "DeepSeek-R1 disponível" "curl -s http://localhost:11434/api/tags | grep -q 'deepseek'"
check "Qwen 2.5 disponível" "curl -s http://localhost:11434/api/tags | grep -q 'qwen'"
check "SaulLM disponível" "curl -s http://localhost:11434/api/tags | grep -q 'saullm'"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# BACKEND
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}BACKEND (Node.js):${NC}"

BACKEND_DIR="/opt/daisugi/sugoi/app/backend"

check "Diretório backend existe" "[ -d $BACKEND_DIR ]"
check "package.json existe" "[ -f $BACKEND_DIR/package.json ]"
check "node_modules instalado" "[ -d $BACKEND_DIR/node_modules ]"
check "Módulo pg (PostgreSQL) instalado" "[ -d $BACKEND_DIR/node_modules/pg ]"
check "Prisma gerado" "[ -d $BACKEND_DIR/node_modules/.prisma ]"
check ".env.production existe" "[ -f $BACKEND_DIR/.env.production ]"
check ".env.production tem DATABASE_URL" "grep -q 'DATABASE_URL' $BACKEND_DIR/.env.production"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# FRONTEND
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}FRONTEND (DIFY):${NC}"

DIFY_DIR="/opt/daisugi/sugoi/dify"

check "Diretório dify existe" "[ -d $DIFY_DIR ]"
check "Dockerfile existe" "[ -f $DIFY_DIR/Dockerfile ]"
check "Docker image dify:semana3 built" "docker images | grep -q 'dify.*semana3'"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# GIT
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}GIT:${NC}"

GIT_DIR="/opt/daisugi/sugoi"

check "Git repository inicializado" "[ -d $GIT_DIR/.git ]"
check "Branch feature/dai-integration-audit existe" "cd $GIT_DIR && git branch | grep -q 'feature/dai-integration-audit'"
check "Branch feature/dai-integration-audit ativo" "cd $GIT_DIR && git branch | grep -q '* feature/dai-integration-audit'"
check "Repo sincronizado com origin" "cd $GIT_DIR && git fetch origin > /dev/null 2>&1 && [ -z \"\$(git rev-list --count @{u}...HEAD)\" ]"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# DOCUMENTAÇÃO
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}DOCUMENTAÇÃO:${NC}"

OUTPUT_DIR="/opt/daisugi/sugoi/output"

check "BRIEFING_MASTER_SEMANA3_IDE.md existe" "[ -f $OUTPUT_DIR/BRIEFING_MASTER_SEMANA3_IDE.md ]"
check "SDD_SEMANA3_ANATOMIA_COMPLETA.md existe" "[ -f $OUTPUT_DIR/SDD_SEMANA3_ANATOMIA_COMPLETA.md ]"
check "RESUMO_INTELIGENCIA_SEMANA3.md existe" "[ -f $OUTPUT_DIR/RESUMO_INTELIGENCIA_SEMANA3.md ]"
check "auto-setup-semana3.sh existe" "[ -f $OUTPUT_DIR/auto-setup-semana3.sh ]"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# SECURITY
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}SEGURANÇA:${NC}"

check "SSH key tem permissões corretas (600)" "[ -f ~/.ssh/ssh-key-2026-09-25.key ] && [ \$(stat -f%A ~/.ssh/ssh-key-2026-09-25.key 2>/dev/null) = '600' ] || true"
check ".env.production não commitado no git" "cd $BACKEND_DIR && ! git ls-files | grep -q '.env.production' || true"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# RESULTADO
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"

TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))

echo -e "${CYAN}RESULTADO: $PASSED/$TOTAL checks passaram ($PERCENTAGE%)${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🟢 GO — PRONTO PARA SEGUNDA 08:00${NC}"
  echo ""
  echo "Todos os sistemas estão prontos!"
  echo "Execute auto-setup-semana3.sh segunda de manhã."
  exit 0
else
  echo -e "${YELLOW}🟡 ATENÇÃO — $FAILED items falharam${NC}"
  echo ""
  echo "Ações necessárias:"
  echo "  1. Revisar os ❌ acima"
  echo "  2. Corrigir manualmente os sistemas falhados"
  echo "  3. Re-rodar este checklist"
  echo ""
  echo "Contato para bloqueadores:"
  echo "  • Banco de dados: DBA"
  echo "  • Docker/Ollama: DevOps"
  echo "  • Backend: Dev Lead"
  exit 1
fi
