import crypto from "crypto";

export class AssinaturaSHA256 {
  public static calcularHash(payload: any): string {
    const serialized = typeof payload === "string" ? payload : JSON.stringify(payload);
    return crypto.createHash("sha256").update(serialized, "utf8").digest("hex");
  }

  public static criarAssinatura(hashOriginal: string, userId: string, timestamp: string = new Date().toISOString()): {
    hash_original: string;
    hash_assinatura: string;
    signer_id: string;
    timestamp_assinatura: string;
    conformidade_lei: string;
  } {
    const dadosCombinados = `${hashOriginal}:${userId}:${timestamp}`;
    const hashAssinatura = crypto.createHash("sha256").update(dadosCombinados, "utf8").digest("hex");

    return {
      hash_original: hashOriginal,
      hash_assinatura: hashAssinatura,
      signer_id: userId,
      timestamp_assinatura: timestamp,
      conformidade_lei: "Lei 14.063/2020 - Assinatura Eletrônica Avançada"
    };
  }

  public static validarHash(payload: any, hashEsperado: string): boolean {
    const hashCalculado = this.calcularHash(payload);
    return hashCalculado === hashEsperado;
  }
}
