#!/usr/bin/env python3
"""Interactive installer generator.

Reads `config.json`, lets the user choose items to install, writes a shell
script that runs the selected installers in order, then executes it.

Usage: python3 install.py

Options presented interactively. The generated shell script is created under
/tmp and removed after successful run.
"""

import json
import os
import shlex
import subprocess
import sys
import tempfile
from datetime import datetime

ROOT = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(ROOT, "config.json")


def load_config(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def flatten_items(config):
    # Return list of tuples (display_name, scriptPath)
    items = []
    for section_name, section in config.items():
        if isinstance(section, dict):
            for name, meta in section.items():
                script = meta.get("scriptPath")
                display = f"{section_name}/{name}"
                items.append((display, script))
    return items


def sectioned_items(config):
    # Return ordered dict-like list: [(section_name, [(name, script, url), ...]), ...]
    sections = []
    for section_name, section in config.items():
        entries = []
        if isinstance(section, dict):
            for name, meta in section.items():
                script = meta.get("scriptPath")
                url = meta.get("urlInfo", "")
                entries.append((name, script, url))
        sections.append((section_name, entries))
    return sections


def print_menu(items):
    print("Selecciona los números de los elementos a instalar (coma separada, rangos 1-3).")
    print("Usa 'a' para seleccionar todos, 'q' para salir.")
    for i, (display, script) in enumerate(items, start=1):
        print(f"  {i:2d}) {display} -> {script}")


def parse_selection(choice, n):
    choice = choice.strip().lower()
    if choice in ("q", "quit", "exit"):
        return None
    if choice in ("a", "all"):
        return list(range(1, n + 1))
    parts = [p.strip() for p in choice.split(",") if p.strip()]
    result = set()
    for p in parts:
        if "-" in p:
            try:
                a, b = p.split("-", 1)
                a_i = int(a)
                b_i = int(b)
                for k in range(min(a_i, b_i), max(a_i, b_i) + 1):
                    if 1 <= k <= n:
                        result.add(k)
            except ValueError:
                continue
        else:
            try:
                idx = int(p)
                if 1 <= idx <= n:
                    result.add(idx)
            except ValueError:
                continue
    return sorted(result)


def confirm(prompt="¿Continuar?"):
    resp = input(f"{prompt} [y/N]: ").strip().lower()
    return resp in ("y", "yes")


def build_shell_script(selected_scripts):
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    tmp_path = os.path.join(tempfile.gettempdir(), f"install_selected_{ts}.sh")
    lines = []
    lines.append("#!/usr/bin/env bash")
    lines.append("set -euo pipefail")
    lines.append("")
    lines.append("echo 'Running selected installers'")
    lines.append("")
    for disp, script in selected_scripts:
        abs_path = os.path.join(ROOT, script) if not os.path.isabs(script) else script
        abs_path = os.path.abspath(abs_path)
        if not os.path.exists(abs_path):
            lines.append(f"echo 'WARNING: script not found: {shlex.quote(abs_path)}' >&2")
            continue
        lines.append(f"echo '=== Running: {disp} ({abs_path}) ==='")
        # Run each installer in its own bash invocation so they don't pollute the generator script
        lines.append(f"bash {shlex.quote(abs_path)}")
        lines.append("")
    content = "\n".join(lines) + "\n"
    with open(tmp_path, "w", encoding="utf-8") as f:
        f.write(content)
    os.chmod(tmp_path, 0o755)
    return tmp_path


def run_script(path):
    print(f"Ejecutando {path} ...")
    try:
        subprocess.run(["bash", path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"La ejecución falló con código: {e.returncode}")
        raise


def main():
    if not os.path.exists(CONFIG_PATH):
        print(f"No se encontró el fichero de configuración: {CONFIG_PATH}")
        sys.exit(1)
    config = load_config(CONFIG_PATH)
    items = flatten_items(config)
    if not items:
        print("No hay scripts configurados.")
        sys.exit(0)


    print("Instalador interactivo (sección por sección)\n")
    sections = sectioned_items(config)
    selected = []

    for section_name, entries in sections:
        if not entries:
            continue
        print(f"\n=== Sección: {section_name} ===")
        for i, (name, script, url) in enumerate(entries, start=1):
            shown = url if url else script
            print(f"  {i:2d}) {name} -> {shown}")

        while True:
            resp = input("Instalar toda la sección? (y = todos, n = ninguno, s = seleccionar items): ").strip().lower()
            if resp in ("y", "yes"):
                for name, script, url in entries:
                    display = f"{section_name}/{name}"
                    selected.append((display, script))
                break
            elif resp in ("n", "no"):
                break
            elif resp in ("s", "select"):
                sel_input = input("Selecciona números (ej. 1,3-4) o 'a' para todos: ").strip()
                sel = parse_selection(sel_input, len(entries))
                if sel is None:
                    print("Volviendo a la sección.")
                    break
                if not sel:
                    print("No se seleccionó nada en esta sección.")
                    break
                for i in sel:
                    name, script, url = entries[i - 1]
                    display = f"{section_name}/{name}"
                    selected.append((display, script))
                break
            else:
                print("Opción no válida. Responde 'y', 'n' o 's'.")

    if not selected:
        print("No se seleccionó nada para instalar. Saliendo.")
        sys.exit(0)

    print("\nHas seleccionado los siguientes elementos:")
    for disp, script in selected:
        # attempt to show urlInfo if available in config
        # lookup script in config to find urlInfo
        url = None
        for section in config.values():
            if isinstance(section, dict):
                for meta in section.values():
                    if meta.get("scriptPath") == script:
                        url = meta.get("urlInfo", "")
                        break
                if url is not None:
                    break
        if url:
            print(f" - {disp} -> {script} ({url})")
        else:
            print(f" - {disp} -> {script}")

    if not confirm("Crear y ejecutar el script con las selecciones?"):
        print("Aborted by user")
        sys.exit(0)

    tmp_script = build_shell_script(selected)
    print(f"Script creado en: {tmp_script}")

    try:
        run_script(tmp_script)
    except Exception:
        print("Error durante la ejecución. El script se mantiene en:", tmp_script)
        sys.exit(1)

    # If everything succeeded, remove the temp script
    try:
        os.remove(tmp_script)
        print("Instalación completada y script temporal eliminado.")
    except OSError:
        print("Instalación completada. No se pudo eliminar el script temporal:", tmp_script)


if __name__ == "__main__":
    main()
