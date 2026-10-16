# SDD — Especificação Dirigida por Design: Fase 2 (LLM Engines & Governança)
**Módulo:** Motores de Inteligência Artificial & Pipeline de Governança  
**Autoridade Técnica:** `Dai_Vibe_Code` (Arquiteto-Chefe)  
**Data:** 16 de Outubro de 2026 | **Versão:** 1.0-Draft  
**Compatibilidade:** 100% Retrocompatível com a FASE 1 (PAM-IGA, LogAuditoria, AssinaturaDigital)  

---

## 1. Visão Geral da Arquitetura dos 4 Motores

A FASE 2 acopla 4 analisadores autônomos ao fluxo de submissão documental e contratual:

```
[ Upload do Documento / Minuta ]
               │
               ▼
   [ Pipeline Assíncrono O(1) ]
  ┌────────────┬────────────┬────────────┬────────────┐
  │            │            │            │            │
  ▼            ▼            ▼            ▼            ▼
[Engine 1]   [Engine 2]   [Engine 3]   [Engine 4]  (Paralelo asyncio)
Compliance   Structure    Redaction    Duplicity
 Checker      Analyzer    Suggester     Detector
(Regras/SoD) (Estrutura) (Sintaxe/Jur) (RapidFuzz)
  │            │            │            │            │
  └────────────┴────────────┴────────────┴────────────┘
               │
               ▼ (Cabresto Estrutural: Instructor + Pydantic)
   [ Relatório Consolidado de Governança ]
               │
               ▼
[ Gravação em LogAuditoria & Notificação RACI ]
```

---

## 2. Contratos de Dados & Cabresto Anti-Alucinação (Instructor / Pydantic)

Cada engine é estritamente proibida de responder texto livre. Suas saídas devem obedecer aos seguintes modelos:

```python
from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field

class StatusConformidade(str, Enum):
    CONFORME = "CONFORME"
    PENDENTE = "PENDENTE"
    NAO_CONFORME = "NAO_CONFORME"

class ApontamentoAuditoria(BaseModel):
    clausula_ou_secao: str = Field(..., description="Trecho ou referência do documento analisado")
    descricao_problema: str = Field(..., description="Explicação objetiva da divergência ou risco")
    severidade: str = Field(..., description="BAIXA | MEDIA | ALTA | CRITICA")
    sugestao_correcao: Optional[str] = Field(None, description="Sugestão de texto ou ajuste formal")

# 1. Output do Compliance Checker
class ComplianceResult(BaseModel):
    status: StatusConformidade
    score_aderencia: float = Field(..., ge=0.0, le=100.0, description="Percentual de conformidade às normas")
    violacoes_sod: List[str] = Field(default_factory=list, description="Violações de Segregação de Funções")
    apontamentos: List[ApontamentoAuditoria]
    justificativa_sintetica: str

# 2. Output do Structure Analyzer
class StructureResult(BaseModel):
    formato_valido: bool
    secoes_ausentes: List[str]
    consistencia_anexos: bool
    score_integridade: float = Field(..., ge=0.0, le=100.0)
    apontamentos: List[ApontamentoAuditoria]

# 3. Output do Redaction Suggester
class SugestaoRedacao(BaseModel):
    texto_original: str
    texto_proposto: str
    motivo_melhoria: str = Field(..., description="Clareza | Risco Jurídico | Padronização")

class RedactionResult(BaseModel):
    sugestoes: List[SugestaoRedacao]
    grau_melhoria_estimado: float

# 4. Output do Duplicity Detector (RapidFuzz Grounding)
class DuplicidadeDetectada(BaseModel):
    documento_id_existente: str
    similaridade_percentual: float = Field(..., ge=0.0, le=100.0)
    tipo_conflito: str = Field(..., description="TEXTO_IDENTICO | CNPJ_DUPLICADO | HOMONIMO")

class DuplicityResult(BaseModel):
    possui_duplicidade: bool
    itens_similares: List[DuplicidadeDetectada]
```

---

## 3. SLA de Performance & Matriz de Roteamento de Modelos

Para garantir a meta de **execução em $< 5$ segundos**, adota-se o roteamento de menor latência:

| Engine | Motor Primário | Motor Fallback (Offline) | Latência Estimada |
|---|---|---|---|
| **Compliance Checker** | Claude 3.5 Sonnet / Gemini Flash | DeepSeek-R1 (Ollama) | 1.8s a 2.5s |
| **Structure Analyzer** | Gemini 1.5 Flash | Qwen2.5-Coder (Ollama) | 1.2s a 1.9s |
| **Redaction Suggester**| Claude 3.5 Sonnet | SaulLM GGUF Local | 2.0s a 2.8s |
| **Duplicity Detector** | **RapidFuzz Local (`.venv`)** | RapidFuzz HDW Linux | **0.05s (Submétrica)** |

* **Execução em Paralelo:** As 4 análises são disparadas simultaneamente via `asyncio.gather`. O tempo total é limitado pelo motor mais lento ($\approx 2.8$s), mantendo-se com folga dentro do teto de 5 segundos.

---

## 4. Integração e Preservação da Fase 1

1. **Reutilização da Tabela `LogAuditoria`:**
   * Cada análise é registrada com `evento="ANALISE_GOVERNANCA_FASE2"`, gravando o hash SHA-256 do documento e o usuário autenticado via `Cofre PAM-IGA`.
2. **Workflow & Threads de Comentários (Semana 3):**
   * Os apontamentos de auditoria gerados pelas engines são transformados automaticamente em threads de discussão direcionadas aos responsáveis pela matriz RACI.
3. **Trava de Publicação (Semana 4):**
   * Documentos com `status == NAO_CONFORME` ou duplicidade acima de 85% têm a assinatura digital bloqueada até deliberação em quarentena.
