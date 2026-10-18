import React from "react";
import { ResultadoValidacao } from "../types";

interface ValidacaoPanelProps {
  validacao: ResultadoValidacao | null;
  onExecutarValidacao?: () => void;
  loading?: boolean;
}

export const ValidacaoPanel: React.FC<ValidacaoPanelProps> = ({ validacao, onExecutarValidacao, loading = false }) => {
  return (
    <div className="validacao-panel" style={{ border: "1px solid #dcdcdc", borderRadius: "8px", padding: "16px", background: "#fff" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "12px" }}>
        <h4 style={{ margin: 0 }}>Painel de Auditoria dos 10 Travões Periciais</h4>
        {onExecutarValidacao && (
          <button
            onClick={onExecutarValidacao}
            disabled={loading}
            style={{
              background: "#28a745",
              color: "#fff",
              border: "none",
              padding: "6px 14px",
              borderRadius: "4px",
              cursor: loading ? "not-allowed" : "pointer"
            }}
          >
            {loading ? "Validando..." : "Executar 10 Travões"}
          </button>
        )}
      </div>

      {validacao ? (
        <div>
          <div style={{ marginBottom: "12px", display: "flex", alignItems: "center", gap: "10px" }}>
            <span style={{ fontWeight: "bold" }}>Score de Conformidade:</span>
            <span style={{ color: validacao.score === 100 ? "#28a745" : "#dc3545", fontWeight: "bold", fontSize: "16px" }}>
              {validacao.score}%
            </span>
            <span style={{ fontSize: "12px", color: "#666" }}>({validacao.passou_todos ? "Aprovado em todos os travões" : "Travões pendentes"})</span>
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
            {validacao.travoes.map((travao) => (
              <div
                key={travao.id}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "8px 12px",
                  borderRadius: "4px",
                  background: travao.passou ? "#f0fff4" : "#fff5f5",
                  borderLeft: `4px solid ${travao.passou ? "#28a745" : "#dc3545"}`
                }}
              >
                <span>
                  <strong>#{travao.id} {travao.nome}</strong>: {travao.mensagem}
                </span>
                <span>{travao.passou ? "✅ OK" : "❌ Falha"}</span>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <p style={{ color: "#777", fontStyle: "italic" }}>Nenhuma validação executada para este processo. Clique no botão acima para rodar a auditoria.</p>
      )}
    </div>
  );
};
