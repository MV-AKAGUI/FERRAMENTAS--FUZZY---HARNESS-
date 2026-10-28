"""Adaptador do Laya para o eval de roteamento.

LAYA_CRITERIOS=curtos (padrão): mesmos critérios do prompt do roteador atual.
LAYA_CRITERIOS=ricos: critérios descritivos do domínio (testa quanto o Laya depende da descrição).
"""
import os
from laya import Router

_router = Router()
_RICOS = {
    "juridico": "interpretar leis, cláusulas, contratos, garantias, escrituras, estatutos, prazos processuais, "
                "validade de atos, responsabilidade legal, recuperação judicial; pede parecer ou base legal",
    "financeiro": "calcular ou analisar números: saldos, juros, amortização, fluxo de caixa, DRE, balanço, "
                  "EBITDA, índices, projeções, conciliação de valores; pede uma conta ou planilha",
    "investigacao": "apurar suspeitas e fatos: fraude, favorecimento, conflito de interesse, pessoas e vínculos, "
                    "documentos divergentes ou apagados, padrões estranhos, linha do tempo; pergunta quem, por que ou o que está por trás",
}
_PERGUNTA = {
    "assunto": {
        "type": "choice",
        "instructions": "Qual especialista deve atender esta queixa?",
        "criteria": {
            "juridico": "leis, regras ou contratos",
            "financeiro": "dinheiro, planilhas ou lucros",
            "investigacao": "pesquisa, anomalias ou dúvidas abertas",
        },
    }
}
if os.getenv("LAYA_CRITERIOS") == "ricos":
    _PERGUNTA["assunto"]["criteria"] = _RICOS


def classificar(texto: str) -> str:
    # português vai para o checkpoint multilíngue; forçar evita cair no inglês em texto curto
    r = _router.predict(texto, _PERGUNTA, model="multilingual")
    return r["answers"]["assunto"]["choice"]
