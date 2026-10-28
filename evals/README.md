# Evals

## Roteamento (`sistema_nervoso_langgraph.roteador`)

60 pedidos sintéticos rotulados (`roteamento.jsonl`, 20 por classe, 23 difíceis). Rótulo = especialista que deve agir primeiro. Revisar rótulos e trocar por pedidos reais quando houver.

```bash
.venv/Scripts/python.exe evals/eval_roteador.py llama                 # roteador atual
.venv-laya/Scripts/python.exe evals/eval_roteador.py laya             # Laya zero-shot (venv separado)
LAYA_CRITERIOS=ricos .venv-laya/Scripts/python.exe evals/eval_roteador.py laya
```

### Resultado em 28/10/2026 (RTX 3050 4 GB; Laya em CPU)

| Backend | Acerto | Difíceis | jurídico / financeiro / investigação | p50 |
|---|---|---|---|---|
| Llama 3.1 (atual) | **76,7%** | **60%** | 100% / 90% / 40% | 814 ms |
| Laya 0.4.15 multilíngue, critérios do prompt | 61,7% | 35% | 55% / 100% / 30% | **104 ms** |
| Laya, critérios ricos | 60,0% | 45% | 45% / 95% / 40% | 198 ms |

Laya com confiança ≥ 0,9 cobre 21/60 casos com 81% de acerto: não serve como atalho para os casos fáceis.

**Conclusão:** Laya zero-shot não substitui o roteador. É 8x mais rápido, mas perde 15 pontos de acerto e tende a mandar tudo para `financeiro`. Caminho para reavaliar: fine-tune do Laya com ~300–500 decisões reais rotuladas (notebook oficial em GPU gratuita do Kaggle) e rodar este mesmo eval. O ponto fraco do roteador atual é `investigacao` (40%).
