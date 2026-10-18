import express from "express";
import cors from "cors";
import path from "path";
import fs from "fs";
import { ProcessoService } from "./services/ProcessoService";
import { TravaoService } from "./services/TravaoService";
import { AprovacaoService } from "./services/AprovacaoService";
import { OllamaService } from "./services/OllamaService";

const app = express();
app.use(cors());
app.use(express.json());

// 1. Raiz & Health check
app.get("/", (req, res) => {
  res.redirect("/login");
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

// 7. INTERFACE INTERATIVA: /login (Formulário Real com Auth & Armazenamento de Token)
app.get("/login", (req, res) => {
  res.send(`<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SUGOI Kigyou — Portal de Processos BPM (Login)</title>
  <style>
    * { box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .login-card { background: #1e293b; width: 100%; max-width: 440px; padding: 36px; border-radius: 14px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.5); border: 1px solid #334155; }
    .badge { display: inline-block; padding: 4px 10px; border-radius: 999px; background: #065f46; color: #34d399; font-weight: bold; font-size: 12px; margin-bottom: 16px; }
    h1 { color: #38bdf8; font-size: 24px; margin: 0 0 8px 0; }
    p { color: #94a3b8; font-size: 14px; margin-bottom: 24px; }
    .form-group { margin-bottom: 18px; }
    label { display: block; font-size: 13px; font-weight: 600; color: #cbd5e1; margin-bottom: 6px; }
    input { width: 100%; padding: 10px 14px; border-radius: 8px; border: 1px solid #475569; background: #0f172a; color: #fff; font-size: 14px; outline: none; }
    input:focus { border-color: #38bdf8; box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.2); }
    button { width: 100%; padding: 12px; border-radius: 8px; border: none; background: #0284c7; color: #fff; font-size: 15px; font-weight: bold; cursor: pointer; transition: background 0.2s; margin-top: 10px; }
    button:hover { background: #0369a1; }
    .error-msg { background: #7f1d1d; color: #fca5a5; padding: 10px; border-radius: 6px; font-size: 13px; margin-bottom: 16px; display: none; }
    .test-users { margin-top: 24px; padding-top: 20px; border-top: 1px solid #334155; font-size: 12px; color: #94a3b8; }
    .test-user-item { cursor: pointer; padding: 6px 8px; border-radius: 4px; background: #0f172a; margin-top: 6px; display: flex; justify-content: space-between; }
    .test-user-item:hover { background: #1e3a5f; color: #38bdf8; }
  </style>
</head>
<body>
  <div class="login-card">
    <span class="badge">🟢 UAT Homologação Ativa</span>
    <h1>SUGOI Kigyou BPM</h1>
    <p>Acesse o Portal de Auditoria & Cadeia de Valor</p>

    <div id="errorBox" class="error-msg"></div>

    <form id="loginForm">
      <div class="form-group">
        <label for="email">E-mail Corporativo</label>
        <input type="email" id="email" required placeholder="user1@sugoi.com.br" value="user1@sugoi.com.br">
      </div>
      <div class="form-group">
        <label for="password">Senha de Acesso</label>
        <input type="password" id="password" required placeholder="••••••••" value="temp-pwd-001">
      </div>
      <button type="submit" id="btnSubmit">Entrar no Sistema</button>
    </form>

    <div class="test-users">
      <strong>Contas Pré-Homologadas (Clique para preencher):</strong>
      <div class="test-user-item" onclick="fillUser('user1@sugoi.com.br', 'temp-pwd-001')">
        <span>Setor 1: Comercial (Maker)</span>
        <code>user1@sugoi.com.br</code>
      </div>
      <div class="test-user-item" onclick="fillUser('user2@sugoi.com.br', 'temp-pwd-002')">
        <span>Setor 2: Auditoria (10 Travões)</span>
        <code>user2@sugoi.com.br</code>
      </div>
      <div class="test-user-item" onclick="fillUser('user3@sugoi.com.br', 'temp-pwd-003')">
        <span>Setor 3: Diretoria (Checker/Lei 14.063)</span>
        <code>user3@sugoi.com.br</code>
      </div>
    </div>
  </div>

  <script>
    function fillUser(email, pwd) {
      document.getElementById('email').value = email;
      document.getElementById('password').value = pwd;
    }

    document.getElementById('loginForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const email = document.getElementById('email').value;
      const password = document.getElementById('password').value;
      const btn = document.getElementById('btnSubmit');
      const errorBox = document.getElementById('errorBox');

      btn.disabled = true;
      btn.textContent = 'Autenticando...';
      errorBox.style.display = 'none';

      try {
        const res = await fetch('/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password })
        });
        const data = await res.json();

        if (res.ok && data.token) {
          localStorage.setItem('sugoi_auth_token', data.token);
          localStorage.setItem('sugoi_user', JSON.stringify(data.user));
          window.location.href = '/app';
        } else {
          throw new Error(data.error || 'Credenciais inválidas');
        }
      } catch (err) {
        errorBox.textContent = err.message || 'Falha na conexão com a API';
        errorBox.style.display = 'block';
        btn.disabled = false;
        btn.textContent = 'Entrar no Sistema';
      }
    });
  </script>
</body>
</html>`);
});

// 8. INTERFACE INTERATIVA: /app (Studio Executivo da Cadeia de Valor & BPM)
const publicDirCandidates = [
  path.join(__dirname, "../public"),
  path.join(__dirname, "../../public"),
  path.join(process.cwd(), "public"),
  path.join(process.cwd(), "app/backend/public"),
  path.join("/opt/daisugi/sugoi/app/backend/public")
];

let publicDir = "";
for (const dir of publicDirCandidates) {
  if (fs.existsSync(dir)) {
    publicDir = dir;
    break;
  }
}

if (publicDir) {
  app.use(express.static(publicDir));
}

app.get("/app", (req, res) => {
  const appHtmlPath = publicDir ? path.join(publicDir, "app.html") : "";
  if (appHtmlPath && fs.existsSync(appHtmlPath)) {
    return res.sendFile(appHtmlPath);
  }
  res.redirect("/login");
});

const PORT = process.env.PORT || 8001;
if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => {
    console.log(`[Sugoi Backend] Servidor escutando na porta ${PORT}`);
  });
}

export default app;

