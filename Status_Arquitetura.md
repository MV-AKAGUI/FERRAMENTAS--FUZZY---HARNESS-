# Inventário da Arquitetura "Arquiteto Neural"
*Filosofia: Homeostase Computacional (Privacidade e Processamento Local)*

Abaixo está o mapeamento de todos os componentes da nossa infraestrutura. Tudo está instalado, mas o nível de comunicação (integração) entre eles varia, conforme detalhado na coluna de status.

## 1. Cérebros e Modelos de IA (Ollama)
* **Onde roda:** Instalado nativamente no Windows (Ollama).
* **Status:** 🟢 Instalado, rodando e pronto para receber requisições.
* **Componentes:**
  - `Llama 3.1` (Generalista / Roteador)
  - `SaulLM` (Especialista Jurídico)
  - `Qwen 2.5` (Matemático / Financeiro / Controladoria)
  - `Mistral-Nemo` (Investigador)
  - `Nomic-Embed-Text` (Gerador de Embeddings para RAG)
* **Comunicação:** Ainda aguardando o LangGraph conectar a Interface do Usuário a eles.

## 2. Banco de Dados e Memória (PostgreSQL + pgvector)
* **Onde roda:** Contêiner Docker (`cerebro_pgvector` na porta 5432).
* **Status:** 🟢 Instalado e rodando.
* **Comunicação:** Isolado no momento. Aguardando integração com o LlamaIndex para injetar os documentos locais (PDFs e arquivos).

## 3. Microserviços e Ferramentas (Docker)
* **Onde roda:** Contêineres isolados via `docker-compose-ferramentas.yml`.
* **Status:** 🟢 Todos instalados e rodando.
* **Componentes:**
  - `PaddleOCR API` (Porta 8000): O "Leitor" de Notas Fiscais e PDFs pesados.
  - `SearXNG` (Porta 8080): O Buscador privado na Web.
  - `n8n` (Porta 5678): Automação de fluxos e webhooks.
* **Comunicação:** Rodando de forma independente. O n8n e a Interface precisarão ser ensinados a mandar requisições para a porta do OCR e do SearXNG.

## 4. Engenharia de Software e CI/CD (Harness Gitness)
* **Onde roda:** Contêiner Docker (`harness_gitness` na porta 3000).
* **Status:** 🟢 Instalado, rodando, e conta de Administrador criada.
* **Comunicação:** O Gitness já gerencia os próprios arquivos internos. Futuramente as automações do n8n e os códigos gerados pelas IAs podem fazer commits diretos nele.

## 5. Interface do Usuário (Streamlit)
* **Onde roda:** Ambiente Virtual Python (`.venv` via `app_chat_st.py` na porta 8001).
* **Status:** 🟢 Instalada e rodando na tela do usuário.
* **Comunicação:** É atualmente uma "casca". Exibe mensagens visuais, mas ainda não se comunica com o backend.

## 6. Orquestração e Roteamento (LangChain / LangGraph)
* **Onde roda:** Bibliotecas instaladas no `.venv`.
* **Status:** 🟡 Bibliotecas instaladas, mas o código não foi escrito.
* **Comunicação:** Esta é a "Cola" do sistema. É o LangGraph que fará a Interface (Item 5) conversar com os Cérebros (Item 1) e com o Banco de Dados (Item 2).

---

### Resumo das Integrações Atuais
- **Instalado e Rodando:** 100% das ferramentas e infraestrutura.
- **Se comunicando de forma autônoma:** 0% (A infraestrutura subiu isolada propositalmente por segurança).
- **Próximo Passo Crítico:** Escrever o código do Orquestrador (LangGraph) para ligar os "fios" entre a Interface, os Modelos (Ollama) e as Ferramentas.
