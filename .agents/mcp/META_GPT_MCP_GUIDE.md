# 🤖 Meta_GPT MCP Server - Guia de Uso Claude Code

**Status:** ✅ Pronto para operação  
**Versão:** DAISUGI-1.0.0  
**Compatibilidade:** Claude Code + Ollama Local  

---

## 📋 Instalação (Uma Vez)

### 1. Verificar estrutura criada
```bash
# Deve existir:
.claude/settings.json          # ✅ Configuração MCP
.agents/mcp/meta-gpt-server.py # ✅ Server wrapper
.agents/mcp/meta-gpt-cli.ps1   # ✅ CLI PowerShell
.agents/mcp/meta-gpt-cli.sh    # ✅ CLI Bash
```

### 2. Inicializar Meta_GPT (primeira vez)
```powershell
# Windows/PowerShell
cd C:\Users\Ronaldo Akagui.SUG00245\DAISUGI_TECNOLOGIAS\FERRAMENTAS--FUZZY---HARNESS-
.\.agents\mcp\meta-gpt-cli.ps1 -Task "init" -Model "claude-opus-5-5"
```

```bash
# Linux/Mac
bash .agents/mcp/meta-gpt-cli.sh -t "init" -m "claude-opus-5-5"
```

---

## 🚀 Uso via CLI (Recomendado para Chat)

### **Opção 1: PowerShell (Windows)**

```powershell
# Sintaxe básica
.\.agents\mcp\meta-gpt-cli.ps1 -Task "sua tarefa aqui"

# Exemplo 1: Gerar PRD
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Gerar PRD para sistema de pagamento" -Model "claude-opus-5-5"

# Exemplo 2: Com modelo local (DeepSeek)
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Arquitetura de microserviços" -Model "deepseek-r1"

# Exemplo 3: Com watch mode (monitorar output)
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Criar estrutura Django" -Watch
```

### **Opção 2: Bash/Shell (Linux/Mac)**

```bash
# Sintaxe básica
bash .agents/mcp/meta-gpt-cli.sh -t "sua tarefa aqui"

# Exemplo 1: Gerar código
bash .agents/mcp/meta-gpt-cli.sh -t "Backend Python com FastAPI" -m "qwen2.5-coder"

# Exemplo 2: Com watch
bash .agents/mcp/meta-gpt-cli.sh -t "Estrutura de testes" -w
```

---

## 🎯 Comando Único para Chat (RECOMENDADO)

### **Digite isso aqui no Claude Code chat:**

#### Windows (PowerShell):
```
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Descreva aqui o que Meta_GPT deve fazer" -Model "claude-opus-5-5" -Watch
```

#### Linux/Mac (Bash):
```
bash .agents/mcp/meta-gpt-cli.sh -t "Descreva aqui o que Meta_GPT deve fazer" -m "claude-opus-5-5" -w
```

---

## 💡 Casos de Uso Prático

### **Caso 1: Gerar PRD automaticamente**

```powershell
.\.agents\mcp\meta-gpt-cli.ps1 `
  -Task "PRD para sistema CRM: rastreamento de vendas, pipeline de negócios, relatórios de analytics" `
  -Model "claude-opus-5-5" `
  -Watch
```

### **Caso 2: Arquitetura de Sistema**

```powershell
.\.agents\mcp\meta-gpt-cli.ps1 `
  -Task "Arquitetura cloud-native para processamento de PDF com IA usando Docker, K8s e API REST" `
  -Model "deepseek-r1" `
  -Watch
```

### **Caso 3: Geração de Código (com Qwen local)**

```powershell
.\.agents\mcp\meta-gpt-cli.ps1 `
  -Task "Código Python para pipeline ETL com Airflow, Spark e PostgreSQL" `
  -Model "qwen2.5-coder" `
  -Watch
```

### **Caso 4: Plano de Testes E2E**

```powershell
.\.agents\mcp\meta-gpt-cli.ps1 `
  -Task "Plano de testes E2E com Playwright, Cucumber e CI/CD" `
  -Model "claude-opus-5-5"
