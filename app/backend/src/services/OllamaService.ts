export class OllamaService {
  private static baseUrl = process.env.OLLAMA_BASE_URL || "http://127.0.0.1:11434";

  public static async queryModel(model: string, prompt: string, timeoutMs: number = 20000): Promise<string> {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const response = await fetch(`${this.baseUrl}/api/generate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model, prompt, stream: false }),
        signal: controller.signal
      });

      if (!response.ok) {
        throw new Error(`Erro Ollama (${model}): ${response.statusText}`);
      }

      const data: any = await response.json();
      return data.response;
    } finally {
      clearTimeout(timer);
    }
  }

  public static async validateBPMWithCascade(prompt: string): Promise<{ modelUsed: string; response: string }> {
    // Cascata de modelos locais: DeepSeek-R1 -> Qwen2.5 -> SaulLM
    const models = ["deepseek-r1:8b", "qwen2.5:latest", "saullm:latest"];

    for (const model of models) {
      try {
        const res = await this.queryModel(model, prompt, 15000);
        return { modelUsed: model, response: res };
      } catch (err) {
        console.warn(`[OllamaService] Falha no modelo ${model}, tentando próximo na cascata...`);
      }
    }

    throw new Error("Todos os modelos na cascata do Ollama falharam.");
  }
}
