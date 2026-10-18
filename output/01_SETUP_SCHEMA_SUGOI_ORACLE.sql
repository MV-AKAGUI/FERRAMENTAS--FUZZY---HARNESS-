-- ═══════════════════════════════════════════════════════════════════════════
-- SCRIPT: Setup Schema SUGOI no PostgreSQL Oracle (Compartilhado)
-- ═══════════════════════════════════════════════════════════════════════════
-- Database: memoria_vetorial (ou cadeia_valor)
-- Schema: sugoi (NOVO - separado de kigyou_*)
-- Usuario: admin (já existe)
-- Objetivo: Criar estrutura Prisma + tabelas SUGOI_CADEIA_DE_VALOR
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. CRIAR SCHEMA SUGOI
-- ═══════════════════════════════════════════════════════════════════════════
CREATE SCHEMA IF NOT EXISTS sugoi;

-- 2. VERIFICAR EXTENSÕES NECESSÁRIAS
-- ═══════════════════════════════════════════════════════════════════════════
-- pgvector já deve estar ativa (instalada por Kigyou)
-- Se não estiver, descomente:
-- CREATE EXTENSION IF NOT EXISTS vector SCHEMA public;

-- 3. CRIAR TABELAS COMPARTILHADAS (public schema)
-- ═══════════════════════════════════════════════════════════════════════════
-- Essas já devem existir do Kigyou, mas criamos com IF NOT EXISTS para segurança

