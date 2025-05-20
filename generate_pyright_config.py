import os
import json
from pathlib import Path

MONOREPO_ROOT = Path(__file__).resolve().parent

def is_python_project(dir_path):
    return (dir_path / "pyproject.toml").is_file() and (dir_path / ".venv").is_dir()

def find_projects(root):
    projects = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirpath = Path(dirpath)
        if ".venv" in dirnames:
            if is_python_project(dirpath):
                projects.append(dirpath)
            # Don't recurse into .venv directories
            dirnames.remove(".venv")
    return projects

def generate_pyright_config(projects):
    execution_envs = []
    for project_path in projects:
        src_path = project_path / "src"
        root_for_pyright = src_path if src_path.exists() else project_path
        rel_src = os.path.relpath(root_for_pyright, MONOREPO_ROOT)
        rel_venv = os.path.relpath(project_path / ".venv", MONOREPO_ROOT)

        execution_envs.append({
            "root": rel_src,
            "extraPaths": [rel_src],
            "venv": rel_venv
        })

    config = {
        "typeCheckingMode": "strict",
        "exclude": ["**/.venv"],
        "executionEnvironments": execution_envs
    }

    config_path = MONOREPO_ROOT / "pyrightconfig.json"
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    print(f"✅ Generated pyrightconfig.json with {len(execution_envs)} environments")

if __name__ == "__main__":
    projects = find_projects(MONOREPO_ROOT)
    generate_pyright_config(projects)
