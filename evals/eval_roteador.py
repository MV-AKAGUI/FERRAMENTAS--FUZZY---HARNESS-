"""Eval do roteamento (juridico / financeiro / investigacao) do sistema_nervoso_langgraph.

Uso (da raiz do repo):
    python evals/eval_roteador.py llama          # roteador atual (Llama 3.1 via Ollama)
    python evals/eval_roteador.py laya           # Laya (precisa do pacote laya instalado)

Mede acerto geral, acerto nos casos difíceis, matriz de confusão e latência (1ª chamada é aquecimento, fora da conta).
"""
import json, statistics, sys, time
from collections import Counter
from pathlib import Path

AQUI = Path(__file__).parent
CLASSES = ["juridico", "financeiro", "investigacao"]


def backend_llama():
    sys.path.insert(0, str(AQUI.parent))
    from langchain_core.messages import HumanMessage
    from sistema_nervoso_langgraph import roteador
    return lambda texto: roteador({"messages": [HumanMessage(content=texto)]})


def backend_laya():
    from laya_backend import classificar  # evals/laya_backend.py
    return classificar


def main(nome):
    casos = [json.loads(l) for l in (AQUI / "roteamento.jsonl").read_text(encoding="utf-8").splitlines() if l.strip()]
    prever = {"llama": backend_llama, "laya": backend_laya}[nome]()
    prever(casos[0]["texto"])  # aquecimento: carrega o modelo

    linhas, tempos = [], []
    for c in casos:
        t0 = time.perf_counter()
        p = prever(c["texto"])
        tempos.append(time.perf_counter() - t0)
        linhas.append({**c, "previsto": p, "ok": p == c["rotulo"]})
        print(f"{'OK ' if p == c['rotulo'] else 'ERR'} {c['id']} {c['rotulo']:>12} -> {p:<12} {tempos[-1]*1000:7.0f} ms", flush=True)

    dif = [l for l in linhas if l["dificil"]]
    q = statistics.quantiles(tempos, n=20)
    resumo = {
        "backend": nome,
        "casos": len(linhas),
        "acerto": round(sum(l["ok"] for l in linhas) / len(linhas), 3),
        "acerto_dificeis": round(sum(l["ok"] for l in dif) / len(dif), 3),
        "acerto_por_classe": {k: round(sum(l["ok"] for l in linhas if l["rotulo"] == k) / sum(l["rotulo"] == k for l in linhas), 3) for k in CLASSES},
        "confusao": {k: dict(Counter(l["previsto"] for l in linhas if l["rotulo"] == k)) for k in CLASSES},
        "latencia_ms": {"p50": round(statistics.median(tempos) * 1000), "p95": round(q[18] * 1000), "total_s": round(sum(tempos), 1)},
        "erros": [l["id"] for l in linhas if not l["ok"]],
    }
    (AQUI / "resultados").mkdir(exist_ok=True)
    (AQUI / "resultados" / f"{nome}.json").write_text(json.dumps({"resumo": resumo, "linhas": linhas}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(resumo, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "llama")
