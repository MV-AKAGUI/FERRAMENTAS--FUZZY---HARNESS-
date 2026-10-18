import React, { useState } from "react";
import { ResultadoBuscaRAG } from "../types";
import { ApiService } from "../services/api";

interface BuscaWidgetProps {
  onSelectResultado?: (item: ResultadoBuscaRAG) => void;
}

export const BuscaWidget: React.FC<BuscaWidgetProps> = ({ onSelectResultado }) => {
  const [termo, setTermo] = useState("");
  const [resultados, setResultados] = useState<ResultadoBuscaRAG[]>([]);
  const [buscando, setBuscando] = useState(false);

  const handleBuscar = async () => {
    if (!termo.trim()) return;
    setBuscando(true);
    try {
      const data = await ApiService.buscaRAG(termo);
      setResultados(data);
    } finally {
      setBuscando(false);
    }
  };

  return (
    <div className="busca-widget" style={{ border: "1px solid #dcdcdc", borderRadius: "8px", padding: "16px", background: "#fff" }}>
      <h4 style={{ marginTop: 0 }}>Busca Semântica & Precedentes (RAG Forense)</h4>
      <div style={{ display: "flex", gap: "8px", marginBottom: "12px" }}>
        <input
          type="text"
          placeholder="Pesquisar cláusula, contrato ou processo..."
          value={termo}
          onChange={(e) => setTermo(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && handleBuscar()}
          style={{ flex: 1, padding: "8px", borderRadius: "4px", border: "1px solid #ccc" }}
        />
        <button
          onClick={handleBuscar}
          disabled={buscando}
          style={{ background: "#1F4E79", color: "#fff", border: "none", padding: "8px 16px", borderRadius: "4px", cursor: "pointer" }}
        >
          {buscando ? "Buscando..." : "Pesquisar RAG"}
        </button>
      </div>

      <div className="resultados-lista" style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
        {resultados.map((res) => (
          <div
            key={res.id}
            onClick={() => onSelectResultado && onSelectResultado(res)}
            style={{
              padding: "10px",
              border: "1px solid #eee",
              borderRadius: "4px",
              cursor: "pointer",
              background: "#fafafa"
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <strong>{res.nome}</strong>
              <span style={{ fontSize: "12px", color: "#1F4E79", fontWeight: "bold" }}>
                Similaridade: {(res.similarity_score * 100).toFixed(0)}%
              </span>
            </div>
            <p style={{ margin: "4px 0 0", fontSize: "12px", color: "#666" }}>{res.descricao}</p>
            <span style={{ fontSize: "11px", color: "#999" }}>Setor: {res.setor}</span>
          </div>
        ))}
      </div>
    </div>
  );
};
