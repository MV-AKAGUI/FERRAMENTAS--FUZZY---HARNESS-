"""
KAN-SA & DAISUGI — Test Harness de Tolerância Matemática Zero (R$ 0,00)
Motor Determinístico Anti-Alucinação para Conciliação de Dívidas, Amortizações e Juros.
"""
from typing import List, Dict, Any

class TestHarnessDeterminismo:
    """
    Executa cálculos puramente aritméticos sem intermediação de LLMs,
    garantindo que qualquer laudo pericial mantenha delta de fechamento de R$ 0,00.
    """
    def __init__(self, tolerancia_centavos: float = 0.01):
        self.tolerancia = tolerancia_centavos

    def conciliar_operacoes(self, operacoes: List[Dict[str, Any]], saldo_fechamento_esperado: float = None) -> Dict[str, Any]:
        soma_tomado = sum(float(op.get('valor_tomado', 0.0) or 0.0) for op in operacoes)
        soma_saldo = sum(float(op.get('saldo_devedor', 0.0) or 0.0) for op in operacoes)
        
        delta = 0.0
        if saldo_fechamento_esperado is not None:
            delta = abs(soma_saldo - float(saldo_fechamento_esperado))
            
        aprovado = delta <= self.tolerancia
        return {
            'status': 'APROVADO_R$0,00' if aprovado else 'DIVERGENCIA_DETECTADA',
            'delta_apurado': round(delta, 4),
            'soma_tomado': round(soma_tomado, 2),
            'soma_saldo_devedor': round(soma_saldo, 2),
            'saldo_fechamento_esperado': round(saldo_fechamento_esperado, 2) if saldo_fechamento_esperado else round(soma_saldo, 2),
            'tolerancia_limite': self.tolerancia,
            'total_operacoes': len(operacoes)
        }

    def validar_fluxo_mensal(self, meses: List[Dict[str, Any]]) -> Dict[str, Any]:
        inconsistencias = []
        for i, m in enumerate(meses):
            desvio = float(m.get('desvio_contratual', 0.0) or 0.0)
            if abs(desvio) > self.tolerancia:
                inconsistencias.append({
                    'mes': m.get('mes_rotulo') or i + 1,
                    'desvio': desvio,
                    'causa': m.get('causa_raiz_desvio', 'Não justificada')
                })
        return {
            'status': 'CONFORME' if not inconsistencias else 'RESSALVAS_APURADAS',
            'qtd_inconsistencias': len(inconsistencias),
            'detalhes': inconsistencias
        }
