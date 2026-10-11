"""
Bridge Central Daisugi - Invocador Unificado sob Demanda (Homeostase)
Permite executar tarefas de RapidFuzz, Docling e MetaGPT cirurgicamente
sem sobrecarregar o sistema.
"""
import sys
import json
import argparse

def run_rapidfuzz(query, choices, threshold=80.0):
    try:
        from rapidfuzz import process, fuzz
        results = process.extract(query, choices, scorer=fuzz.token_sort_ratio, score_cutoff=threshold)
        return [{"match": r[0], "score": float(r[1]), "index": int(r[2])} for r in results]
    except Exception as e:
        return {"error": str(e)}

def run_docling_inspect():
    try:
        import docling
        return {"status": "available", "version": getattr(docling, "__version__", "installed")}
    except Exception as e:
        return {"status": "unavailable", "detail": str(e)}

def run_metagpt_status():
    import os
    metagpt_dir = r"c:\Users\Ronaldo Akagui.SUG00245\DAISUGI_TECNOLOGIAS\Meta_GPT_DAISUGI"
    has_venv = os.path.isdir(os.path.join(metagpt_dir, ".venv"))
    return {
        "workspace": metagpt_dir,
        "environment_configured": has_venv,
        "status": "ready"
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Daisugi Ecosystem Tool Bridge")
    parser.add_argument("--action", required=True, choices=["fuzz", "docling-status", "metagpt-status"])
    parser.add_argument("--query", default="")
    parser.add_argument("--choices", default="[]")
    parser.add_argument("--threshold", type=float, default=80.0)

    args = parser.parse_args()

    if args.action == "fuzz":
        try:
            choices = json.loads(args.choices)
        except Exception:
            choices = [c.strip() for c in args.choices.split(",") if c.strip()]
        res = run_rapidfuzz(args.query, choices, args.threshold)
        print(json.dumps(res, ensure_ascii=False, indent=2))
    elif args.action == "docling-status":
        print(json.dumps(run_docling_inspect(), ensure_ascii=False, indent=2))
    elif args.action == "metagpt-status":
        print(json.dumps(run_metagpt_status(), ensure_ascii=False, indent=2))
