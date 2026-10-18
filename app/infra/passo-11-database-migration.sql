-- ═══════════════════════════════════════════════════════════════════════════════
-- PASSO 11: DATABASE MIGRATION & SCHEMA DEFINITION (SUGOI_*)
-- 8 Tabelas Principais + Índices de Alta Performance + Suporte pgvector
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- 1. Tabela de Setores PAM (14 Setores Organizacionais)
CREATE TABLE IF NOT EXISTS sugoi_setores_pam (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    ordem_hierarquica INT NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Pessoas e Cadeiras (Maker / Checker)
CREATE TABLE IF NOT EXISTS sugoi_pessoas_cadeiras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(150) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    setor_id INT REFERENCES sugoi_setores_pam(id),
    pode_aprovar_diretoria BOOLEAN DEFAULT FALSE,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela de Processos BPM
CREATE TABLE IF NOT EXISTS sugoi_processos_bpm (
    id VARCHAR(50) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    status VARCHAR(30) DEFAULT 'rascunho',
    graph_json JSONB NOT NULL,
    hash_sha256 VARCHAR(64),
    created_by VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabela de Nós e Tarefas do Grafo
CREATE TABLE IF NOT EXISTS sugoi_processos_nos (
    id VARCHAR(50) PRIMARY KEY,
    processo_id VARCHAR(50) REFERENCES sugoi_processos_bpm(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL,
    rotulo VARCHAR(255) NOT NULL,
    setor_id INT REFERENCES sugoi_setores_pam(id),
    ordem_execucao INT DEFAULT 0
);

-- 5. Tabela de Transições e Arestas do Grafo
CREATE TABLE IF NOT EXISTS sugoi_processos_arestas (
    id SERIAL PRIMARY KEY,
    processo_id VARCHAR(50) REFERENCES sugoi_processos_bpm(id) ON DELETE CASCADE,
    origem_no_id VARCHAR(50) NOT NULL,
    destino_no_id VARCHAR(50) NOT NULL
);

-- 6. Tabela de Resultados de Auditoria (10 Travões)
CREATE TABLE IF NOT EXISTS sugoi_auditoria_travoes (
    id SERIAL PRIMARY KEY,
    processo_id VARCHAR(50) REFERENCES sugoi_processos_bpm(id) ON DELETE CASCADE,
    score_conformidade NUMERIC(5,2) NOT NULL,
    passou_todos BOOLEAN NOT NULL,
    detalhes_json JSONB NOT NULL,
    executado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Tabela de Assinaturas e Trilhas de Auditoria (Lei 14.063)
CREATE TABLE IF NOT EXISTS sugoi_assinaturas_digitais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    processo_id VARCHAR(50) REFERENCES sugoi_processos_bpm(id) ON DELETE CASCADE,
    signer_id VARCHAR(50) NOT NULL,
    hash_original VARCHAR(64) NOT NULL,
    hash_assinatura VARCHAR(64) NOT NULL,
    timestamp_assinatura TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    conformidade_lei VARCHAR(100) DEFAULT 'Lei 14.063/2020',
    ip_origem VARCHAR(45)
);

-- 8. Tabela de Vetores de Conhecimento RAG
CREATE TABLE IF NOT EXISTS sugoi_rag_embeddings (
    id SERIAL PRIMARY KEY,
    processo_id VARCHAR(50) REFERENCES sugoi_processos_bpm(id) ON DELETE CASCADE,
    conteudo_chunk TEXT NOT NULL,
    embedding vector(768),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices Estratégicos
CREATE INDEX IF NOT EXISTS idx_proc_status ON sugoi_processos_bpm(status);
CREATE INDEX IF NOT EXISTS idx_proc_created_by ON sugoi_processos_bpm(created_by);
CREATE INDEX IF NOT EXISTS idx_assinaturas_processo ON sugoi_assinaturas_digitais(processo_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_processo ON sugoi_auditoria_travoes(processo_id);
