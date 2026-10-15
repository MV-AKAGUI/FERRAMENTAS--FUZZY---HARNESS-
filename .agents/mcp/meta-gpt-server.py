#!/usr/bin/env python3
"""
MCP Server Wrapper para Meta_GPT_DAISUGI
Expõe Meta_GPT como ferramenta via stdio (Claude Code compatible)
"""

import json
import sys
import os
import subprocess
from pathlib import Path

META_GPT_WORKSPACE = Path(os.getenv("META_GPT_WORKSPACE", ".venv/meta_gpt"))
DAISUGI_ROOT = Path(__file__).parent.parent.parent

class MetaGPTServer:
    def __init__(self):
        self.workspace = META_GPT_WORKSPACE
        self.workspace.mkdir(parents=True, exist_ok=True)
        self.models = ["deepseek-r1", "qwen2.5-coder", "claude-opus-5-5"]

    def handle_request(self, request: dict) -> dict:
        """Processa requisição de Meta_GPT via JSON-RPC"""
        method = request.get("method")
        params = request.get("params", {})

        if method == "initialize":
            return self._init()
        elif method == "execute_workflow":
            return self._execute_workflow(params)
        elif method == "list_workflows":
            return self._list_workflows()
        elif method == "get_status":
            return self._get_status()
        else:
            return {"error": f"Unknown method: {method}"}

    def _init(self) -> dict:
        """Inicializa Meta_GPT"""
        try:
            return {
                "status": "initialized",
                "workspace": str(self.workspace),
                "available_models": self.models,
                "version": "DAISUGI-1.0.0"
            }
        except Exception as e:
            return {"error": str(e)}

    def _execute_workflow(self, params: dict) -> dict:
        """Executa workflow Meta_GPT"""
        task = params.get("task")
        model = params.get("model", "claude-opus-5-5")

        if not task:
            return {"error": "Task is required"}

        try:
            # Invocar Meta_GPT via subprocess
            cmd = [
                "python",
                "-m", "metagpt.cli",
                "--task", task,
                "--model", model,
                "--workspace", str(self.workspace),
                "--headless"
            ]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=str(DAISUGI_ROOT),
                timeout=300
            )

            return {
                "status": "completed" if result.returncode == 0 else "failed",
                "output": result.stdout,
                "error": result.stderr if result.returncode != 0 else None,
                "task": task,
                "model": model
            }
        except subprocess.TimeoutExpired:
            return {"error": "Workflow timeout (300s exceeded)"}
        except Exception as e:
            return {"error": str(e)}

    def _list_workflows(self) -> dict:
        """Lista workflows disponíveis"""
        workflows_dir = self.workspace / "workflows"
        if not workflows_dir.exists():
            return {"workflows": []}

        workflows = [
            f.stem for f in workflows_dir.glob("*.json")
        ]
        return {"workflows": workflows}

    def _get_status(self) -> dict:
        """Status do servidor Meta_GPT"""
        return {
            "status": "running",
            "workspace": str(self.workspace),
            "uptime": "active"
        }

def main():
    """Entry point para MCP (stdio communication)"""
    server = MetaGPTServer()

    # Modo interativo: ler JSON do stdin
    for line in sys.stdin:
        try:
            request = json.loads(line.strip())
            response = server.handle_request(request)
            print(json.dumps(response))
            sys.stdout.flush()
        except json.JSONDecodeError:
            print(json.dumps({"error": "Invalid JSON"}))
            sys.stdout.flush()
        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    main()
