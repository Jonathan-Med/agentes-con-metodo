#!/usr/bin/env bash
# Prueba que la receta del tablero da la misma carpeta desde el repo, un worktree hermano y uno anidado.
set -euo pipefail
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
base="$tmp/repos con espacio"; mkdir -p "$base/proyecto"
git -C "$base/proyecto" init -q -b main
git -C "$base/proyecto" -c user.name=t -c user.email=t@t commit -q --allow-empty -m inicio
git -C "$base/proyecto" worktree add -q "$base/proyecto-rama" -b rama
mkdir -p "$base/proyecto/.claude/worktrees"
git -C "$base/proyecto" worktree add -q "$base/proyecto/.claude/worktrees/anidado" -b anidado
ruta() {
  ( cd "$1"
    comun=$(git rev-parse --path-format=absolute --git-common-dir)
    repo=$(cd "$(dirname "$comun")" && pwd)
    echo "$(dirname "$repo")/_coordinacion/$(basename "$repo")" )
}
esperado="$(cd "$base" && pwd)/_coordinacion/proyecto"
for d in "$base/proyecto" "$base/proyecto-rama" "$base/proyecto/.claude/worktrees/anidado"; do
  obtenido=$(ruta "$d")
  [ "$obtenido" = "$esperado" ] || { echo "FALLA: desde $d sale $obtenido (esperado $esperado)"; exit 1; }
done
echo "tablero: ok"
