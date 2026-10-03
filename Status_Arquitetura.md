# Status Oficial: Projeto Arquiteto Neural (Ferramentas, Fuzzy & Harness)
*Documento vivo atualizado com a Filosofia de Homeostase Computacional (Privacidade e Processamento Local)*

Este documento detalha o estágio atual de todas as aplicações e conceitos abordados no nosso roadmap, listando o que está rodando, o que está isolado e o que falta conectar.

---

## 1. 🧠 Inteligência Artificial (Os "Doutores" e o Roteador)
* **Ferramenta:** Ollama (Servidor Local de LLMs).
* **Status de Instalação:** 🟢 100% Instalado e Funcional nos bastidores.
* **Comunicação:** 🔴 "Mudos" na interface. Aguardando a fiação do LangGraph.
* **Componentes Baixados:**
  - **Llama 3.1:** O Cérebro Generalista e "Maestro" do roteamento.
  - **SaulLM (O Dr. Jurídico):** Especialista em leis, contratos e jargões do direito.
  - **Qwen 2.5 (O Especialista Financeiro):** Analista de balanços, DREs, FP&A e números empresariais.
  - **Mistral-Nemo (O Investigador):** Visão sistêmica, faro investigativo e cruzamento de informações.
  - **Nomic-Embed-Text:** O tradutor silencioso que gera embeddings vetoriais.
* **O que falta:** Criar a regra (o script Python) que permite que eles recebam as mensagens digitadas pelo usuário no chat.

## 2. 🎨 Interface de Comunicação (O Rosto)
* **Ferramenta:** Streamlit (Arquivo `app_chat_st.py` na porta 8001).
* **Status de Instalação:** 🟢 100% Instalado e Rodando.
* **Comunicação:** 🔴 "Casca Vazia". O campo de texto existe, mas não processa a mensagem ainda.
* **O que falta:** Vincular o botão de "Enviar" com o roteador (LangGraph).

## 3. 🔀 Orquestração e Roteamento Lógico (O Sistema Nervoso)
* **Ferramentas:** LangChain e LangGraph (Bibliotecas Python no `.venv`).
* **Status de Instalação:** 🟡 Bibliotecas instaladas.
* **Comunicação:** 🔴 Código não escrito.
* **O que falta:** Esta é a peça central que devemos construir agora. Precisamos escrever as regras do LangGraph para que ele intercepte a mensagem do Streamlit e decida: *"É sobre finanças? Envie para o Qwen. É sobre processo? Envie para o Dr. Saul."*

## 4. 🗄️ Memória de Longo Prazo e RAG (O Cofre de Arquivos)
* **Ferramentas:** PostgreSQL + extensão `pgvector` (via Docker na porta 5432).
* **Status de Instalação:** 🟢 100% Instalado e Rodando.
* **Comunicação:** 🔴 Banco vazio e isolado.
* **Ferramentas de Ingestão (LlamaIndex e Docling):** Instaladas no `.venv`.
* **O que falta:** Escrever o script que pega seus PDFs locais, usa o *Docling* para ler o texto (mesmo tabelas complexas), transforma em vetores com o *Nomic* e salva dentro do *Postgres*.

## 5. 🛠️ Microserviços de Extração e Integração (Os "Braços e Olhos")
*Todos rodando de forma isolada em contêineres Docker, respeitando a Homeostase Computacional.*
* **PaddleOCR (A porta 8000):** O nosso "Olho" para extrair textos de Notas Fiscais e imagens escaneadas. 🟢 Instalado.
* **SearXNG (A porta 8080):** O "Buscador Anônimo". Permite pesquisar na internet sem vazar dados. 🟢 Instalado.
* **n8n (A porta 5678):** A nossa "Secretária de Automação", para integrar com e-mails, webhooks, etc. 🟢 Instalado.
* **Busca Fuzzy (Fuzzy Matching):** 🟡 Conceito mapeado para ser usado em cruzamento de dados investigativos. Faltam bibliotecas específicas de Python (como `thefuzz` ou `rapidfuzz`) que precisaremos baixar quando o Investigador (Mistral-Nemo) for ativado.

## 6. 🏭 Engenharia de Software e CI/CD (O Gerente da Fábrica)
* **Ferramenta:** Harness Open Source / Gitness (via Docker na porta 3000).
* **Status de Instalação:** 🟢 100% Instalado. Você já criou a conta de Administrador.
* **Comunicação:** 🟡 Operando como "Cofre" independente no momento.
* **O que falta:** Futuramente, integraremos o Harness aos Agentes (ex: MetaGPT), permitindo que a IA escreva códigos, submeta ao Harness para testes automáticos, e faça atualizações de sistema sozinhas.

---

## 🎯 Conclusão e Ordem de Ação
Toda a nossa infraestrutura e maquinário de "Hardware simulado" (Docker, Bancos, Modelos, UI) foi **montada com sucesso e está operante**.

**As próximas tarefas lógicas (o que falta vincular/baixar):**
1. **(Ação Imediata)** Escrever a lógica do LangGraph no arquivo do Streamlit para o "Dr. Saul" e o "Qwen" ganharem voz no chat.
2. Escrever o script de injeção RAG para popular o Banco de Dados (Postgres) com seus arquivos.
3. Baixar bibliotecas de busca *Fuzzy* (`pip install rapidfuzz`) para refinar as investigações de dados do Mistral-Nemo.
