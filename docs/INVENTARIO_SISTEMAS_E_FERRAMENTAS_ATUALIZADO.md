# Inventário Completo de Sistemas, Ferramentas, Plugins, Skills e Regras do Ecossistema Daisugi

**Data e Hora da Consolidação:** 15/10/2026 15:15:00  
**Autoridade:** PMO Governança de IA, Dr. Taylor Code & Claude Code  
**Ambiente:** Google Antigravity IDE (Desktop Windows) & Nó Servidor HDW Linux  
**Status de Homologação:** 100% Auditado e Atualizado  

---

## 1. Regras de Governança e Diretrizes Inegociáveis (Harness & Fuzzy)

O repositório e o ecossistema são governados por diretrizes rígidas gravadas em `.agents/rules/vibe_coding_daisugi.md`, `CLAUDE.md` e regras globais de auto-sync:

1. **Protocolo Permanente de Vibe Coding Daisugi (`.agents/rules/vibe_coding_daisugi.md`):**
   * **Condução pelo Dr. Taylor Code & Conselho Clínico:** Decisões avaliadas sob a ótica de Homeostase Computacional (latência submétrica, tolerância a falhas, concorrência desacoplada $O(1)$, estabilidade de ambiente).
   * **Conselho Especialista Multidisciplinar:**
     * *Dr. Taylor / Qwen 2.5 Coder:* Homeostase de software, código, matemática e robustez de APIs.
     * *Dr. SaulLM:* Compliance jurídico, contratos, catálogo de cadeiras e segregação de funções (SoD).
     * *Mistral-Nemo:* Tratamento de ambiguidade, sanitização semântica e casamento difuso (RapidFuzz).
     * *DeepSeek-R1:* Raciocínio formal estruturado, auditoria de hashes SHA-256 e custódia documental (HDW).
   * **Zero Vazamento Cognitivo na UI (Identidade Soberana):** O usuário final nunca escolhe ou visualiza modelos/toggles na tela (ex: Llama, Qwen, DeepSeek). Quem atende é a identidade soberana da aplicação (**DAI**). Modelos operam invisivelmente no back-end.
   * **RapidFuzz Grounding & Anti-Alucinação Nível Zero:** Proibição de inferências soltas. Toda triagem fonética/cadastral passa por RapidFuzz e casamento vetorial fundamentado (RAG / Docling / HDW).
   * **Blindagem de Acesso, SoD e Contrato PAM/IGA:** Segregação estrita de funções (*Maker-Checker*). Quem solicita nunca auto-aprova quarentena (HTTP 403). Credenciais geridas sob cofre.
   * **Soberania Local & Otimização de Tokens:** Priorização do acervo local via Ollama (`http://127.0.0.1:11434`) para custo zero de tokens de nuvem/IDE e autonomia offline.
   * **Disciplina Karpathy:** Intervenções cirúrgicas (*surgical-patch*), evidência de teste executável (*verify-and-stop*) e auto-sync obrigatório no Git.

2. **Diretrizes Claude Code (`CLAUDE.md`):**
   * Atuação como auditor e especialista de refatoração sob comando do Antigravity PMO.
   * Preservação rigorosa de contexto, modificações cirúrgicas e síntese objetiva (*Caveman mode*).

3. **Regra Global GitHub Auto-Sync:**
   * Sincronização automática a cada ciclo aprovado (`git status` ──► `git pull origin main` ──► `git add .` ──► `git commit` ──► `git push origin main`).

---

## 2. Ferramentas Core do Vibe Coding & Inteligência Artificial

