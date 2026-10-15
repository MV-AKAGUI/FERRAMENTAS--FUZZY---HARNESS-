#!/bin/bash
# META_GPT CLI Wrapper para Claude Code (Bash/Linux)
# Uso: ./meta-gpt-cli.sh -t "seu_prompt" -m deepseek-r1

set -e

TASK=""
MODEL="claude-opus-5-5"
WATCH=false
DAISUGI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

usage() {
    echo "❌ Uso: $0 -t <task> [-m <model>] [-w]"
    echo "  -t: Tarefa/prompt para Meta_GPT (obrigatório)"
    echo "  -m: Modelo (deepseek-r1, qwen2.5-coder, claude-opus-5-5) [padrão: claude-opus-5-5]"
    echo "  -w: Watch mode (monitorar workspace)"
    exit 1
}

while getopts "t:m:wh" opt; do
    case $opt in
        t) TASK="$OPTARG" ;;
        m) MODEL="$OPTARG" ;;
        w) WATCH=true ;;
        *) usage ;;
    esac
done

[ -z "$TASK" ] && usage

WORKSPACE="$DAISUGI_ROOT/daisugi_workspace"
mkdir -p "$WORKSPACE"

echo "🚀 Meta_GPT DAISUGI CLI"
echo "Task: $TASK"
echo "Model: $MODEL"
echo "Workspace: $WORKSPACE"

# Invocar Python MCP server
python3 "$(dirname "${BASH_SOURCE[0]}")/meta-gpt-server.py" << EOF
{
  "method": "execute_workflow",
  "params": {
    "task": "$TASK",
    "model": "$MODEL",
    "workspace": "$WORKSPACE"
  }
}
EOF

if [ "$WATCH" = true ]; then
    echo ""
    echo "📁 Workspace:"
    find "$WORKSPACE" -type f 2>/dev/null | head -20
fi
