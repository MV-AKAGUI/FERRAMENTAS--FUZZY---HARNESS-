# Diretrizes do Projeto - Atuação Integrada com Antigravity IDE

## Contexto de Execução
- Este repositório é gerenciado pelo **Antigravity IDE** atuando como PMO Orquestrador (Harness).
- O **Claude Code** é utilizado como motor especialista de código para tarefas técnicas e refatorações complexas.
- O gateway local (`OmniRoute`) e instâncias locais (Ollama / LM Studio) são acionados para absorver processamento quando as cotas de nuvem atingem limite.

## Regras de Atuação
1. **Atendimento a Sprints**: Siga estritamente as instruções passadas pelo Antigravity PMO.
2. **Preservação do Contexto**: Sempre leia a estrutura de arquivos antes de realizar modificações diretas.
3. **Modificações Cirúrgicas (Karpathy Guidelines)**: Altere estritamente o necessário. Não reescreva arquivos inteiros nem destrua comentários ou docstrings.
4. **Economia de Tokens (Caveman Mode)**: Responda de forma direta, técnica e concisa, eliminando prolixidade.
5. **Sincronização**: Ao finalizar qualquer alteração de código ou documentação, assegure que o estado do repositório esteja íntegro e validado para auto-sync com o GitHub.
