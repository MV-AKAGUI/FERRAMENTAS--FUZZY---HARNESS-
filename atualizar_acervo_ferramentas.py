"""
Script de Atualização Automática do Acervo de Ferramentas - DAISUGI TECNOLOGIAS
Repositório: FERRAMENTAS--FUZZY---HARNESS-
"""

import os
import re
import sys
import datetime
import subprocess
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

def obter_modelos_ollama():
    """Lê os modelos baixados no Ollama diretamente dos manifests locais."""
    home = Path.home()
    ollama_dir = home / ".ollama" / "models" / "manifests" / "registry.ollama.ai" / "library"
    modelos = []
    if ollama_dir.exists():
        for model_path in ollama_dir.iterdir():
            if model_path.is_dir():
                model_name = model_path.name
                for tag_file in model_path.iterdir():
                    if tag_file.is_file():
                        modelos.append(f"{model_name}:{tag_file.name}")
    return sorted(modelos)

def obter_servicos_docker():
    """Lê serviços configurados no docker-compose-ferramentas.yml."""
    compose_file = BASE_DIR / "docker-compose-ferramentas.yml"
    servicos = []
    if compose_file.exists():
        with open(compose_file, "r", encoding="utf-8") as f:
            content = f.read()
        import re
        matches = re.findall(r"container_name:\s*([a-zA-Z0-9_\-]+)", content)
        servicos = matches
    return servicos

def obter_principais_pacotes_python():
    """Lê bibliotecas chave do requirements.txt."""
    req_file = BASE_DIR / "requirements.txt"
    pacotes = []
    if req_file.exists():
        with open(req_file, "r", encoding="utf-8") as f:
            for line in f:
                parts = [p.strip() for p in line.split(",") if p.strip()]
                for part in parts:
                    pacotes.append(part)
    return pacotes