CREATE TABLE IF NOT EXISTS public.setor (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(2) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE public.setor IS 'Setores IMUTÁVEIS (14 total) - Compartilhado Kigyou + SUGOI';

CREATE TABLE IF NOT EXISTS public.cadeira (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(10) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  alcada_nivel INT NOT NULL,
  setor_id INT NOT NULL REFERENCES public.setor(id),
  modulo VARCHAR(50),
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE public.cadeira IS 'Cadeiras (Kigyou + SUGOI) - Compartilhado';

CREATE TABLE IF NOT EXISTS public.pessoa_cadeira (
  id SERIAL PRIMARY KEY,
  cpf VARCHAR(11) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  cadeira_id INT REFERENCES public.cadeira(id),
  setor_id INT REFERENCES public.setor(id),
  modulo VARCHAR(50),
  data_inicio TIMESTAMP DEFAULT NOW(),
  data_fim TIMESTAMP,
  ativo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE public.pessoa_cadeira IS 'Pessoas + Cadeiras - Compartilhado (Kigyou + SUGOI)';

CREATE TABLE IF NOT EXISTS public.login_audit (
  id BIGSERIAL PRIMARY KEY,
  cpf VARCHAR(11) NOT NULL REFERENCES public.pessoa_cadeira(cpf),
  timestamp TIMESTAMP DEFAULT NOW(),
  ip_address VARCHAR(50),
  resultado VARCHAR(20),
  modulo VARCHAR(50)
);
COMMENT ON TABLE public.login_audit IS 'Auditoria centralizada de logins';

CREATE TABLE IF NOT EXISTS public.sod_violation_log (
  id BIGSERIAL PRIMARY KEY,
  cpf_executor VARCHAR(11) NOT NULL REFERENCES public.pessoa_cadeira(cpf),
  acao VARCHAR(255),
  modulo VARCHAR(50),
  violacao_tipo VARCHAR(100),
  processo_id INT,
  timestamp TIMESTAMP DEFAULT NOW(),
  bloqueado BOOLEAN DEFAULT TRUE
);
COMMENT ON TABLE public.sod_violation_log IS 'Log de violações SoD - Compartilhado (20 regras)';

-- 4. CRIAR TABELAS SUGOI (schema: sugoi)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS sugoi.processo_bpm (
  id SERIAL PRIMARY KEY,
  setor_id INT NOT NULL REFERENCES public.setor(id),
  nome VARCHAR(255) NOT NULL,
  descricao TEXT,
  status VARCHAR(30) DEFAULT 'RASCUNHO',
  criado_por_cpf VARCHAR(11) NOT NULL REFERENCES public.pessoa_cadeira(cpf),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  embedding vector(1536),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.processo_bpm IS 'Processos BPM - Núcleo de SUGOI_CADEIA_DE_VALOR';
CREATE INDEX idx_processo_bpm_setor ON sugoi.processo_bpm(setor_id);
CREATE INDEX idx_processo_bpm_status ON sugoi.processo_bpm(status);
CREATE INDEX idx_processo_bpm_criado_por ON sugoi.processo_bpm(criado_por_cpf);

CREATE TABLE IF NOT EXISTS sugoi.no_bpm (
  id SERIAL PRIMARY KEY,
  processo_id INT NOT NULL REFERENCES sugoi.processo_bpm(id) ON DELETE CASCADE,
  nome VARCHAR(255) NOT NULL,
  tipo VARCHAR(30),
  descricao TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.no_bpm IS 'Nós do diagrama BPM (INICIO, ATIVIDADE, DECISAO, FIM)';
CREATE INDEX idx_no_bpm_processo ON sugoi.no_bpm(processo_id);

CREATE TABLE IF NOT EXISTS sugoi.aresta_bpm (
  id SERIAL PRIMARY KEY,
  processo_id INT NOT NULL REFERENCES sugoi.processo_bpm(id) ON DELETE CASCADE,
  no_origem_id INT NOT NULL,
  no_destino_id INT NOT NULL,
  label VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.aresta_bpm IS 'Arestas (conexões) entre nós do BPM';
CREATE INDEX idx_aresta_bpm_processo ON sugoi.aresta_bpm(processo_id);

CREATE TABLE IF NOT EXISTS sugoi.definicao_raci_documento (
  id SERIAL PRIMARY KEY,
  cpf_pessoa VARCHAR(11) NOT NULL REFERENCES public.pessoa_cadeira(cpf),
  processo_id INT NOT NULL REFERENCES sugoi.processo_bpm(id),
  papel_raci VARCHAR(20),
  data_designacao TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.definicao_raci_documento IS 'Matriz RACI (Responsável, Accountable, Consultado, Informado)';
CREATE INDEX idx_raci_pessoa ON sugoi.definicao_raci_documento(cpf_pessoa);
CREATE INDEX idx_raci_processo ON sugoi.definicao_raci_documento(processo_id);

CREATE TABLE IF NOT EXISTS sugoi.analisador_documento (
  id SERIAL PRIMARY KEY,
  validacao VARCHAR(100),
  modelo VARCHAR(100),
  confianca INT,
  timestamp TIMESTAMP DEFAULT NOW(),
  log_id VARCHAR(255) UNIQUE,
  resultado TEXT,
  tempo_ms INT,
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.analisador_documento IS 'Logs de validação (BPM, HAP, EAP, SoD, RapidFuzz, etc)';
CREATE INDEX idx_analisador_validacao ON sugoi.analisador_documento(validacao);
CREATE INDEX idx_analisador_confianca ON sugoi.analisador_documento(confianca);

CREATE TABLE IF NOT EXISTS sugoi.log_auditoria (
  id SERIAL PRIMARY KEY,
  cpf_executor VARCHAR(11) NOT NULL REFERENCES public.pessoa_cadeira(cpf),
  acao VARCHAR(255),
  documento_id INT,
  resultado VARCHAR(100),
  timestamp TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.log_auditoria IS 'Auditoria de ações (append-only)';
CREATE INDEX idx_auditoria_executor ON sugoi.log_auditoria(cpf_executor);
CREATE INDEX idx_auditoria_timestamp ON sugoi.log_auditoria(timestamp);

CREATE TABLE IF NOT EXISTS sugoi.processo_embedding (
  id SERIAL PRIMARY KEY,
  processo_id INT NOT NULL REFERENCES sugoi.processo_bpm(id) ON DELETE CASCADE,
  embedding vector(1536),
  fonte VARCHAR(100),
  timestamp TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.processo_embedding IS 'Embeddings para RAG (busca semântica)';
CREATE INDEX idx_embedding_processo ON sugoi.processo_embedding(processo_id);
CREATE INDEX idx_embedding_vetor ON sugoi.processo_embedding USING ivfflat (embedding vector_cosine_ops);

CREATE TABLE IF NOT EXISTS sugoi.assinatura_digital (
  id SERIAL PRIMARY KEY,
  processo_id INT NOT NULL REFERENCES sugoi.processo_bpm(id),
  cpf_signatario VARCHAR(11) NOT NULL REFERENCES public.pessoa_cadeira(cpf),
  hash_documento VARCHAR(256),
  timestamp_assinatura TIMESTAMP,
  de_acordo BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE sugoi.assinatura_digital IS 'Assinatura digital e fé pública (MP 2.200-2/2001)';
CREATE INDEX idx_assinatura_processo ON sugoi.assinatura_digital(processo_id);

-- 5. PERMISSÕES (Usuário SUGOI pode ler schemas compartilhados)
-- ═══════════════════════════════════════════════════════════════════════════
-- (Opcional: criar usuário sugoi_app separado)
-- CREATE USER sugoi_app WITH PASSWORD 'sugoi_password_forte';
-- GRANT CONNECT ON DATABASE memoria_vetorial TO sugoi_app;
-- GRANT USAGE ON SCHEMA sugoi TO sugoi_app;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sugoi TO sugoi_app;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sugoi TO sugoi_app;
-- GRANT USAGE ON SCHEMA public TO sugoi_app;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO sugoi_app;

-- 6. SEED DATA INICIAL (14 Setores - PAM SUGOI)
-- ═══════════════════════════════════════════════════════════════════════════
INSERT INTO public.setor (codigo, nome, ativo) VALUES
  ('01', 'Presidência', TRUE),
  ('02', 'Gente, cultura e gestão', TRUE),
  ('03', 'Operações', TRUE),
  ('04', 'Planejamento financeiro', TRUE),
  ('05', 'Controladoria', TRUE),
  ('06', 'Administrativo financeiro', TRUE),
  ('07', 'Jurídico empresarial', TRUE),
  ('08', 'QSMS', TRUE),
  ('09', 'Land bank e novos negócios', TRUE),
  ('10', 'Jurídico imobiliário', TRUE),
  ('11', 'Incorporação', TRUE),
  ('12', 'Engenharia', TRUE),
  ('13', 'Suprimentos', TRUE),
  ('14', 'CRM', TRUE)
ON CONFLICT DO NOTHING;

-- 7. VERIFICAÇÃO FINAL
-- ═══════════════════════════════════════════════════════════════════════════
SELECT
  schemaname,
  COUNT(*) as tabelas_criadas
FROM pg_tables
WHERE schemaname IN ('sugoi', 'public')
GROUP BY schemaname;

SELECT COUNT(*) as setores_cadastrados FROM public.setor WHERE ativo = TRUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- FIM DO SCRIPT
-- Próximo passo: Executar Prisma migrate (npx prisma migrate deploy --prod)
-- ═══════════════════════════════════════════════════════════════════════════
