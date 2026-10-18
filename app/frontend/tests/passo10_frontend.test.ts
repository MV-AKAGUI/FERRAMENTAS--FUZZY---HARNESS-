import { ApiService } from "../src/services/api";
import { SETORES_PAM } from "../src/components/ProcessoCanvas";

describe("Testes Frontend PASSO 10 - DIFY & React Components", () => {
  beforeAll(() => {
    ApiService.setMockMode(true);
  });

  test("1. Tipos e Constantes: Deve conter os 14 setores PAM homologados", () => {
    expect(SETORES_PAM.length).toBe(14);
    expect(SETORES_PAM).toContain("Presidência");
    expect(SETORES_PAM).toContain("Diretoria Jurídica");
    expect(SETORES_PAM).toContain("Auditoria Pericial");
    expect(SETORES_PAM).toContain("Compliance & DPO");
  });

  test("2. ApiService: Listagem de Processos Mock", async () => {
    const lista = await ApiService.listarProcessos();
    expect(Array.isArray(lista)).toBe(true);
    expect(lista.length).toBeGreaterThan(0);
    expect(lista[0].status).toBe("validado");
  });

  test("3. ApiService: Criação de Novo Processo", async () => {
    const graphMock = {
      nodes: [{ id: "n1", type: "task", label: "Teste Unitário" }],
      edges: []
    };
    const novo = await ApiService.criarProcesso("Processo Automatizado", graphMock, "usr_tester");
    expect(novo.id).toBeDefined();
    expect(novo.status).toBe("rascunho");
    expect(novo.created_by).toBe("usr_tester");
  });

  test("4. ApiService: Validação de 10 Travões via Mock", async () => {
    const resultado = await ApiService.validarProcesso({ nodes: [], edges: [] });
    expect(resultado.passou_todos).toBe(true);
    expect(resultado.score).toBe(100);
    expect(resultado.travoes.length).toBe(10);
  });

  test("5. ApiService: Aprovação Maker/Checker", async () => {
    const aprovacao = await ApiService.aprovarProcesso("proc_001", "usr_diretor", true);
    expect(aprovacao.status).toBe("aprovado");
    expect(aprovacao.processo_id).toBe("proc_001");
  });

  test("6. ApiService: Busca Semântica RAG", async () => {
    const res = await ApiService.buscaRAG("Contrato");
    expect(Array.isArray(res)).toBe(true);
    expect(res.length).toBeGreaterThan(0);
    expect(res[0].similarity_score).toBeGreaterThan(0.7);
  });
});