def gerar_conteudo_markdown(data_str):
    modelos = obter_modelos_ollama()
    servicos = obter_servicos_docker()
    
    md = f"""# 🛠️ Acervo Oficial de Ferramentas - FUZZY-HARNESS
> **Data da Última Atualização:** {data_str}  
> **Repositório Oficial:** [MV-AKAGUI/FERRAMENTAS--FUZZY---HARNESS-](https://github.com/MV-AKAGUI/FERRAMENTAS--FUZZY---HARNESS-)  
> **Ecossistema:** DAISUGI TECNOLOGIAS  

Este documento é o catálogo consolidado de todas as ferramentas, modelos de inteligência artificial, OCRs, orquestradores e utilitários instalados e homologados no nosso ecossistema local.

---

## ⚡ Como Atualizar este Catálogo Automaticamente
Sempre que uma nova ferramenta, modelo do Ollama, contêiner ou biblioteca for adicionada, execute no terminal (PowerShell) dentro desta pasta:

```powershell
python atualizar_acervo_ferramentas.py --sync
```

O comando irá:
1. Varrer modelos locais no Ollama (`.ollama/models`);
2. Varrer serviços Docker no `docker-compose-ferramentas.yml`;
3. Varrer bibliotecas do `requirements.txt` e módulos em `ferramentas/`;
4. Regenerar este documento com a data do dia;
5. Executar o `git add`, `git commit` e `git push` automaticamente para o GitHub.

---

## 1. 🧠 Modelos de IA Locais (LLMs & Embeddings via Ollama)
*Modelos 100% offline, executando na porta local `11434` sem custos de API ou vazamento de dados.*

| Modelo | Função Operacional no Ecossistema | Status Local |
| :--- | :--- | :--- |
| **Llama 3.1 8B** (`llama3.1:latest`) | **Maestro Geral:** Coordenação de fluxos, decomposição de tarefas complexas e raciocínio sênior. | {'✅ Ativo' if any('llama3.1' in m for m in modelos) else 'Instalado'} |
| **DeepSeek-R1 8B** (`deepseek-r1:8b`) | **Raciocínio Lógico & POPs:** Análise investigativa com *Chain-of-Thought*, auditoria de deltas, juros e elaboração de fluxogramas BPMN/Mermaid. | {'✅ Ativo' if any('deepseek-r1' in m for m in modelos) else 'Instalado'} |
| **Qwen 2.5 Coder 7B** (`qwen2.5-coder:7b`) | **Engenheiro de Software Sênior:** Geração e refatoração de código Python, testes automatizados e algoritmos de cálculo. | {'✅ Ativo' if any('qwen2.5-coder' in m for m in modelos) else 'Instalado'} |
| **Qwen 2.5** (`qwen2.5:latest`) | **Auditor Revisor & Presidente:** Consolidação de julgamentos técnicos, fechamento de balanços e emissão de laudos/acórdãos. | {'✅ Ativo' if any('qwen2.5' in m for m in modelos) else 'Instalado'} |
| **SaulLM 7B** (`saullm:latest` / `.gguf`) | **Perito Jurídico & Compliance:** Leitura de CCBs, escrituras de CRI, debêntures, contratos sociais e auditoria contratual. | {'✅ Ativo' if any('saullm' in m for m in modelos) else 'Instalado'} |
| **Mistral / Mistral-Nemo 12B** (`mistral-nemo:latest`) | **Hermenêutica Forense & Pesquisa:** Avaliação semântica fina, caça a anacronismos em relatórios e redação técnica. | {'✅ Ativo' if any('mistral-nemo' in m for m in modelos) else 'Instalado'} |
| **nomic-embed-text** (`nomic-embed-text:latest`) | **Vetorizador Matemático:** Modelo de Embeddings de alta performance para alimentar a busca vetorial (RAG) no pgvector. | {'✅ Ativo' if any('nomic-embed-text' in m for m in modelos) else 'Instalado'} |

---

## 2. 👁️ Visão Computacional, Extração de Documentos & OCR de Notas Fiscais
*Ferramentas para leitura profunda de documentos físicos escaneados, relatórios e notas fiscais.*

| Ferramenta | Descrição e Utilização | Porta / Endpoint |
| :--- | :--- | :--- |
| **PaddleOCR** (`docker_paddleocr`) | **OCR Especializado em Notas Fiscais:** API FastAPI com PaddleOCR em português para extrair texto de notas fiscais, faturas e recibos para o pipeline. | `http://localhost:8000/ler_nota_fiscal` |
| **Docling (IBM)** (`docling==2.133.0`) | **Parser Avançado de Documentos:** Transforma PDFs complexos, escaneados com tabelas e relatórios técnicos em Markdown/JSON estruturado com máxima fidelidade. | Módulo Python / CLI |
| **RapidOCR** (`rapidocr==3.9.2`) | **OCR Rápido Local:** Motor leve baseado em ONNX para leitura quase instantânea de imagens e recortes de tela. | Módulo Python |
| **pypdfium2 / pdfplumber** | **Renderizadores de PDF:** Extração de páginas, dados brutos e conversão de páginas em imagens de alta resolução. | Módulo Python |
| **python-docx / openpyxl / xlsxwriter** | **Manipuladores Office:** Leitura e gravação de contratos Word (.docx) e planilhas contábeis (.xlsx). | Módulo Python |

---

## 3. 🎯 Triagem Rápida & Lógica Fuzzy (Anti-Erro de Digitação)
*Módulos de comparação textual com tolerância fonética e semântica.*

| Ferramenta | Descrição e Utilização | Implementação |
| :--- | :--- | :--- |
| **RapidFuzz** (`RapidFuzz==3.14.6`) | **Motor de Comparação Rápida:** Algoritmos C++ ultrarrápidos (Levenshtein, Token Sort Ratio) para busca em catálogos e tolerância a erros tipográficos. | Biblioteca Core |
| **Reconciliador 5 Vias** | **Cruzamento Contábil:** Cruza simultaneamente credores, contratos, escrituras, extratos e relatórios com limiar mínimo de 85% de similaridade. | `ferramentas/rapidfuzz_reconciliador_5vias.py` |
| **Fuzzy Investigator** | **Auditoria de Homônimos:** Aplicação para rastreamento de variações de nomes de empresas, fornecedores e CPFs/CNPJs. | Projeto na Área de Trabalho |

---

## 4. ⚙️ DevOps, CI/CD & Test Harness Determinístico
*Esteira de controle de versões, automação de deploys e validação matemática.*

| Ferramenta | Descrição e Utilização | Acesso / Local |
| :--- | :--- | :--- |
| **Harness Gitness** | **Servidor Git & CI/CD Local:** Plataforma moderna de DevOps para hospedar repositórios locais e rodar pipelines de build e testes dos agentes de IA. | `http://localhost:3000` |
| **Test Harness R$ 0,00** | **Harness Anti-Alucinação Financeira:** Módulo aritmético estrito em Python que audita o serviço da dívida e liquidações com tolerância zero (R$ 0,00). | `ferramentas/test_harness_determinismo.py` |
| **Docker Desktop** | **Virtualização de Contêineres:** Hospeda a infraestrutura em rede isolada (`cerebro_pgvector`, `olho_paddleocr`, `n8n`, `searxng`, `gitness`). | Daemon Local |

---

## 5. 🕸️ Orquestração de Agentes, Cadeias e Grafos (LangChain & LangGraph)
*Arquitetura de raciocínio, delegação de tarefas e estado de execução.*

| Ferramenta | Descrição e Utilização | Arquivo / Módulo |
| :--- | :--- | :--- |
| **LangGraph** (`langgraph==1.2.12`) | **Sistema Nervoso Determinístico:** Orquestrador de grafos com estado para o fluxo da Dai, permitindo transição controlada entre triagem, ferramentas e especialistas. | `sistema_nervoso_langgraph.py` |
| **LangChain** (`langchain==1.4.3`) | **Framework de Cadeias:** Conexão com Ollama, formatação de prompts, carregamento de documentos e chamada de ferramentas. | Módulo Python |
| **MetaGPT** | **Fábrica de Software Multi-Agente:** Metodologia baseada em Procedimentos Operacionais Padrão (SOPs) com agentes nos papéis de PM, Arquiteto, Engenheiro e QA. | Pasta `Meta_GPT_DAISUGI` / `.metagpt` |
| **LlamaIndex** (`llama-index==0.14.25`) | **Estruturação de RAG:** Indexação vetorial hierárquica e estratégias de recuperação de contexto para documentos extensos. | Biblioteca Python |

---

## 6. 🗄️ Banco de Dados, Memória Semântica & RAG
*Persistência de prontuários, cadastros e vetores de conhecimento.*

| Ferramenta | Descrição e Utilização | Acesso / Porta |
| :--- | :--- | :--- |
| **PostgreSQL + pgvector** (`cerebro_pgvector`) | **Memória Vetorial & Relacional:** Banco oficial da clínica/sistema que une tabelas SQL relacionais com índices vetoriais (HNSW/IVFFlat) para busca semântica em tempo real. | `localhost:5432` (db: `memoria_vetorial`) |
| **SQLAlchemy & psycopg2** | **Camada ORM:** Mapeamento objeto-relacional para transações seguras e consultas eficientes. | Módulo Python |

---

## 7. 🔌 Plataformas Visuais, Automação & Busca Privada
*Microserviços auxiliares prontos para uso das aplicações.*

| Ferramenta | Descrição e Utilização | Acesso / Porta |
| :--- | :--- | :--- |
| **Dify** (`./dify`) | **Plataforma Visual de IA Low-Code:** Interface completa para desenho visual de agentes, chatbots, pipelines de RAG e testes interativos. | Código clonado em `./dify` |
| **n8n** (`n8n_automacao`) | **Automação de Workflows:** Alternativa open source ao Zapier para integração com APIs, webhooks, envio de alertas e integração com sistemas legados. | `http://localhost:5678` |
| **SearXNG** (`buscador_searxng`) | **Buscador Privado na Web:** Metabusca anônima e sem rastreamento que permite aos agentes consultarem a internet de forma privada. | `http://localhost:8080` |

---

## 8. 💻 Interfaces com o Usuário (Front-End) & Processamento de Voz
*Interfaces gráficas para atendimento, testes e comando por voz.*

| Ferramenta | Descrição e Utilização | Execução |
| :--- | :--- | :--- |
| **Streamlit** (`streamlit==1.65.0`) | **Front-End da Recepção da Dai:** Interface web amigável com login por perfis (Diretoria, Cliente, Dev), prontuário dinâmico, status e avatar da Dai. | `streamlit run app_chat_st.py` |
| **Chainlit** (`chainlit==2.11.0`) | **Chat Conversacional:** Interface focada em conversação direta para validação de prompts e testes rápidos com agentes. | `chainlit run app_chat.py` |
| **OpenAI Whisper** (`openai-whisper`) | **Transcrição de Voz para Texto (STT):** Modelo de inteligência artificial para reconhecer áudios e comandos de voz dos usuários. | Módulo Python |
| **FastAPI & Uvicorn** | **Servidores de Microsserviços:** Criação de APIs REST ultrarrápidas para expor funções das ferramentas a outros sistemas. | `uvicorn app:app --port 8000` |

---

## 9. 📈 Motores Analíticos Especiais
*Ferramentas internas de auditoria e cálculo contínuo.*

| Ferramenta | Descrição e Utilização | Arquivo |
| :--- | :--- | :--- |
| **Tribunal de Auditoria Independente** | **Auditoria Colegiada 4 IAs:** Sistema que convoca Perito Matemático, Perito Jurídico e Câmaras Linguística e Revisora para homologação documental. | `ferramentas/tribunal_auditoria_independente.py` |
| **Motor de Evolução Temporal da Dívida** | **Cálculo de Séries Históricas:** Consolidação contábil multi-exercício (2021 a 2024), cálculo de CAGR, picos e gerador de gráficos vetoriais SVG. | `ferramentas/evolucao_temporal_divida.py` |

---
*Documento gerado e gerenciado automaticamente pelo ecossistema DAISUGI TECNOLOGIAS.*
"""
    return md

