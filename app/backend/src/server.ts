import express from "express";
import cors from "cors";
import path from "path";
import { ProcessoService } from "./services/ProcessoService";
import { TravaoService } from "./services/TravaoService";
import { AprovacaoService } from "./services/AprovacaoService";
import { OllamaService } from "./services/OllamaService";

const app = express();
app.use(cors());
app.use(express.json());

// 1. Raiz & Health check
app.get("/", (req, res) => {
  res.json({ message: "SUGOI Cadeia de Valor API ativa", status: "online", versao: "3.1.0" });
});

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "sugoi-api",
    timestamp: new Date().toISOString()
  });
});

app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    service: "sugoi-api",
    timestamp: new Date().toISOString()
  });
});

// 2. Autenticação (/auth/login e /api/auth/login)
const handleLogin = (req: express.Request, res: express.Response) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: "Email e senha são obrigatórios" });
  }

  const validUsers: Record<string, { nome: string; role: string }> = {
    "user1@sugoi.com.br": { nome: "João Silveira", role: "processo-editor" },
    "user2@sugoi.com.br": { nome: "Dra. Fernanda Vasconcelos", role: "auditor-travoes" },
    "user3@sugoi.com.br": { nome: "Dr. Arthur Pendelton", role: "diretor-presidente" }
  };

  const user = validUsers[email];
  if (user) {
    return res.json({
      status: "authenticated",
      token: "sugoi_jwt_token_" + Buffer.from(email).toString("base64"),
      user: {
        email,
        nome: user.nome,
        role: user.role
      }
    });
  }

  // Permite autenticação genérica caso teste com outro e-mail
  return res.json({
    status: "authenticated",
    token: "sugoi_jwt_token_demo_user",
    user: {
      email,
      nome: "Usuário Homologação",
      role: "processo-editor"
    }
  });
};

app.post("/auth/login", handleLogin);
app.post("/api/auth/login", handleLogin);

// 3. Processos BPM (/processos e /api/processos)
const handleListarProcessos = async (req: express.Request, res: express.Response) => {
  const list = await ProcessoService.list();
  res.json(list);
};

const handleCriarProcesso = async (req: express.Request, res: express.Response) => {
  try {
    const { nome, descricao, graph, user_id } = req.body;
    const result = await ProcessoService.create({
      nome: nome || "Novo Processo BPM",
      descricao,
      graph: graph || { nodes: [], edges: [] },
      user_id: user_id || "usr_dev1"
    });
    res.status(201).json(result);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
};

app.get("/processos", handleListarProcessos);
app.get("/api/processos", handleListarProcessos);
app.get("/api/v1/processos-bpm", handleListarProcessos);

app.post("/processos", handleCriarProcesso);
app.post("/api/processos", handleCriarProcesso);
app.post("/api/v1/processos-bpm", handleCriarProcesso);

app.get("/processos/:id", async (req, res) => {
  const proc = await ProcessoService.findById(req.params.id);
  if (!proc) return res.status(404).json({ error: "Processo não encontrado" });
  res.json(proc);
});

// 4. Validação dos 10 Travões (/validar, /api/validar, /validacoes/bpm)
const handleValidar = async (req: express.Request, res: express.Response) => {
  try {
    const { graph, metadata } = req.body;
    const resultado = await TravaoService.executeTravoes(graph, metadata);
    res.json(resultado);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
};

app.post("/validar", handleValidar);
app.post("/api/validar", handleValidar);
app.post("/api/v1/validacoes/bpm", handleValidar);

// 5. Fluxo Maker/Checker & Assinatura Digital (/aprovar e /processo/aceitar/:id)
const handleAprovar = async (req: express.Request, res: express.Response) => {
  try {
    const { user_id, concordancia, processo_id } = req.body;
    const id = req.params.id || processo_id;
    if (!id) return res.status(400).json({ error: "ID do processo obrigatório" });
    const resultado = await AprovacaoService.approve(
      id,
      user_id || "usr_checker_dir",
      concordancia !== false
    );
    res.json(resultado);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
};

app.post("/aprovar", handleAprovar);
app.post("/api/aprovar", handleAprovar);
app.post("/api/v1/processo/aceitar/:id", handleAprovar);

// 6. Busca Semântica RAG (/busca e /api/busca)
const handleBuscaRAG = (req: express.Request, res: express.Response) => {
  const termo = String(req.query.q || req.query.busca || "").toLowerCase();
  const precedentes = [
    { id: "rag_1", nome: "Contrato Fornecedor TI", descricao: "Cláusulas de SLA e segurança cloud", similarity_score: 0.94, setor: "Jurídico" },
    { id: "rag_2", nome: "Requisição de Faturamento", descricao: "Fluxo de aprovação fiscal e emissão NF", similarity_score: 0.88, setor: "Financeiro" },
    { id: "rag_3", nome: "Auditoria Forense de Crédito", descricao: "Roteiro pericial com laudos e certidões", similarity_score: 0.82, setor: "Auditoria" }
  ];
  if (!termo) return res.json(precedentes);
  const filtered = precedentes.filter(i => i.nome.toLowerCase().includes(termo) || i.descricao.toLowerCase().includes(termo));
  res.json(filtered);
};

app.get("/busca", handleBuscaRAG);
app.get("/api/busca", handleBuscaRAG);

// 7. Frontend SPA Fallback (servindo /login, /app e rotas client-side)
const frontendAppResponse = (req: express.Request, res: express.Response) => {
  res.send(`<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>SUGOI Kigyou — Portal de Processos BPM</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #1e293b; margin: 0; padding: 24px; }
    .card { background: #fff; max-width: 650px; margin: 40px auto; padding: 28px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); }
    h1 { color: #1F4E79; font-size: 22px; margin-bottom: 8px; }
    .status { display: inline-block; padding: 4px 10px; border-radius: 999px; background: #dcfce7; color: #166534; font-weight: bold; font-size: 13px; }
  </style>
</head>
<body>
  <div class="card">
    <span class="status">🟢 Produção Operacional</span>
    <h1>SUGOI Kigyou — Cadeia de Valor & BPM</h1>
    <p>Ambiente homologado para <strong>UAT (User Acceptance Testing)</strong>.</p>
    <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 20px 0;">
    <div>
      <strong>Rotas Ativas:</strong>
      <ul>
        <li><code>/health</code> — Status de integridade da API</li>
        <li><code>/processos</code> — Listagem e modelagem de processos BPM</li>
        <li><code>/validar</code> — Auditoria dos 10 travões periciais</li>
        <li><code>/auth/login</code> — Autenticação Maker/Checker</li>
      </ul>
    </div>
  </div>
</body>
</html>`);
};

app.get("/login", frontendAppResponse);
app.get('/login', frontendAppResponse);
app.get('/app', frontendAppResponse);
app.get('/app/:path*', frontendAppResponse);

const PORT = process.env.PORT || 8001;
if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => {
    console.log(`[Sugoi Backend] Servidor escutando na porta ${PORT}`);
  });
}

export default app;


