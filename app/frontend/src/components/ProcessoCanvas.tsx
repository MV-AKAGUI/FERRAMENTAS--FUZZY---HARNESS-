import React, { useState } from "react";
import { GraphBPM, NodeBPM } from "../types";

export const SETORES_PAM = [
  "Presidência",
  "Diretoria Jurídica",
  "Diretoria Financeira",
  "Auditoria Pericial",
  "Compliance & DPO",
  "Engenharia & TI",
  "Controladoria",
  "Recursos Humanos",
  "Comercial / Vendas",
  "Operações",
  "Risco & Crédito",
  "Suprimentos",
  "Relações Institucionais",
  "Atendimento / Sac"
];

interface ProcessoCanvasProps {
  graph: GraphBPM;
  onUpdateGraph?: (newGraph: GraphBPM) => void;
  readOnly?: boolean;
}

export const ProcessoCanvas: React.FC<ProcessoCanvasProps> = ({ graph, onUpdateGraph, readOnly = false }) => {
  const [nodes, setNodes] = useState<NodeBPM[]>(graph.nodes || []);
  const [selectedSetor, setSelectedSetor] = useState<string>(SETORES_PAM[0]);

  const handleAddNode = () => {
    if (readOnly) return;
    const newNode: NodeBPM = {
      id: "node_" + Math.random().toString(36).substring(2, 7),
      type: "task",
      label: `Etapa ${selectedSetor}`,
      setor: selectedSetor,
      position: { x: 100 + nodes.length * 20, y: 100 + nodes.length * 20 }
    };
    const updated = [...nodes, newNode];
    setNodes(updated);
    if (onUpdateGraph) {
      onUpdateGraph({ ...graph, nodes: updated });
    }
  };

  return (
    <div className="processo-canvas-container" style={{ border: "1px solid #ccc", padding: "16px", borderRadius: "8px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "12px" }}>
        <h3>Canvas de Modelagem de Processos BPM (14 Setores PAM)</h3>
        {!readOnly && (
          <div style={{ display: "flex", gap: "8px" }}>
            <select value={selectedSetor} onChange={(e) => setSelectedSetor(e.target.value)}>
              {SETORES_PAM.map((setor) => (
                <option key={setor} value={setor}>
                  {setor}
                </option>
              ))}
            </select>
            <button onClick={handleAddNode} style={{ background: "#1F4E79", color: "#fff", border: "none", padding: "6px 12px", borderRadius: "4px" }}>
              + Adicionar Nó ao Setor
            </button>
          </div>
        )}
      </div>

      <div className="canvas-grid" style={{ minHeight: "300px", background: "#f8f9fa", borderRadius: "6px", padding: "16px", display: "flex", flexWrap: "wrap", gap: "12px" }}>
        {nodes.map((node) => (
          <div
            key={node.id}
            style={{
              background: "#fff",
              border: "2px solid #1F4E79",
              borderRadius: "6px",
              padding: "10px",
              minWidth: "150px",
              boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
            }}
          >
            <span style={{ fontSize: "10px", color: "#888", display: "block" }}>{node.setor || "Geral"}</span>
            <strong>{node.label}</strong>
            <div style={{ fontSize: "11px", color: "#555", marginTop: "4px" }}>Tipo: {node.type}</div>
          </div>
        ))}
      </div>
    </div>
  );
};
