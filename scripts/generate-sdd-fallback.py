#!/usr/bin/env python3
"""
FALLBACK: Geração de SDD via Claude API (se Meta_GPT falhar)
Lê FASE_1_OTIMIZADA.md e gera SDD, C4, Prisma schema via LLM
"""

import sys
import json
from pathlib import Path

# Tenta importar Claude API
try:
    from anthropic import Anthropic
except ImportError:
    print("❌ Anthropic SDK não instalado. Instale: pip install anthropic")
    sys.exit(1)


def generate_sdd_fallback(briefing_path: str, output_dir: str):
    """
    Gera SDD, C4, Prisma schema usando Claude API como fallback.
    """
    print("\n" + "="*80)
    print("🔄 FALLBACK: Geração SDD via Claude API")
    print(f"   Briefing: {briefing_path}")
    print(f"   Output: {output_dir}")
    print("="*80)

    briefing_file = Path(briefing_path)
    if not briefing_file.exists():
        print(f"❌ ERRO: Briefing não encontrado: {briefing_path}")
        sys.exit(1)

    # Ler briefing
    with open(briefing_file, 'r', encoding='utf-8') as f:
        briefing = f.read()

    print(f"\n✅ Briefing carregado ({len(briefing)} caracteres)")

    # Inicializar cliente Claude
    client = Anthropic()

    # Prompt para geração SDD
    prompt = f"""
Você é um arquiteto de software especializado em sistemas corporativos.

Baseado no briefing abaixo, gere uma **Especificação de Sistema Detalhada (SDD)** com:

1. **Resumo Executivo** (5 linhas)
2. **Arquitetura C4** (Context, Container, Component diagrams em Mermaid)
3. **Prisma Schema** (Models e relações de banco de dados)
4. **Pydantic Contracts** (Validação de API)
5. **14 Setores Definidos** (lista imutável)
6. **RACI Matrix** (Responsabilidades)
7. **API Endpoints** (POST, GET, PUT operações)

---

BRIEFING:

{briefing}

---

GERE AGORA A SDD COMPLETA (mínimo 500 linhas).
"""

    print("\n🤖 Chamando Claude API para gerar SDD...")

    try:
        message = client.messages.create(
            model="claude-opus-5-5",  # Usar o melhor modelo
            max_tokens=4000,
            messages=[
                {"role": "user", "content": prompt}
            ]
        )

        sdd_content = message.content[0].text

        # Criar diretório de output
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        # Salvar SDD
        sdd_file = output_path / "SDD_FASE1_AUTOGEN.md"
        with open(sdd_file, 'w', encoding='utf-8') as f:
            f.write(sdd_content)

        print(f"\n✅ SDD gerado: {sdd_file}")
        print(f"   {len(sdd_content)} caracteres")

        # Extrair Prisma schema (se incluído na resposta)
        if "```prisma" in sdd_content:
            prisma_start = sdd_content.find("```prisma")
            prisma_end = sdd_content.find("```", prisma_start + 9)
            if prisma_end > prisma_start:
                prisma_code = sdd_content[prisma_start+9:prisma_end].strip()
                prisma_file = output_path / "schema.prisma"
                with open(prisma_file, 'w', encoding='utf-8') as f:
                    f.write(prisma_code)
                print(f"✅ Prisma schema extraído: {prisma_file}")

        print("\n" + "="*80)
        print("✅ FALLBACK CONCLUÍDO COM SUCESSO")
        print("="*80)

    except Exception as e:
        print(f"\n❌ ERRO ao chamar Claude API: {e}")
        sys.exit(1)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Fallback SDD Generation via Claude API")
    parser.add_argument("--spec", required=True, help="Caminho para briefing (FASE_1_OTIMIZADA.md)")
    parser.add_argument("--output", default="./output/fase1_autogen/", help="Diretório de saída")

    args = parser.parse_args()

    generate_sdd_fallback(args.spec, args.output)
