#!/usr/bin/env bash
# Instala la skill metodo-de-trabajo y su bloque en el CLAUDE.md global.
# Uso: bash instalar.sh
# Por copia, no por enlace: un enlace en un worktree ejecuta la version de otro arbol.
#
# El CLAUDE.md global es del usuario. El instalador solo escribe dentro de su bloque marcado y nunca
# toca lo de fuera. Reinstalar no duplica: si el bloque ya esta, se reemplaza en su mismo lugar, y si
# no cambio nada, el archivo no se reescribe.
#
# Salida: 0 todo instalado · 2 skill instalada, pero el CLAUDE.md tiene las marcas rotas y no se toco.
set -euo pipefail
raiz="$(cd "$(dirname "$0")" && pwd)"
destino="${CLAUDE_HOME:-$HOME/.claude}"
skill_dest="$destino/skills/metodo-de-trabajo"
global_dest="$destino/CLAUDE.md"
ini='<!-- metodo-de-trabajo:inicio -->'
fin='<!-- metodo-de-trabajo:fin -->'
version=$(grep -m1 -oE '^## [0-9]+\.[0-9]+\.[0-9]+' "$raiz/CHANGELOG.md" | cut -c4-)

trabajo=$(mktemp -d); trap 'rm -rf "$trabajo"' EXIT
bloque="$trabajo/bloque"
{ printf '%s\n' "$ini"; cat "$raiz/global/CLAUDE.md"; printf '%s\n' "$fin"; } > "$bloque"

# Hasta la 2.0 se instalaba el archivo entero, sin marcas, y se guardaba una copia dentro de la skill.
# Se rescata ANTES de reemplazar la skill, que es donde vive.
legado=""
if [ -f "$skill_dest/.global-instalado" ]; then
  legado="$trabajo/legado"; cp "$skill_dest/.global-instalado" "$legado"
fi

mkdir -p "$destino/skills"
rm -rf "$skill_dest"
cp -R "$raiz/skill" "$skill_dest"
echo "metodo-de-trabajo $version instalada en $skill_dest"

respaldar() { cp "$global_dest" "$global_dest.respaldo-$(date +%Y%m%d-%H%M%S)"; }

if [ ! -f "$global_dest" ]; then
  cp "$bloque" "$global_dest"
  echo "CLAUDE.md global creado con el bloque de la skill"
  exit 0
fi

# Las marcas se buscan con -U y \r opcional: en Windows el archivo puede tener CRLF.
patron_ini="^${ini}"$'\r'"?\$"
patron_fin="^${fin}"$'\r'"?\$"
n_ini=$(grep -cUE "$patron_ini" "$global_dest" || true)
n_fin=$(grep -cUE "$patron_fin" "$global_dest" || true)

if [ "$n_ini" = 0 ] && [ "$n_fin" = 0 ]; then
  respaldar
  if [ -n "$legado" ] && cmp -s "$legado" "$global_dest"; then
    # Todo el archivo era nuestro (formato anterior): se cambia por el bloque, sin duplicar reglas.
    cp "$bloque" "$global_dest"
    echo "CLAUDE.md global convertido al formato de bloque"
  else
    # Archivo propio del usuario: el bloque va al final; lo demas no se toca.
    [ -n "$(tail -c1 "$global_dest")" ] && printf '\n' >> "$global_dest"
    { printf '\n'; cat "$bloque"; } >> "$global_dest"
    echo "bloque de la skill agregado al final de tu CLAUDE.md global"
  fi
  exit 0
fi

l_ini=$(grep -nUE "$patron_ini" "$global_dest" | head -1 | cut -d: -f1 || true)
l_fin=$(grep -nUE "$patron_fin" "$global_dest" | head -1 | cut -d: -f1 || true)
if [ "$n_ini" != 1 ] || [ "$n_fin" != 1 ] || [ "${l_ini:-0}" -ge "${l_fin:-0}" ]; then
  echo "AVISO: las marcas del bloque en $global_dest estan rotas; no lo toque." >&2
  echo "Deja exactamente una linea '$ini' y una '$fin', en ese orden, y vuelve a instalar." >&2
  exit 2
fi

# Reemplaza solo lo que esta entre las marcas. Las lineas de fuera se imprimen tal cual: BINMODE=3
# evita que awk en Windows les quite el CR (en otros sistemas no tiene efecto).
awk -v BINMODE=3 -v b="$bloque" -v ini="$ini" -v fin="$fin" '
  { linea = $0; sub(/\r$/, "", linea) }
  linea == ini { while ((getline l < b) > 0) print l; dentro = 1; next }
  linea == fin { dentro = 0; next }
  !dentro { print }
' "$global_dest" > "$trabajo/nuevo"

if cmp -s "$trabajo/nuevo" "$global_dest"; then
  echo "bloque de la skill ya estaba al dia"
else
  cp "$trabajo/nuevo" "$global_dest"
  echo "bloque de la skill actualizado"
fi
