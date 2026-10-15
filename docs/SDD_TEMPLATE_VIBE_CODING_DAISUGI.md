# Template de Especificação Dirigida por Design (SDD - Spec-Driven Development)
# Ecossistema Daisugi — Governança Dr. Taylor & Antigravity Vibe Coding

Este documento é a âncora soberana de qualquer nova aplicação ou módulo.
Nenhum código deve ser gerado antes do preenchimento e aprovação destas 4 seções.

---

## 1. Constituição do Projeto (`constitution`)
* **Nome do Módulo / Aplicação:** [Ex: Portal de Custódia Documental]
* **Missão Principal:** [Ex: Permitir consulta de certidões e validação fonética com zero alucinação]
* **Identidade Visual e Atendimento:** DAI (Lobby Soberano — Proibido expor modelos de IA na tela)
* **Leis Inegociáveis:**
  1. Tolerância zero a alucinação (grounding obrigatório via RapidFuzz / Docling / PostgreSQL).
  2. Isolamento estrito de credenciais (KeePass / PAM-IGA, nunca em código).
  3. Segregação de Funções (SoD: Maker-Checker com HTTP 403 para auto-aprovação).
  4. Sincronização obrigatória com o repositório Git.

---

## 2. Especificação Funcional (`specify`)
*(Escrita em português de negócio — pensada para gestores e não-engenheiros)*

* **Quem usa? (Atores):** [Ex: Diretor de Operações, Analista Financeiro, Fornecedor]
* **Qual é o fluxo do usuário?**
  * Passo 1: O usuário faz o upload do balanço ou certidão.
  * Passo 2: O sistema saneia a razão social e CNPJ via RapidFuzz.
  * Passo 3: O sistema exibe os dados estruturados e pede confirmação.
* **O que o sistema NÃO deve fazer? (Limites de Escopo):**
  * [Ex: Não emite parecer jurídico definitivo sem assinatura do Dr. SaulLM].

---

## 3. Anatomia Técnica & Arquitetura da Aplicação (`plan`)

### A. Camada de Interface (Vibe Design & Front-End)
* **Framework:** HTML/CSS moderno ou Vite + React (se complexo).
* **Componentes:** Shadcn/UI (Dark mode nativo, cards de status, tabelas com ordenação).
* **Regra de UI:** Zero jargão técnico visível ao usuário final.

### B. Camada de Lógica & APIs (Back-End)
* **Framework:** FastAPI (Python 3.11 no `.venv`).
* **Documentação Interativa:** Swagger UI ativo em `/docs`.
* **Cabresto Estrutural:** Validação estrita via `Instructor` + `Pydantic` (anti-alucinação).

### C. Camada de Dados & Persistência
* **Banco Relacional e Vetorial:** PostgreSQL + pgvector (HDW Linux - Porta 5432).
* **Custódia Documental:** Hudson API (Porta 8000).
* **Extração Fiel:** Docling Parser (Desktop / HDW).

### D. Camada de Segurança & Auditoria
* **Proteção Local de Segredos:** Gitleaks ativo antes de commits.
* **Auditoria de Código:** Claude Code CLI (Nuvem) com failover para DeepSeek-R1 / Qwen2.5-Coder (Ollama Local).

---

## 4. Plano de Tarefas Atômicas (`tasks`)
- [ ] **Tarefa 1:** Criar os modelos Pydantic de entrada e saída com validação do `Instructor`.
- [ ] **Tarefa 2:** Gerar o diagrama visual de anatomia com `diagrams`.
- [ ] **Tarefa 3:** Implementar endpoints no FastAPI e validar na rota `/docs`.
- [ ] **Tarefa 4:** Montar interface com componentes do `Shadcn/UI`.
- [ ] **Tarefa 5:** Executar varredura do `Gitleaks` e sincronizar com o GitHub via Git Auto-Sync.
