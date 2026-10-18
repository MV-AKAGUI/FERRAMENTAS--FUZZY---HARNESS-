export type StatusProcesso = "rascunho" | "validado" | "aprovado" | "rejeitado";

export interface NodeBPM {
  id: string;
  type: string;
  label: string;
  setor?: string;
  data?: Record<string, any>;
  position?: { x: number; y: number };
}

export interface EdgeBPM {
  id: string;
  source: string;
  target: string;
  label?: string;
}

export interface GraphBPM {
  nodes: NodeBPM[];
  edges: EdgeBPM[];
}

export interface ProcessoBPM {
  id: string;
  nome: string;
  descricao?: string;
  status: StatusProcesso;
  graph: GraphBPM;
  created_by: string;
  created_at: string;
  updated_at: string;
  hash_sha256?: string;
}

export interface TravaoItem {
  id: number;
  nome: string;
  passou: boolean;
  mensagem: string;
}

export interface ResultadoValidacao {
  passou_todos: boolean;
  score: number;
  travoes: TravaoItem[];
  data_validacao: string;
}

export interface AssinaturaDigital {
  hash_original: string;
  hash_assinatura: string;
  signer_id: string;
  timestamp_assinatura: string;
  conformidade_lei: string;
}

export interface RespostaAprovacao {
  status: StatusProcesso;
  processo_id: string;
  assinatura?: AssinaturaDigital;
  mensagem?: string;
}

export interface ResultadoBuscaRAG {
  id: string;
  nome: string;
  descricao: string;
  similarity_score: number;
  setor: string;
}

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
