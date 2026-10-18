import express from "express";
import cors from "cors";
import { ProcessoService } from "./services/ProcessoService";
import { TravaoService } from "./services/TravaoService";
import { AprovacaoService } from "./services/AprovacaoService";
import { OllamaService } from "./services/OllamaService";

const app = express();
app.use(cors());
app.use(express.json());

// 1. Health check
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "sugoi_backend_bpm_passo9",
    timestamp: new Date().toISOString()
  });
});

// 2. CRUD Processos BPM
app.post("/api/v1/processos-bpm", async (req, res) => {
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
});

app.get("/api/v1/processos-bpm", async (req, res) => {
  const list = await ProcessoService.list();
  res.json(list);
});

app.get("/api/v1/processos-bpm/:id", async (req, res) => {
  const proc = await ProcessoService.findById(req.params.id);
  if (!proc) return res.status(404).json({ error: "Processo não encontrado" });
  res.json(proc);
});

// 3. Validação dos 10 Travões
app.post("/api/v1/validacoes/bpm", async (req, res) => {
  try {
    const { graph, metadata } = req.body;
    const resultado = await TravaoService.executeTravoes(graph, metadata);
    res.json(resultado);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 4. Fluxo Maker/Checker & Assinatura Digital
app.post("/api/v1/processo/aceitar/:id", async (req, res) => {
  try {
    const { user_id, concordancia } = req.body;
    const resultado = await AprovacaoService.approve(
      req.params.id,
      user_id || "usr_checker_dir",
      concordancia !== false
    );
    res.json(resultado);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

// 5. Teste de IA Ollama
app.post("/api/v1/ia/semantica-bpm", async (req, res) => {
  try {
    const { prompt } = req.body;
    const resultado = await OllamaService.validateBPMWithCascade(prompt || "Analise a consistência do fluxo BPM.");
    res.json(resultado);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 8001;
app.listen(PORT, () => {
  console.log(`[Sugoi Backend PASSO 9] Servidor escutando na porta ${PORT}`);
});

export default app;
