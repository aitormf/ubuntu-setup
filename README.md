# Configs — Instalación centralizada

Este repositorio incluye scripts para facilitar la instalación de dependencias y aplicaciones en una máquina Linux.

## Ejecutar `config.sh`

1. Asegúrate de que `config.sh` es ejecutable (solo la primera vez):

```bash
chmod +x ./config.sh
```

2. Ejecuta el script y elige una opción del menú:

```bash
./config.sh
```

Opciones disponibles:
- `1` — Instalar todo: ejecuta el instalador de dependencias y luego `install.py` (menú interactivo para elegir aplicaciones).
- `2` — Instalar aplicaciones: ejecuta `install.py` directamente.
- `3` — Instalar dependencias: ejecuta el script de dependencias (requiere sudo).

Nota: el instalador de dependencias (`scripts/install-dependences.sh`) ejecuta acciones que requieren privilegios; se usará `sudo` cuando sea necesario.

## Añadir nuevos instaladores

1. Crea un script en la carpeta adecuada, por ejemplo:

```
scripts/ide/install-nombre.sh
```

2. Haz que el script sea idempotente y que compruebe si la aplicación ya existe antes de instalar.

3. Añade una entrada en `config.json` bajo la sección correspondiente (por ejemplo `IDE`, `OTHERS`, `TERMINAL-APPS`, `ZSH`):

```json
"MiApp": {
  "scriptPath": "scripts/ide/install-miapp.sh",
  "urlInfo": "https://ejemplo.com/miapp"
}
```

4. Si quieres que `install.py` lo muestre, asegúrate de que `scriptPath` apunta a la ruta correcta relativa al root del repo.

5. Opcional: prueba manualmente el script:

```bash
bash scripts/ide/install-miapp.sh
```

## Cómo actualizar este repositorio

- Añade nuevos scripts en `scripts/` y actualiza `config.json`.
- Si cambia la estructura (por ejemplo renombrar `scritps/` a `scripts/`), actualiza las rutas en `config.json`.
- Haz commits con mensajes claros, por ejemplo: `git add . && git commit -m "feat: add install-miapp"`.

## Restaurar backups

Algunos instaladores que sobrescriben configuración de usuario pueden crear backups antes de modificar ficheros. Consulta cada script para saber la ubicación del backup y cómo restaurarlo.
