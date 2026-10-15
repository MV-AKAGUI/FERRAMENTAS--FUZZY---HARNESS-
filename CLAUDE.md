# Diretrizes do Projeto - Atuação Integrada com Antigravity IDE

## Contexto de Execução
- Este repositório é gerenciado pelo **Antigravity IDE** atuando como PMO Orquestrador (Harness).
- O **Claude Code** é utilizado como motor especialista de código para tarefas técnicas e refatorações complexas.
- O gateway local (`OmniRoute`) e instâncias locais (Ollama / LM Studio) são acionados para absorver processamento quando as cotas de nuvem atingem limite.
- **`Dai_Vibe_Code`** é o Arquiteto-Chefe especializado em design-first, anti-alucinação e governança RACI.

## Regras de Atuação
1. **Atendimento a Sprints**: Siga estritamente as instruções passadas pelo Antigravity PMO.
2. **Preservação do Contexto**: Sempre leia a estrutura de arquivos antes de realizar modificações diretas.
3. **Modificações Cirúrgicas (Karpathy Guidelines)**: Altere estritamente o necessário. Não reescreva arquivos inteiros nem destrua comentários ou docstrings.
4. **Economia de Tokens (Caveman Mode)**: Responda de forma direta, técnica e concisa, eliminando prolixidade.
5. **Sincronização**: Ao finalizar qualquer alteração de código ou documentação, assegure que o estado do repositório esteja íntegro e validado para auto-sync com o GitHub.

## Dai_Vibe_Code: Agente Arquitetônico
### Invocação
```bash
# No Antigravity IDE
/agent dai-vibe-code --mode "discovery" --input "[seu briefing]"

# No Claude Code
claude /dai-vibe-code
```

### Capacidades
- ✅ **Escuta Ativa**: Captura contexto, stakeholders, restrições
- ✅ **Grill-Me**: 7 perguntas socrática validam premissas (com % confiança)
- ✅ **Anatomia Técnica**: C4, SDD, Schemas Pydantic, RACI, Tech Stack
- ✅ **Anti-Alucinação**: Guardrails de validação em 3 camadas
- ✅ **Fuzzy Gates**: Decisões respeitam confiança % e harness RACI

### Gates & Alçada
- 🟢 **Livre**: Specs, C4, Pydantic, testes locais, Grill-Me
- 🔴 **Bloqueado**: PostgreSQL schema, Docker port, commits prod (requer "De Acordo")

### Recursos
- 📄 Skill oficial: `.claude/skills/dai-vibe-code/`
- 📋 Grill-Me Protocol: 7 perguntas + matrix de confiança
- 🛡️ Guardrails: anti-alucinação em 3 camadas
- 🔌 Tech Stack: Meta_GPT, LangChain Graph, n8n, Dify, Ollama
