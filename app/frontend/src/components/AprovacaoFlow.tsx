import React, { useState } from "react";
import { ProcessoBPM, RespostaAprovacao } from "../types";

interface AprovacaoFlowProps {
  processo: ProcessoBPM;
  currentUserId: string;
  onDecidir: (concordancia: boolean) => Promise<RespostaAprovacao | null>;
}

export const AprovacaoFlow: React.FC<AprovacaoFlowProps> = ({ processo, currentUserId, onDecidir }) => {
  const [decidindo, setDecidindo] = useState(false);
  const [resultado, setResultado] = useState<RespostaAprovacao | null>(null);

  const isMaker = processo.created_by === currentUserId;

  const handleAction = async (concordancia: boolean) => {
    setDecidindo(true);
    try {
      const res = await onDecidir(concordancia);
      setResultado(res);
    } finally {
      setDecidindo(false);
    }
  };

  return (
    <div className="aprovacao-flow" style={{ border: "1px solid #dcdcdc", borderRadius: "8px", padding: "16px", background: "#fff" }}>
      <h4>Fluxo de Aprovação e Segregação de Funções (Maker/Checker)</h4>

      <div style={{ marginBottom: "12px", fontSize: "14px", lineHeight: "1.6" }}>
        <div><strong>Processo:</strong> {processo.nome}</div>
        <div><strong>Status Atual:</strong> <span style={{ textTransform: "uppercase", fontWeight: "bold" }}>{processo.status}</span></div>
        <div><strong>Autor (Maker):</strong> {processo.created_by}</div>
        <div><strong>Usuário Ativo:</strong> {currentUserId}</div>
      </div>

      {isMaker ? (
        <div style={{ padding: "10px", background: "#fff3cd", border: "1px solid #ffeeba", borderRadius: "4px", color: "#856404" }}>
          ⚠️ <strong>Regra de SoD:</strong> Como autor (Maker) deste processo, você não pode assinar a aprovação final. Um revisor com cadeira de Diretoria (Checker) deve homologar.
        </div>
      ) : (
        <div>
          <p style={{ margin: "8px 0" }}>Você está autorizado como revisor pericial. Escolha sua decisão:</p>
          <div style={{ display: "flex", gap: "10px" }}>
            <button
              onClick={() => handleAction(true)}
              disabled={decidindo}
              style={{ background: "#28a745", color: "#fff", border: "none", padding: "8px 16px", borderRadius: "4px", cursor: "pointer" }}
            >
              {decidindo ? "Assinando..." : "✅ Homologar & Assinar (Lei 14.063)"}
            </button>
            <button
              onClick={() => handleAction(false)}
              disabled={decidindo}
              style={{ background: "#dc3545", color: "#fff", border: "none", padding: "8px 16px", borderRadius: "4px", cursor: "pointer" }}
            >
              {decidindo ? "Processando..." : "❌ Rejeitar Processo"}
            </button>
          </div>
        </div>
      )}

      {resultado && (
        <div style={{ marginTop: "12px", padding: "10px", background: resultado.status === "aprovado" ? "#d4edda" : "#f8d7da", borderRadius: "4px" }}>
          <strong>Resultado:</strong> Processo {resultado.status} com sucesso!
          {resultado.assinatura && (
            <div style={{ fontSize: "11px", marginTop: "4px", color: "#333" }}>
              Hash SHA-256: <code>{resultado.assinatura.hash_assinatura.substring(0, 24)}...</code>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
