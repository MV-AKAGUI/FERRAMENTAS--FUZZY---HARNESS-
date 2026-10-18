import { useState, useEffect, useCallback } from "react";
import { ProcessoBPM, ResultadoValidacao, GraphBPM, NodeBPM, EdgeBPM } from "../types";
import { ApiService } from "../services/api";

export function useBPM() {
  const [processos, setProcessos] = useState<ProcessoBPM[]>([]);
  const [processoAtual, setProcessoAtual] = useState<ProcessoBPM | null>(null);
  const [validacao, setValidacao] = useState<ResultadoValidacao | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const carregarProcessos = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await ApiService.listarProcessos();
      setProcessos(data);
      if (data.length > 0 && !processoAtual) {
        setProcessoAtual(data[0]);
      }
    } catch (err: any) {
      setError(err.message || "Erro ao listar processos");
    } finally {
      setLoading(false);
    }
  }, [processoAtual]);

  useEffect(() => {
    carregarProcessos();
  }, [carregarProcessos]);

  const validarGrafoAtual = async (graph: GraphBPM) => {
    setLoading(true);
    setError(null);
    try {
      const res = await ApiService.validarProcesso(graph);
      setValidacao(res);
      return res;
    } catch (err: any) {
      setError(err.message || "Erro na validação do grafo");
      return null;
    } finally {
      setLoading(false);
    }
  };

  const aprovarProcessoAtual = async (userId: string, concordancia: boolean) => {
    if (!processoAtual) return null;
    setLoading(true);
    try {
      const res = await ApiService.aprovarProcesso(processoAtual.id, userId, concordancia);
      await carregarProcessos();
      return res;
    } catch (err: any) {
      setError(err.message || "Erro ao submeter aprovação");
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    processos,
    processoAtual,
    setProcessoAtual,
    validacao,
    loading,
    error,
    carregarProcessos,
    validarGrafoAtual,
    aprovarProcessoAtual
  };
}
