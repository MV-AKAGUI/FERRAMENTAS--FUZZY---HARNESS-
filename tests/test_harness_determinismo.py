from ferramentas.test_harness_determinismo import TestHarnessDeterminismo as Harness


def test_conciliacao_fecha_em_zero():
    ops = [{"valor_tomado": 100.0, "saldo_devedor": 60.10}, {"valor_tomado": 50.0, "saldo_devedor": 39.90}]
    r = Harness().conciliar_operacoes(ops, saldo_fechamento_esperado=100.00)
    assert r["status"] == "APROVADO_R$0,00"
    assert r["delta_apurado"] == 0


def test_conciliacao_detecta_divergencia_de_centavos():
    r = Harness().conciliar_operacoes([{"saldo_devedor": 100.02}], saldo_fechamento_esperado=100.00)
    assert r["status"] == "DIVERGENCIA_DETECTADA"


def test_fluxo_mensal_aponta_desvio():
    meses = [{"mes_rotulo": "jan", "desvio_contratual": 0}, {"mes_rotulo": "fev", "desvio_contratual": 5.0}]
    r = Harness().validar_fluxo_mensal(meses)
    assert r["status"] == "RESSALVAS_APURADAS"
    assert r["detalhes"][0]["mes"] == "fev"
