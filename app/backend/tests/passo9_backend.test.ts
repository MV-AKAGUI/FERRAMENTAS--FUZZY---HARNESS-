import { hasCycle, isConnected, hasOrphans } from "../src/utils/graph-validators";
import { AssinaturaSHA256 } from "../src/security/AssinaturaSHA256";
import { TravaoService } from "../src/services/TravaoService";

describe("Testes Unitários - PASSO 9 Backend", () => {
  test("Validador de Grafos: Detecta Ciclo", () => {
    const graphComCiclo = {
      nodes: [{ id: "A", type: "task" }, { id: "B", type: "task" }],
      edges: [{ source: "A", target: "B" }, { source: "B", target: "A" }]
    };
    expect(hasCycle(graphComCiclo)).toBe(true);

    const graphSemCiclo = {
      nodes: [{ id: "A", type: "task" }, { id: "B", type: "task" }],
      edges: [{ source: "A", target: "B" }]
    };
    expect(hasCycle(graphSemCiclo)).toBe(false);
  });

  test("Validador de Grafos: Conectividade e Órfãos", () => {
    const graphConectado = {
      nodes: [{ id: "1", type: "start" }, { id: "2", type: "end" }],
      edges: [{ source: "1", target: "2" }]
    };
    expect(isConnected(graphConectado)).toBe(true);
    expect(hasOrphans(graphConectado).length).toBe(0);

    const graphComOrfao = {
      nodes: [{ id: "1", type: "start" }, { id: "2", type: "end" }, { id: "3", type: "orphan" }],
      edges: [{ source: "1", target: "2" }]
    };
    expect(hasOrphans(graphComOrfao)).toContain("3");
  });

  test("Criptografia: SHA-256 e Assinatura Digital", () => {
    const payload = { id: "proc_001", valor: 150000 };
    const hash = AssinaturaSHA256.calcularHash(payload);
    expect(hash).toHaveLength(64);

    const assinatura = AssinaturaSHA256.criarAssinatura(hash, "usr_diretor_01");
    expect(assinatura.hash_assinatura).toHaveLength(64);
    expect(assinatura.signer_id).toBe("usr_diretor_01");
    expect(assinatura.conformidade_lei).toContain("14.063");
  });

  test("Travões: Execução dos 10 travões", async () => {
    const resultado = await TravaoService.executeTravoes({});
    expect(resultado.passou_todos).toBe(true);
    expect(resultado.score).toBe(100);
    expect(resultado.travoes.length).toBe(10);
  });
});