| Ferramenta / Módulo | Versão / Endpoint | Status Operacional | Papel no Ecossistema |
|---|---|---|---|
| **Google Antigravity IDE** | 2.5.5 | ✅ Ativo e Operacional | Plataforma Soberana de Vibe Coding, Orquestração e Terminal Central |
| **Dr. Taylor Code** | 1.0.0 (`.agents/skills`) | ✅ Ativo e Operacional | Engenheiro de Soluções e Regulador de Homeostase Computacional |
| **Meta_GPT DAISUGI** | Branch main (`.venv`) | ✅ Ativo e Operacional | Software House Multi-Agente (SOPs: PRD, Arquiteto, Engenheiro, QA) |
| **Docling Parser (Desktop)** | 2.130.0 | ✅ Ativo e Operacional | Ingestão e extração de alta fidelidade de PDFs, tabelas e balanços |
| **Docling Parser (HDW Linux)** | 2.135.0 | ✅ Ativo e Operacional | Ingestão acelerada de documentos pesados no nó de computação |
| **RapidFuzz (Desktop)** | 3.14.6 (`.venv`) | ✅ Ativo e Operacional | Sanitização lexical, busca fonética e tolerância zero a divergências |
| **RapidFuzz (HDW Linux)** | 3.14.6 | ✅ Ativo e Operacional | Processamento fonético e batimento cadastral de alta performance |
| **Claude Code CLI** | 2.1.263 | ✅ Instalado (Audit Mode) | Auditor Externo de Estrutura, Conformidade, Código e QA |
| **Ollama Engine** | v0.35.0 (Windows) | ✅ Ativo (Porta 11434) | Escudo Local de Processamento Seguro (Zero Vazamento Cognitivo) |
| **DeepSeek-R1 (Local Ollama)** | 8B (Q4_K_M) | ✅ Ativo (Porta 11434) | Auditor Local de Contingência e Raciocínio Formal Estruturado |
| **Qwen2.5-Coder (Local Ollama)** | 7B (Q4_K_M) | ✅ Ativo (Porta 11434) | Auditor Sintático Local & Gerador de Código Offline Seguro |
| **SaulLM (GGUF Local)** | v1 Q4_K_M (4.3 GB) | ✅ Baixado no Workspace | Modelo Especialista em Compliance Jurídico e Contratos |
| **PostgreSQL + pgvector (HDW)** | Porta 5432 (Docker) | ✅ Ativo e Operacional | Banco de Dados Relacional e Vetorial para RAG Grounded |
| **Hudson API Backend (HDW)** | Porta 8000 (Docker) | ✅ Ativo e Operacional | Serviços de Custódia, Desbloqueio e Ingestão Documental |
| **LangGraph** | Python Lib (`.venv`) | ✅ Ativo e Operacional | Orquestração de Grafos Cíclicos com Auto-Cura e Checkpoints |
| **Dify** | Low-Code AI Studio | ✅ Ativo e Operacional | Prototipação Visual de Pipelines de IA e RAG Grounded |
| **n8n** | Automação Low-Code | ✅ Ativo e Operacional | Barramento de Webhooks, Integrações e Gatilhos Corporativos |
| **Gitness / Git Harness** | 2.55.0.3 | ✅ Ativo e Operacional | Controle de Versão, Rastreabilidade e GitHub Auto-Sync |

---

## 3. Plugins Absorvidos (Claude & Antigravity)

Os plugins estendem as capacidades do agente com ferramentas MCP, subagentes especializados e fluxos operacionais completos:

1. **`chrome-devtools-plugin`:**
   * Ferramentas de inspeção e automação de navegadores Chrome/DevTools.
   * Análise de acessibilidade (a11y), renderização e otimização LCP/CWV e depuração de memory leaks.
2. **`data-agent-kit-plugin`:**
   * Kit completo de engenharia de dados, BigQuery, Dataform, dbt, Spark, Dataproc, Airflow (Cloud Composer) e Cloud Storage.
3. **`firebase`:**
   * Ferramentas completas de Firebase CLI, Firestore, Auth, Data Connect (PostgreSQL), Cloud Functions, Hosting e subagente `firestore-rules-author`.
4. **`flutter` & `android-cli-plugin`:**
   * Suporte completo para desenvolvimento multiplataforma mobile e desktop, testes unitários, depuração FFI, layout responsivo e subagente `flutter_a11y_agent`.
5. **`gemini-api`:**
   * Desenvolvimento avançado com APIs Gemini, Gemini Live (áudio/vídeo bidirecional com WebSocket) e Gemini Omni Flash.
6. **`google-antigravity-sdk`:**
   * Criação, configuração e orquestração de sistemas multiagentes autônomos no padrão AGY.
7. **`google_maps_platform`:**
   * Arquitetura e integração com serviços geoespaciais, rotas, geocoding e mapas 3D.
8. **`modern-web-guidance-plugin`:**
   * Melhores práticas de front-end moderno, componentes reativos, extensões do Chrome (Manifest V3) e estilos de alta fidelidade.
9. **`science`:**
   * Suite científica avançada com integrações para AlphaFold, ChEMBL, PubMed, Ensembl, UniProt, PDB, NCBI e busca de literatura (ArXiv, BioRxiv, EuropePMC).

