import subprocess
import json
import urllib.request
import urllib.error

try:
    from antigravity.agents import Agent, tool
except ImportError:
    # Fallback para execução stand-alone ou ambiente sem SDK global montado
    class Agent:
        def __init__(self, name, system_prompt):
            self.name = name
            self.system_prompt = system_prompt

    def tool(func):
        return func


class PMOOrchestrator(Agent):
    """
    Agente PMO responsável por gerenciar as sprints e delegar execuções pesadas
    de código para o Claude Code ou para as LLMs locais (Ollama).
    """

    @tool
    def delegar_para_claude_code(self, instrucao: str) -> str:
        """Executa comandos técnicos via Claude Code CLI na raiz do projeto."""
        try:
            res = subprocess.run(["claude", "-p", instrucao], capture_output=True, text=True, check=True)
            return res.stdout
        except Exception as e:
            return f"Erro ao executar Claude Code: {str(e)}"

    @tool
    def delegar_para_llm_local(self, prompt: str, modelo: str = "llama3") -> str:
        """Envia requisições de processamento para a LLM local no Ollama sem gastar tokens da nuvem."""
        try:
            data = json.dumps({"model": modelo, "prompt": prompt, "stream": False}).encode("utf-8")
            req = urllib.request.Request("http://localhost:11434/api/generate", data=data, headers={"Content-Type": "application/json"})
            with urllib.request.urlopen(req, timeout=120) as resp:
                res_data = json.loads(resp.read().decode("utf-8"))
                return res_data.get("response", "Sem resposta")
        except Exception as e:
            return f"Erro ao conectar na LLM local: {str(e)}"


pmo = PMOOrchestrator(
    name="Antigravity_PMO",
    system_prompt="Atue como PMO do projeto. Planeje as tarefas e delegue tarefas técnicas pesadas ao Claude Code ou LLMs locais."
)

if __name__ == "__main__":
    print(f"Harness PMO carregado com sucesso: {pmo.name}")

