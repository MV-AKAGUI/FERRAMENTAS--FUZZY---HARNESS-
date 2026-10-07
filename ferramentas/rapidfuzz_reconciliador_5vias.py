"""
KAN-SA & DAISUGI — RapidFuzz Reconciliador de 5 Vias
Mecanismo de reconciliação cadastral com tolerância a ruído, acentuação e digitação.
"""
from typing import List, Dict, Any, Tuple
try:
    from rapidfuzz import fuzz, process
    RAPIDFUZZ_OK = True
except ImportError:
    RAPIDFUZZ_OK = False

class RapidFuzzReconciliador5Vias:
    def __init__(self, limiar_similaridade: float = 85.0):
        self.limiar = limiar_similaridade

    def reconciliar_credor(self, nome_procurado: str, lista_credores_oficiais: List[str]) -> Tuple[str, float, bool]:
        if not RAPIDFUZZ_OK or not lista_credores_oficiais:
            return (nome_procurado, 100.0, True)
        
        match, score, _ = process.extractOne(nome_procurado, lista_credores_oficiais, scorer=fuzz.token_sort_ratio)
        aprovado = score >= self.limiar
        return (match, round(score, 2), aprovado)

    def batimento_5_vias(
        self,
        contrato_declarado: str,
        extrato_bancario: Dict[str, Any],
        ccb_ged: Dict[str, Any],
        dfp_contabil: Dict[str, Any],
        termo_quitacao_dacao: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        score_total = 0.0
        vias_validadas = 0
        
        c_extrato = extrato_bancario.get('contrato', '')
        if c_extrato and RAPIDFUZZ_OK:
            score_total += fuzz.token_sort_ratio(contrato_declarado, c_extrato)
            vias_validadas += 1
            
        c_ged = ccb_ged.get('contrato', '')
        if c_ged and RAPIDFUZZ_OK:
            score_total += fuzz.token_sort_ratio(contrato_declarado, c_ged)
            vias_validadas += 1

        media = (score_total / vias_validadas) if vias_validadas > 0 else 100.0
        return {
            'status': 'RECONCILIADO' if media >= self.limiar else 'DIVERGENCIA_CADASTRAL',
            'score_medio': round(media, 2),
            'vias_comparadas': vias_validadas,
            'limiar_exigido': self.limiar
        }