---

## 4. Skills Integradas (Workspace & Globais)

### A. Skills de Governança e Engenharia de Software (Workspace `.agents/skills`)
* **`dr-taylor-homeostase`:** Atuação como Regulador de Homeostase Computacional da Daisugi. Garante estabilidade, isolamento (`.venv`/containers), prevenção de alucinação e zero vazamento.
* **`karpathy-guidelines`:** Diretrizes comportamentais para evitar erros comuns de LLM, mantendo alterações cirúrgicas e critérios claros de parada.
* **`surgical-patch`:** Correções no menor nível responsável sem quebrar módulos vizinhos.
* **`verify-and-stop`:** Comprovação executável de não-regressão antes de finalizar tarefas.
* **`lean-build`:** Construção enxuta de novos módulos evitando hiper-complexidade.
* **`caveman`:** Modo conciso de alta densidade técnica com economia extrema de tokens.

### B. Skills Globais de Dados, Cloud e Plataforma (`~/.gemini/config/skills`)
* **`accidental-data-loss-prevention`:** Barreira obrigatória de proteção contra exclusões acidentais ou comandos destrutivos.
* **`managing-python-dependencies`:** Governança estrita do ambiente virtual (`.venv`), proibindo contaminação global.
* **`building-data-apps` & `ml-best-practices`:** Práticas padronizadas de análise de dados, machine learning e interfaces analíticas.
* **`dataform-bigquery`, `dbt-bigquery`, `gcp-dataflow`, `gcp-spark`:** Pipelines de engenharia e transformação de dados em escala.
* **`agy-customizations` & `antigravity-guide`:** Customização e parametrização do ecossistema Google Antigravity IDE.

---

## 5. Ferramentas Desktop e Utilitários de Apoio Corporativo

| Sistema / Aplicativo | Versão | Fabricante | Função |
|---|---|---|---|
| **Docker Desktop** | 29.8.1 | Docker Inc. | Motor de contêineres local (Windows/WSL2) |
| **Python** | 3.11.9 (Local) / 3.11.11 (HDW) | Python Software Foundation | Runtimes de desenvolvimento padronizados |
| **Node.js / npm** | 20.x / 10.x | OpenJS Foundation | Execução de pacotes CLI (Claude Code, linters, ferramentas) |
| **Git** | 2.55.0.3 | Git Community | Versionamento e automação de repositórios |
| **Draw.io** | 31.5.3 | JGraph | Modelagem de arquiteturas e diagramas conceituais |
| **KeePass Password Safe** | 2.60 | Dominik Reichl | Cofre local seguro de credenciais e senhas |
| **Bitdefender Endpoint Security** | 8.26.10.670 | Bitdefender | Proteção de endpoint e isolamento corporativo |
| **Assinador Serpro** | 4.4.0 | Serpro | Assinatura digital de documentos e certidões públicas |
| **Assinador Quick Soft** | 0.9.2 | Quick Soft | Módulo nativo de assinatura corporativa |
| **Google Chrome / Edge** | 154.x | Google / Microsoft | Navegadores e DevTools para validação de front-end |

---

## 6. Matriz de Contingência e Failover

```
+---------------------------------------------------------------------------------------------------------+
|                                      REQUISIÇÃO DE AUDITORIA / CÓDIGO                                   |
+---------------------------------------------------------------------------------------------------------+
                                                     |
                                                     v
                                      +-----------------------------+
                                      |   Possui cotas de nuvem e   |
                                      |    conectividade externa?   |
                                      +-----------------------------+
                                        /                         \
                                 SIM   /                           \  NÃO (Rate-Limit / Offline)
                                      v                             v
                       +-----------------------------+   +------------------------------------+
                       |    CLAUDE CODE (Primário)   |   |     OLLAMA ENGINE (Failover Local) |
                       |  Inspeção estrutural, QA e  |   |  • DeepSeek-R1 (Raciocínio Lógico) |
                       |    conformidade arquitetural|   |  • Qwen2.5-Coder (Sintaxe & Código)|
                       +-----------------------------+   +------------------------------------+
                                      \                             /
                                       \                           /
                                        v                         v
                       +------------------------------------------------------------------+
                       |           VALIDAÇÃO DA HOMEOSTASE (Dr. Taylor Code)             |
                       |       Testes de Não-Regressão, Grounding e Git Auto-Sync        |
                       +------------------------------------------------------------------+
```