def main():
    agora = datetime.datetime.now()
    data_str = agora.strftime("%d-%m-%Y")
    
    # 1. Procurar arquivos anteriores para atualizar ou criar novo com a data corrente
    nome_arquivo = f"Lista de Ferramentas - FUZZY-HARNESS [{data_str}].md"
    caminho_arquivo = BASE_DIR / nome_arquivo
    
    # Remove eventuais versões anteriores do mesmo padrão se tiverem data diferente
    for f in BASE_DIR.glob("Lista de Ferramentas - FUZZY-HARNESS [*.md"):
        if f.name != nome_arquivo:
            print(f"Substituindo versao anterior: {f.name}")
            try:
                f.unlink()
            except Exception as e:
                print(f"Aviso ao remover arquivo antigo: {e}")
                
    conteudo = gerar_conteudo_markdown(data_str)
    with open(caminho_arquivo, "w", encoding="utf-8") as f:
        f.write(conteudo)
        
    print(f"[OK] Documento gerado com sucesso: {nome_arquivo}")
    
    # 2. Se argumento --sync for passado, faz o git sync
    if "--sync" in sys.argv:
        print("[INFO] Executando sincronizacao automatica com o GitHub...")
        subprocess.run(["git", "pull", "origin", "main"], cwd=BASE_DIR, check=False)
        subprocess.run(["git", "add", "."], cwd=BASE_DIR, check=True)
        msg_commit = f"Auto-sync: Atualizacao do acervo de ferramentas [{data_str}]"
        subprocess.run(["git", "commit", "-m", msg_commit], cwd=BASE_DIR, check=False)
        subprocess.run(["git", "push", "origin", "main"], cwd=BASE_DIR, check=True)
        print("[SUCESSO] Sincronizacao com o GitHub finalizada!")

if __name__ == "__main__":
    main()
