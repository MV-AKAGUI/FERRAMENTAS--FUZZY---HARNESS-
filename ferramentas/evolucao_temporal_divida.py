"""
KAN-SA — Motor de Evolução Temporal da Dívida (Multi-Exercício)
Responsável por extrair a série histórica consolidada de endividamento (2021 a 2024),
computar variações nominais, percentuais, CAGR e gerar gráficos interativos para a DAI.
"""

import os
import json
import logging
from typing import Dict, Any, List, Optional

logger = logging.getLogger("kan_sa.evolucao_divida")

class EvolucaoTemporalDividaEngine:
    """
    Engine de Inteligência Financeira e Ciência de Dados:
    Permite consolidar dinamicamente o endividamento do Grupo SUGOI
    entre períodos customizados (ex: 2021 a 2023, 2021 a 2024, etc.).
    """

    def __init__(self, diretorio_data: Optional[str] = None):
        if diretorio_data:
            self.diretorio_data = diretorio_data
        else:
            self.diretorio_data = os.path.abspath(
                os.path.join(os.path.dirname(__file__), "..", "data")
            )

    def carregar_dados_ano(self, ano: int) -> Optional[Dict[str, Any]]:
        caminho = os.path.join(self.diretorio_data, f"dados_endividamento_{ano}.json")
        if os.path.exists(caminho):
            try:
                with open(caminho, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Erro ao carregar dados de {ano}: {e}")
        return None

    def consolidar_periodo(self, ano_inicio: int = 2021, ano_fim: int = 2024) -> Dict[str, Any]:
        """
        Consolida a série mês a mês no intervalo [ano_inicio, ano_fim].
        """
        if ano_inicio > ano_fim:
            ano_inicio, ano_fim = ano_fim, ano_inicio

        serie_mensal: List[Dict[str, Any]] = []
        fechamentos_anuais: List[Dict[str, Any]] = []

        for ano in range(ano_inicio, ano_fim + 1):
            dados_ano = self.carregar_dados_ano(ano)
            if not dados_ano:
                continue

            evolucao = dados_ano.get("resumo_consolidado_evolucao_mensal", [])
            for item in evolucao:
                serie_mensal.append({
                    "mes": item.get("mes"),
                    "mes_rotulo": item.get("mes_rotulo"),
                    "ano": ano,
                    "total_divida_bruta": float(item.get("total_divida_bruta", 0.0)),
                    "sugoi_sa": float(item.get("sugoi_sa", 0.0)),
                    "dahab_brasil_sa": float(item.get("dahab_brasil_sa", 0.0)),
                    "spes": float(item.get("spes", 0.0))
                })

            if evolucao:
                ultimo_mes = evolucao[-1]
                fechamentos_anuais.append({
                    "ano": ano,
                    "mes_fechamento": ultimo_mes.get("mes_rotulo"),
                    "total_divida": float(ultimo_mes.get("total_divida_bruta", 0.0)),
                    "sugoi_sa": float(ultimo_mes.get("sugoi_sa", 0.0)),
                    "dahab_brasil_sa": float(ultimo_mes.get("dahab_brasil_sa", 0.0)),
                    "spes": float(ultimo_mes.get("spes", 0.0))
                })

        # Métricas analíticas
        if not serie_mensal:
            return {"status": "SEM_DADOS", "mensagem": "Nenhum dado encontrado para o período especificado."}

        divida_inicial = serie_mensal[0]["total_divida_bruta"]
        divida_final = serie_mensal[-1]["total_divida_bruta"]
        variacao_nominal = divida_final - divida_inicial
        variacao_percentual = (variacao_nominal / divida_inicial * 100) if divida_inicial > 0 else 0.0

        pico = max(serie_mensal, key=lambda x: x["total_divida_bruta"])
        minima = min(serie_mensal, key=lambda x: x["total_divida_bruta"])

        # Cálculo do CAGR se houver mais de 1 ano
        num_anos = max(1, ano_fim - ano_inicio)
        if divida_inicial > 0 and num_anos >= 1:
            cagr = ((divida_final / divida_inicial) ** (1 / num_anos) - 1) * 100
        else:
            cagr = 0.0

        return {
            "status": "SUCESSO",
            "periodo": f"{ano_inicio} a {ano_fim}",
            "ano_inicio": ano_inicio,
            "ano_fim": ano_fim,
            "total_meses_analisados": len(serie_mensal),
            "divida_inicial": divida_inicial,
            "divida_final": divida_final,
            "variacao_nominal": variacao_nominal,
            "variacao_percentual": round(variacao_percentual, 2),
            "cagr_anual": round(cagr, 2),
            "pico_historico": {
                "mes": pico.get("mes_rotulo"),
                "valor": pico.get("total_divida_bruta")
            },
            "minima_historica": {
                "mes": minima.get("mes_rotulo"),
                "valor": minima.get("total_divida_bruta")
            },
            "fechamentos_anuais": fechamentos_anuais,
            "serie_mensal": serie_mensal
        }

    def gerar_html_grafico_svg(self, dados_consolidacao: Dict[str, Any]) -> str:
        """
        Gera um gráfico visual moderno em SVG com degradê e tooltips responsivos,
        totalmente autossuficiente (sem requisições externas para funcionar offline).
        """
        serie = dados_consolidacao.get("serie_mensal", [])
        if not serie:
            return "<p style='color:#94a3b8;'>Nenhum dado disponível para visualização.</p>"

        # Determinar limites para escala
        valores_total = [item["total_divida_bruta"] for item in serie]
        max_val = max(valores_total) * 1.10
        min_val = min(valores_total) * 0.85
        delta_val = max_val - min_val if max_val != min_val else 1.0

        width = 860
        height = 340
        padding_left = 70
        padding_right = 30
        padding_top = 30
        padding_bottom = 50

        largura_util = width - padding_left - padding_right
        altura_util = height - padding_top - padding_bottom

        pontos_total = []
        pontos_sugoi = []
        pontos_dahab = []
        pontos_spes = []

        labels_x = []

        n = len(serie)
        step_x = largura_util / (n - 1) if n > 1 else largura_util

        for i, item in enumerate(serie):
            x = padding_left + i * step_x
            
            # y para Total
            y_tot = padding_top + altura_util - ((item["total_divida_bruta"] - min_val) / delta_val * altura_util)
            pontos_total.append(f"{x:.1f},{y_tot:.1f}")

            # y para Sugoi SA
            y_sug = padding_top + altura_util - ((item["sugoi_sa"] - min_val) / delta_val * altura_util)
            pontos_sugoi.append(f"{x:.1f},{y_sug:.1f}")

            # y para Dahab
            y_dah = padding_top + altura_util - ((item["dahab_brasil_sa"] - min_val) / delta_val * altura_util)
            pontos_dahab.append(f"{x:.1f},{y_dah:.1f}")

            # y para SPEs
            y_spe = padding_top + altura_util - ((item["spes"] - min_val) / delta_val * altura_util)
            pontos_spes.append(f"{x:.1f},{y_spe:.1f}")

            # Marcar label a cada 4 ou 6 meses
            if n <= 16 or i % max(1, n // 8) == 0 or i == n - 1:
                labels_x.append(f"<text x='{x:.1f}' y='{height - 15}' text-anchor='middle' fill='#94a3b8' font-size='11' font-family='JetBrains Mono'>{item['mes_rotulo']}</text>")

        path_total = "M " + " L ".join(pontos_total)
        path_sugoi = "M " + " L ".join(pontos_sugoi)
        path_dahab = "M " + " L ".join(pontos_dahab)
        path_spes = "M " + " L ".join(pontos_spes)

        # Degradê para área sob a curva do Total
        primeiro_x = padding_left
        ultimo_x = padding_left + (n - 1) * step_x
        y_chao = padding_top + altura_util
        area_total = f"{path_total} L {ultimo_x:.1f},{y_chao} L {primeiro_x:.1f},{y_chao} Z"

        # Linhas de grade horizontais
        grid_lines = []
        for step in range(5):
            val_grid = min_val + (step / 4) * delta_val
            y_grid = padding_top + altura_util - (step / 4 * altura_util)
            grid_lines.append(f"<line x1='{padding_left}' y1='{y_grid:.1f}' x2='{width - padding_right}' y2='{y_grid:.1f}' stroke='rgba(255,255,255,0.08)' stroke-dasharray='4,4'/>")
            val_formatado = f"R$ {val_grid/1e6:.1f}M"
            grid_lines.append(f"<text x='{padding_left - 10}' y='{y_grid + 4:.1f}' text-anchor='end' fill='#64748b' font-size='10' font-family='JetBrains Mono'>{val_formatado}</text>")

        svg = f"""
        <div style="background:#0f172a; border:1px solid rgba(255,255,255,0.1); border-radius:16px; padding:20px; box-shadow:0 10px 25px rgba(0,0,0,0.4); margin-top:16px;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; flex-wrap:wrap; gap:12px;">
                <div>
                    <h3 style="color:#ffffff; font-size:1.1rem; font-weight:700; margin:0;">📈 Evolução do Passivo Bruto ({dados_consolidacao.get('periodo')})</h3>
                    <p style="color:#94a3b8; font-size:0.80rem; margin-top:2px;">Consolidação multi-exercício Grupo SUGOI • Valores nominais em R$</p>
                </div>
                <div style="display:flex; gap:14px; font-size:0.75rem; flex-wrap:wrap;">
                    <span style="color:#F05A22; font-weight:700;">● TOTAL GRUPO</span>
                    <span style="color:#3b82f6; font-weight:600;">● SUGOI S.A</span>
                    <span style="color:#10b981; font-weight:600;">● DAHAB BRASIL</span>
                    <span style="color:#a855f7; font-weight:600;">● SPEs</span>
                </div>
            </div>
            
            <div style="overflow-x:auto;">
                <svg viewBox="0 0 {width} {height}" style="width:100%; height:auto; min-width:650px; display:block;">
                    <defs>
                        <linearGradient id="gradTotal" x1="0%" y1="0%" x2="0%" y2="100%">
                            <stop offset="0%" stop-color="#F05A22" stop-opacity="0.35"/>
                            <stop offset="100%" stop-color="#F05A22" stop-opacity="0.00"/>
                        </linearGradient>
                    </defs>
                    
                    <!-- Grades e Eixos -->
                    {''.join(grid_lines)}
                    
                    <!-- Área do Total -->
                    <path d="{area_total}" fill="url(#gradTotal)"/>
                    
                    <!-- Linhas das Séries -->
                    <path d="{path_spes}" fill="none" stroke="#a855f7" stroke-width="2" stroke-dasharray="3,3"/>
                    <path d="{path_dahab}" fill="none" stroke="#10b981" stroke-width="2.2"/>
                    <path d="{path_sugoi}" fill="none" stroke="#3b82f6" stroke-width="2.5"/>
                    <path d="{path_total}" fill="none" stroke="#F05A22" stroke-width="3.5"/>
                    
                    <!-- Labels do Eixo X -->
                    {''.join(labels_x)}
                </svg>
            </div>
        </div>
        """
        return svg
