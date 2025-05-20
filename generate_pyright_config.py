import os
import json
import sysconfig
from pathlib import Path

def find_venv_site_packages(venv_dir):
    """
    Given a path to a venv (e.g., worktrees/foo/.venv),
    return the site-packages path inside it.
    """
    try:
        python_version = f"python{sysconfig.get_python_version()}"
        sp = Path(venv_dir) / "lib" / python_version / "site-packages"
        return str(sp.resolve()) if sp.exists() else None
    except Exception:
        return None

def find_all_venvs(base_dir):
    """
    Recursively find all `.venv` directories under worktrees/
    """
    venv_paths = []
    for root, dirs, files in os.walk(base_dir):
        if ".venv" in dirs:
            venv_path = os.path.join(root, ".venv")
            site_packages = find_venv_site_packages(venv_path)
            if site_packages:
                venv_paths.append(site_packages)
            dirs.remove(".venv")  # Don't walk inside venvs
    return venv_paths

def generate_pyright_config(venv_site_packages_list, output_path):
    config = {
        "extraPaths": venv_site_packages_list,
    }

    with open(output_path, "w") as f:
        json.dump(config, f, indent=2)

    print(f"✅ Generated {output_path} with {len(venv_site_packages_list)} extraPaths.")

if __name__ == "__main__":
    base_dir = Path(".").resolve()
    venvs = find_all_venvs(base_dir)
    if not venvs:
        print("⚠️ No venvs found.")
    else:
        generate_pyright_config(venvs, base_dir / "pyrightconfig.json")
