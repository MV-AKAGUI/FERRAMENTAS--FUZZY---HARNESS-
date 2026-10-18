import { ProcessoBPM, ResultadoValidacao, RespostaAprovacao, ResultadoBuscaRAG, GraphBPM } from "../types";

export class ApiService {
  private static baseUrl = process.env.REACT_APP_API_URL || "http://localhost:8001/api/v1";
  private static useMock = false;

  private static mockProcessos: ProcessoBPM[] = [
    {
      id: "proc_001",
      nome: "Homologação de Contrato B2B",
      descricao: "Fluxo padrão de contratação jurídica com validação Lei 14.063",
      status: "validado",
      graph: {
        nodes: [
          { id: "1", type: "start", label: "Início", setor: "Comercial" },
          { id: "2", type: "task", label: "Auditoria Jurídica", setor: "Jurídico" },
          { id: "3", type: "task", label: "Aprovação Financeira", setor: "Financeiro" },
          { id: "4", type: "end", label: "Assinatura Final", setor: "Diretoria" }
        ],
        edges: [
          { id: "e1", source: "1", target: "2" },
          { id: "e2", source: "2", target: "3" },
          { id: "e3", source: "3", target: "4" }
        ]
      },
      created_by: "usr_comercial",
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }
  ];

  public static setMockMode(enabled: boolean) {
    this.useMock = enabled;
  }

  public static async listarProcessos(): Promise<ProcessoBPM[]> {
    if (this.useMock) {
      return [...this.mockProcessos];
    }
    try {
      const res = await fetch(`${this.baseUrl}/processos-bpm`);
      if (!res.ok) throw new Error("Falha ao buscar processos");
      return await res.json();
    } catch {
      return [...this.mockProcessos];
    }
  }

  public static async criarProcesso(nome: string, graph: GraphBPM, userId: string = "usr_dev_fe"): Promise<ProcessoBPM> {
    if (this.useMock) {
      const novo: ProcessoBPM = {
        id: "proc_" + Math.random().toString(36).substring(2, 9),
        nome,
        status: "rascunho",
        graph,
        created_by: userId,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      this.mockProcessos.push(novo);
      return novo;
    }

    const res = await fetch(`${this.baseUrl}/processos-bpm`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ nome, graph, user_id: userId })
    });
    return await res.json();
  }

  public static async validarProcesso(graph: GraphBPM): Promise<ResultadoValidacao> {
    if (this.useMock) {
      return {
        passou_todos: true,
        score: 100,
        travoes: Array.from({ length: 10 }, (_, i) => ({
          id: i + 1,
          nome: `Travão ${i + 1}`,
          passou: true,
          mensagem: "Validação mock concluída com sucesso."
        })),
        data_validacao: new Date().toISOString()
      };
    }

    const res = await fetch(`${this.baseUrl}/validacoes/bpm`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ graph })
    });
    return await res.json();
  }

  public static async aprovarProcesso(processoId: string, userId: string, concordancia: boolean): Promise<RespostaAprovacao> {
    if (this.useMock) {
      return {
        status: concordancia ? "aprovado" : "rejeitado",
        processo_id: processoId,
        mensagem: "Decisão mock registrada com sucesso."
      };
    }

    const res = await fetch(`${this.baseUrl}/processo/aceitar/${processoId}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ user_id: userId, concordancia })
    });
    return await res.json();
  }

  public static async buscaRAG(query: string): Promise<ResultadoBuscaRAG[]> {
    // Simula busca semântica RAG instantânea
    const termo = query.toLowerCase();
    const mockDb: ResultadoBuscaRAG[] = [
      { id: "rag_1", nome: "Contrato Fornecedor TI", descricao: "Cláusulas de SLA e segurança cloud", similarity_score: 0.94, setor: "Jurídico" },
      { id: "rag_2", nome: "Requisição de Faturamento", descricao: "Fluxo de aprovação fiscal e emissão NF", similarity_score: 0.88, setor: "Financeiro" },
      { id: "rag_3", nome: "Auditoria Forense de Crédito", descricao: "Roteiro pericial com laudos e certidões", similarity_score: 0.82, setor: "Auditoria" }
    ];

    return mockDb.filter(i => i.nome.toLowerCase().includes(termo) || i.descricao.toLowerCase().includes(termo) || i.setor.toLowerCase().includes(termo));
  }
}
