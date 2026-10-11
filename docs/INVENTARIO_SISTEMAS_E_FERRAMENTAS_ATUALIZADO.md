# Inventário de Sistemas e Ferramentas do Ecossistema Daisugi (Atualizado)
**Data e Hora da Varredura:** 11/10/2026 18:10:00  
**Autoridade:** PMO Governança de IA & Dr. Taylor  
**Ambiente:** Google Antigravity IDE / Desktop Windows & Nó Servidor HDW Linux  

---

## 1. Ferramentas Core do Vibe Coding & Inteligência Artificial

| Ferramenta / Módulo | Versão / Endpoint | Status Operacional | Papel no Ecossistema |
|---|---|---|---|
| **Google Antigravity IDE** | 2.5.5 | ✅ Ativo e Operacional | Plataforma Soberana de Vibe Coding & Orquestração Central |
| **Dr. Taylor (Skill Homeostase)** | 1.0.0 (`.agents/skills`) | ✅ Ativo e Operacional | Engenheiro de Soluções e Regulador de Homeostase Computacional |
| **Meta_GPT DAISUGI** | Branch main (`.venv`) | ✅ Ativo e Operacional | Software House Multi-Agente (SOPs: PRD, Arquiteto, Dev, QA) |
| **Docling Parser (Desktop)** | 2.130.0 | ✅ Ativo e Operacional | Ingestão e parsing fiel de tabelas, balanços e relatórios |
| **Docling Parser (HDW Linux)** | 2.135.0 | ✅ Ativo e Operacional | Ingestão acelerada de PDFs e documentos pesados no servidor |
| **RapidFuzz (Desktop)** | 3.14.6 (`.venv`) | ✅ Ativo e Operacional | Sanitização fonética, cadastral e tolerância zero a divergências |
| **RapidFuzz (HDW Linux)** | 3.14.6 | ✅ Ativo e Operacional | Processamento fonético de alta performance no servidor |
| **Claude Code CLI** | 2.1.263 | ✅ Instalado (Audit Mode) | Auditor Externo de Estrutura e Funcionalidade (Primário) |
| **DeepSeek-R1 (Local Ollama)** | 8B (Q4_K_M) | ✅ Ativo (Porta 11434) | Auditor Local de Contingência (Failover quando Claude expirar) |
| **Qwen2.5-Coder (Local Ollama)** | 7B (Q4_K_M) | ✅ Ativo (Porta 11434) | Auditor Sintático Local & Gerador de Código Offline |
| **Ollama Engine** | v0.35.0 (Windows) | ✅ Ativo e Operacional | Escudo Local de Processamento Seguro (Zero Vazamento) |
| **PostgreSQL + pgvector (HDW)** | Porta 5432 (Docker) | ✅ Ativo e Operacional | Banco de Dados Relacional e Vetorial para RAG Grounded |
| **Hudson API Backend (HDW)** | Porta 8000 (Docker) | ✅ Ativo e Operacional | Serviços de Custódia, Desbloqueio e Ingestão de Documentos |
| **Gitness / Git Harness** | 2.55.0.3 | ✅ Ativo e Operacional | Controle de Versão, Rastreabilidade e GitHub Auto-Sync |

---

## 2. Ferramentas Desktop e Utilitários de Apoio Corporativo

| Sistema / Aplicativo | Versão | Fabricante | Função |
|---|---|---|---|
| **Draw.io** | 31.5.3 | JGraph | Modelagem de arquiteturas e diagramas conceituais |
| **Docker Desktop** | 29.8.1 | Docker Inc. | Motor de contêineres local (Windows/WSL) |
| **Python** | 3.11.9 (Local) / 3.11.11 (HDW) | Python Software Foundation | Runtimes padronizados de desenvolvimento |
| **Node.js / npm** | 20.x / 10.x | OpenJS Foundation | Execução de pacotes CLI (Claude Code, OmniRoute) |
| **Git** | 2.55.0.3 | Git Community | Versionamento e automação de repositórios |
| **KeePass Password Safe** | 2.60 | Dominik Reichl | Cofre local seguro de credenciais e senhas |
| **Bitdefender Endpoint Security**| 8.26.10.670 | Bitdefender | Proteção de endpoint e isolamento corporativo |
| **Assinador Serpro** | 4.4.0 | Serpro | Assinatura digital de documentos e certidões públicas |
| **Assinador Quick Soft** | 0.9.2 | Quick Soft | Módulo nativo de assinatura corporativa |
| **Google Chrome / Edge** | 154.x | Google / Microsoft | Navegadores e DevTools para testes de front-end |

---

## 3. Matriz de Contingência (Failover de Auditoria)
* **Condição Normal:** Auditoria conduzida pelo **Claude Code** para inspeção estrutural e validação funcional.
* **Condição de Esgotamento de Tokens / Offline:** O sistema chaveia automaticamente para o **DeepSeek-R1 (Local Ollama)** e **Qwen2.5-Coder (Local Ollama)**, garantindo que o ciclo de desenvolvimento **nunca seja paralisado**.
