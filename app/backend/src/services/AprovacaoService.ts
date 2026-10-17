import { ProcessoService } from "../services/ProcessoService";
import { AssinaturaSHA256 } from "../security/AssinaturaSHA256";
import { TravaoService } from "../services/TravaoService";

export class AprovacaoService {
  public static async approve(processoId: string, userId: string, concordancia: boolean): Promise<any> {
    const processo = await ProcessoService.findById(processoId);
    if (!processo) {
      throw new Error("Processo não encontrado");
    }

    // Regra Maker / Checker mandatória: o criador não pode aprovar seu próprio processo
    if (processo.created_by === userId) {
      throw new Error("Violação Maker/Checker: Criador não pode assinar a aprovação pericial.");
    }

    if (!concordancia) {
      await ProcessoService.update(processoId, { status: "rejeitado" });
      return { status: "rejeitado", mensagem: "Processo rejeitado pelo revisor." };
    }

    // Executa validação de travões
    const validacao = await TravaoService.executeTravoes(processo.graph);
    if (!validacao.passou_todos) {
      throw new Error("Não é possível aprovar processo com travões pendentes.");
    }

    const hashOrig = AssinaturaSHA256.calcularHash(processo);
    const assinatura = AssinaturaSHA256.criarAssinatura(hashOrig, userId);

    await ProcessoService.update(processoId, {
      status: "aprovado",
      hash_sha256: assinatura.hash_assinatura
    });

    return {
      status: "aprovado",
      processo_id: processoId,
      assinatura
    };
  }
}
