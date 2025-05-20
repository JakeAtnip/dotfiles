import os
import json
import sysconfig
from pathlib import Path
from typing import List

def find_venv_site_packages(venv_dir: Path) -> Path:
    """
    Given a path to a venv (e.g., worktrees/foo/.venv),
    return the site-packages path inside it.

    Raises:
        FileNotFoundError: If the site-packages path does not exist.
    """
    python_version = f"python{sysconfig.get_python_version()}"
    site_packages = venv_dir / "lib" / python_version / "site-packages"
    if not site_packages.exists():
        raise FileNotFoundError(f"Site-packages not found in {venv_dir}")
    return site_packages.resolve()

def find_all_venvs(base_dir: Path) -> List[Path]:
    """
    Recursively find all `.venv` directories under base_dir
    and return their resolved site-packages paths.

    Raises:
        FileNotFoundError: If no valid site-packages dirs are found.
    """
    site_packages_paths: List[Path] = []

    for root, dirs, _ in os.walk(base_dir):
        if ".venv" in dirs:
            venv_path = Path(root) / ".venv"
            site_packages = find_venv_site_packages(venv_path)
            site_packages_paths.append(site_packages)
            dirs.remove(".venv")  # Skip descending into the venv itself

    if not site_packages_paths:
        raise FileNotFoundError("No valid .venv site-packages directories found.")
    
    return site_packages_paths

def generate_pyright_config(site_packages_list: List[Path], output_path: Path) -> None:
    config = {
        "extraPaths": [str(p) for p in site_packages_list],
    }

    with output_path.open("w") as f:
        json.dump(config, f, indent=2)

    print(f"✅ Generated {output_path} with {len(site_packages_list)} extraPaths.")

if __name__ == "__main__":
    try:
        base_dir = Path(".").resolve()
        site_packages = find_all_venvs(base_dir)
        generate_pyright_config(site_packages, base_dir / "pyrightconfig.json")
    except Exception as e:
        print(f"❌ Error: {e}")
        exit(1)
