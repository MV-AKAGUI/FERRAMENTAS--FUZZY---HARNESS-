export interface ProcessoBPM {
  id: string;
  nome: string;
  descricao?: string;
  status: "rascunho" | "validado" | "aprovado" | "rejeitado";
  graph: any;
  created_by: string;
  created_at: string;
  updated_at: string;
  hash_sha256?: string;
}

const memoryStore = new Map<string, ProcessoBPM>();

export class ProcessoService {
  public static async create(data: { nome: string; descricao?: string; graph: any; user_id: string }): Promise<ProcessoBPM> {
    const id = "proc_" + Math.random().toString(36).substring(2, 9);
    const now = new Date().toISOString();
    const processo: ProcessoBPM = {
      id,
      nome: data.nome,
      descricao: data.descricao,
      status: "rascunho",
      graph: data.graph,
      created_by: data.user_id,
      created_at: now,
      updated_at: now
    };
    memoryStore.set(id, processo);
    return processo;
  }

  public static async findById(id: string): Promise<ProcessoBPM | null> {
    return memoryStore.get(id) || null;
  }

  public static async update(id: string, updates: Partial<ProcessoBPM>): Promise<ProcessoBPM | null> {
    const current = memoryStore.get(id);
    if (!current) return null;
    const updated = { ...current, ...updates, updated_at: new Date().toISOString() };
    memoryStore.set(id, updated);
    return updated;
  }

  public static async list(): Promise<ProcessoBPM[]> {
    return Array.from(memoryStore.values());
  }
}
