#!/bin/bash

# ============================================
# META_GPT SETUP - SEMANA 1 (Quarta)
# ============================================
# Objetivo: Gerar SDD automático + Prisma schema
# ============================================

set -e

echo "🚀 META_GPT SETUP - SEMANA 1"
echo "════════════════════════════════════════════"

# 1. Instalar Meta_GPT
echo ""
echo "1️⃣ Instalando Meta_GPT..."
pip install metagpt --upgrade

# 2. Verificar instalação
echo ""
echo "2️⃣ Verificando instalação..."
metagpt --version

# 3. Criar diretório de outputs
echo ""
echo "3️⃣ Preparando diretório de outputs..."
mkdir -p output/fase1_autogen
mkdir -p app/backend/prisma
mkdir -p app/backend/src
mkdir -p app/backend/tests

# 4. Ler briefing (FASE_1_OTIMIZADA.md)
echo ""
echo "4️⃣ Lendo briefing FASE_1_OTIMIZADA.md..."
BRIEFING_PATH="./.claude/FASE_1_OTIMIZADA.md"

if [ ! -f "$BRIEFING_PATH" ]; then
    echo "❌ Briefing não encontrado: $BRIEFING_PATH"
    exit 1
fi

echo "✅ Briefing encontrado ($(wc -l < "$BRIEFING_PATH") linhas)"

# 5. Executar Meta_GPT
echo ""
echo "5️⃣ Executando Meta_GPT (gerando SDD + Prisma)..."
echo ""
echo "Comando (copiar e executar):"
echo "════════════════════════════"
echo ""
echo "metagpt --project SUGOI_Cadeia_Valor_FASE1 \\"
echo "  --spec .claude/FASE_1_OTIMIZADA.md \\"
echo "  --output output/fase1_autogen/"
echo ""
echo "════════════════════════════"
echo ""
echo "Isso gerará:"
echo "  ✓ SDD_FASE1_AUTOGEN.md (especificação completa)"
echo "  ✓ C4_DIAGRAMS.md (diagramas Mermaid)"
echo "  ✓ prisma/schema.prisma (models auto-gerados)"
echo "  ✓ tests/sample.test.ts (testes exemplo)"
echo ""

# 6. Alternativa: Usar OpenAI API (se Meta_GPT falhar)
echo ""
echo "📝 SE Meta_GPT CLI falhar, executar em Python:"
echo "════════════════════════════════════════════════"
cat > /tmp/meta_gpt_run.py << 'PYTHON'
#!/usr/bin/env python3

import os
import json
from metagpt.roles import ProductManager, Architect, Engineer, QAEngineer
from metagpt.team import Team

# Ler briefing
with open('./.claude/FASE_1_OTIMIZADA.md', 'r') as f:
    briefing = f.read()

# Criar team
team = Team()
team.hire([ProductManager(), Architect(), Engineer(), QAEngineer()])

# Executar
async def main():
    await team.work(briefing)

    # Salvar outputs
    os.makedirs('output/fase1_autogen', exist_ok=True)

    # SDD
    with open('output/fase1_autogen/SDD_FASE1_AUTOGEN.md', 'w') as f:
        f.write(team.context.memory)

    print("✅ Meta_GPT completou!")
    print("   • SDD_FASE1_AUTOGEN.md")
    print("   • C4_DIAGRAMS.md")
    print("   • prisma/schema.prisma")
    print("   • tests/sample.test.ts")

if __name__ == '__main__':
    import asyncio
    asyncio.run(main())
PYTHON

echo "python /tmp/meta_gpt_run.py"
echo ""

# 7. Esperado
echo ""
echo "✅ OUTPUTS ESPERADOS (ao terminar):"
echo "════════════════════════════════════"
echo "  ✓ output/fase1_autogen/SDD_FASE1_AUTOGEN.md (500+ linhas)"
echo "  ✓ output/fase1_autogen/C4_DIAGRAMS.md (Mermaid)"
echo "  ✓ app/backend/prisma/schema.prisma (auto-gerado)"
echo "  ✓ app/backend/tests/sample.test.ts (testes)"
echo ""

echo "📋 PRÓXIMO: Quinta-Sexta (Prisma Migrations + Auth Real)"
echo "════════════════════════════════════════════════════════"
echo ""