```

---

## 🎛️ Modelos Disponíveis

| Modelo | Tipo | Melhor para |
|--------|------|------------|
| **claude-opus-5-5** | Cloud | Raciocínio complexo, PRD, arquitetura |
| **deepseek-r1** | Local (Ollama) | Raciocínio estruturado, debugging |
| **qwen2.5-coder** | Local (Ollama) | Geração de código, sintaxe |

---

## 📁 Output & Workspace

Todos os outputs vão para:
```
./daisugi_workspace/
```

Estrutura gerada:
```
daisugi_workspace/
├── workflows/           # Workflows Meta_GPT (JSON)
├── artifacts/           # PRDs, documentos
├── code/               # Código gerado
├── logs/               # Logs de execução
└── reports/            # Relatórios finais
```

---

## 🔧 Configuração Avançada

### Customizar variáveis de ambiente

Editar `.claude/settings.json`:

```json
{
  "mcpServers": {
    "meta-gpt-daisugi": {
      "env": {
        "META_GPT_WORKSPACE": "./custom_workspace",
        "META_GPT_MODE": "interactive",  // "headless" ou "interactive"
        "TIMEOUT": "600"
      }
    }
  }
}
```

### Adicionar novos modelos

Editar `.agents/mcp/meta-gpt-server.py`:

```python
self.models = [
    "deepseek-r1",
    "qwen2.5-coder", 
    "claude-opus-5-5",
    "seu-modelo-novo"  # ← Adicionar aqui
]
```

---

## 🚨 Troubleshooting

### Erro: "Script execution disabled"

```powershell
# Windows: Permitir scripts locais
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erro: "Meta_GPT não encontrado"

```powershell
# Verificar se .venv está ativo
.\.venv\Scripts\Activate.ps1
pip list | grep metagpt
```

### Erro: "Ollama não conecta"

```powershell
# Verificar se Ollama está rodando
curl http://127.0.0.1:11434/api/tags
```

---

## 📊 Fluxo de Integração Antigravity → Claude Code

```
Antigravity IDE (PMO)
    ↓
Define tarefa → "Gerar PRD para X"
    ↓
Claude Code recebe:
    .\.agents\mcp\meta-gpt-cli.ps1 -Task "..." -Watch
    ↓
Meta_GPT (via MCP)
    ├─ DeepSeek-R1 (Local) ──→ Raciocínio
    ├─ Qwen2.5 (Local) ────→ Código
    └─ Opus (Cloud) ───────→ Síntese
    ↓
Output em daisugi_workspace/
    ↓
GitHub auto-sync
```

---

## ✨ Quick Commands para Chat

```bash
# Copie e cole um destes no chat Claude Code:

# 1. PRD rápido
.\.agents\mcp\meta-gpt-cli.ps1 -Task "PRD para [seu_produto]" -Model claude-opus-5-5 -Watch

# 2. Arquitetura
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Arquitetura para [seu_sistema]" -Model deepseek-r1 -Watch

# 3. Código
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Código [linguagem] para [funcionalidade]" -Model qwen2.5-coder -Watch

# 4. Testes
.\.agents\mcp\meta-gpt-cli.ps1 -Task "Plano de testes E2E para [seu_app]" -Model claude-opus-5-5

# Linux/Mac (trocar .\.agents pela bash chamada):
bash .agents/mcp/meta-gpt-cli.sh -t "sua tarefa" -m claude-opus-5-5 -w
```

---

## 📚 Documentação Relacionada

- `CLAUDE.md` - Diretrizes do projeto
- `COMPATIBILIDADE_CLAUDE_CODE_vs_ANTIGRAVITY.md` - Integração arquitectura
- `.agents/rules/vibe_coding_daisugi.md` - Mandamentos Vibe Coding

---

**Assinado por:** Claude Haiku 4.5 | Daisugi PMO  
**Data:** 15/10/2026 16:00  
**Status:** ✅ Pronto para produção
