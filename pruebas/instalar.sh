#!/usr/bin/env bash
# Prueba el instalador contra un destino temporal con espacios.
# El CLAUDE.md global del usuario es suyo: el instalador solo escribe dentro de su bloque marcado.
set -uo pipefail
raiz="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export CLAUDE_HOME="$tmp/con espacio/.claude"
g="$CLAUDE_HOME/CLAUDE.md"
ini='<!-- metodo-de-trabajo:inicio -->'
fin='<!-- metodo-de-trabajo:fin -->'
fallos=0
falla() { echo "FALLA: $*"; fallos=$((fallos + 1)); }
cuenta() { grep -c -- "$1" "$g" 2>/dev/null || true; }
version=$(grep -m1 -oE '^## [0-9]+\.[0-9]+\.[0-9]+' "$raiz/CHANGELOG.md" | cut -c4-)
regla=$(grep -m1 -F 'ID del proyecto' "$raiz/global/CLAUDE.md")

# 1. Sin CLAUDE.md: lo crea solo con el bloque.
salida=$(bash "$raiz/instalar.sh") || falla "primera instalacion fallo: $salida"
[ -f "$CLAUDE_HOME/skills/metodo-de-trabajo/SKILL.md" ] || falla "no copio SKILL.md"
echo "$salida" | grep -qF "metodo-de-trabajo $version instalada" || falla "no imprimio la version: $salida"
[ "$(cuenta "$ini")" = 1 ] && [ "$(cuenta "$fin")" = 1 ] || falla "el archivo nuevo no tiene un solo bloque"
grep -qF -- "$regla" "$g" || falla "el bloque no trae las reglas de global/CLAUDE.md"

# 2. Reinstalar no duplica: tres corridas, un solo bloque y el archivo identico.
cp "$g" "$tmp/antes"
bash "$raiz/instalar.sh" > /dev/null 2>&1; bash "$raiz/instalar.sh" > /dev/null 2>&1
[ "$(cuenta "$ini")" = 1 ] || falla "reinstalar duplico el bloque ($(cuenta "$ini") inicios)"
cmp -s "$tmp/antes" "$g" || falla "reinstalar la misma version cambio el archivo"

# 3. Un CLAUDE.md personal sin bloque: agrega el bloque al final, no toca lo demas y deja respaldo.
rm -f "$CLAUDE_HOME"/CLAUDE.md.respaldo-*
printf '# Mis reglas\n\nNo uses tabs.\n' > "$g"
bash "$raiz/instalar.sh" > /dev/null 2>&1 || falla "con un CLAUDE.md personal fallo"
[ "$(head -3 "$g")" = "$(printf '# Mis reglas\n\nNo uses tabs.')" ] || falla "cambio el contenido personal"
[ "$(cuenta "$ini")" = 1 ] || falla "no agrego un solo bloque al archivo personal"
ls "$CLAUDE_HOME"/CLAUDE.md.respaldo-* > /dev/null 2>&1 || falla "no dejo respaldo antes de modificar"

# 4. Actualizacion: reemplaza solo el bloque; lo de arriba y lo de abajo queda igual.
echo "Una nota mia de abajo." >> "$g"
fuente="$tmp/fuente"; mkdir -p "$fuente"
cp -R "$raiz/skill" "$raiz/global" "$raiz/instalar.sh" "$raiz/CHANGELOG.md" "$fuente/"
echo "7. Regla nueva de la version siguiente." >> "$fuente/global/CLAUDE.md"
bash "$fuente/instalar.sh" > /dev/null 2>&1 || falla "actualizar fallo"
grep -qF "7. Regla nueva de la version siguiente." "$g" || falla "no actualizo el bloque"
grep -qxF "Una nota mia de abajo." "$g" || falla "borro lo que estaba despues del bloque"
grep -qxF "No uses tabs." "$g" || falla "borro lo que estaba antes del bloque"
[ "$(cuenta "$ini")" = 1 ] || falla "actualizar duplico el bloque"
bash "$raiz/instalar.sh" > /dev/null 2>&1
grep -qF "7. Regla nueva" "$g" && falla "volver a la version del repo no quito la regla de la otra version"

# 5. Fin de linea de Windows en el archivo personal: se respeta y no se duplica.
printf '# Mis reglas\r\nCon CRLF.\r\n' > "$g"
bash "$raiz/instalar.sh" > /dev/null 2>&1; bash "$raiz/instalar.sh" > /dev/null 2>&1
[ "$(cuenta "$ini")" = 1 ] || falla "con CRLF duplico el bloque"
head -1 "$g" | grep -qU $'\r' || falla "quito el CRLF de las lineas personales"

# 6. Archivo de una version anterior (todo el archivo era nuestro, sin marcas): se convierte sin duplicar.
cp "$raiz/global/CLAUDE.md" "$g"
cp "$raiz/global/CLAUDE.md" "$CLAUDE_HOME/skills/metodo-de-trabajo/.global-instalado"
bash "$raiz/instalar.sh" > /dev/null 2>&1 || falla "convertir el formato anterior fallo"
[ "$(grep -cF -- "$regla" "$g")" = 1 ] || falla "al convertir el formato anterior duplico las reglas"
[ "$(cuenta "$ini")" = 1 ] || falla "al convertir no dejo un solo bloque"

# 7. Marcas rotas (solo el inicio): no toca el archivo, pero instala la skill y sale con 2.
printf '# Mio\n%s\nmitad de un bloque\n' "$ini" > "$g"
cp "$g" "$tmp/roto"
touch "$CLAUDE_HOME/skills/metodo-de-trabajo/marca-vieja.md"
bash "$raiz/instalar.sh" > "$tmp/salida" 2>&1; codigo=$?
[ "$codigo" -eq 2 ] || falla "con marcas rotas deberia salir con 2 (salio con $codigo)"
cmp -s "$tmp/roto" "$g" || falla "con marcas rotas modifico el archivo"
[ ! -e "$CLAUDE_HOME/skills/metodo-de-trabajo/marca-vieja.md" ] || falla "con marcas rotas no actualizo la skill"

# 8. El perfil del usuario es suyo: el instalador nunca lo toca.
rm -f "$g"; bash "$raiz/instalar.sh" > /dev/null 2>&1
echo "mi perfil" > "$CLAUDE_HOME/perfil.md"
bash "$raiz/instalar.sh" > /dev/null 2>&1
[ "$(cat "$CLAUDE_HOME/perfil.md")" = "mi perfil" ] || falla "el instalador toco el perfil del usuario"

# 9. La skill se reemplaza completa: no quedan archivos viejos.
touch "$CLAUDE_HOME/skills/metodo-de-trabajo/sobrante.md"
bash "$raiz/instalar.sh" > /dev/null 2>&1
[ ! -e "$CLAUDE_HOME/skills/metodo-de-trabajo/sobrante.md" ] || falla "dejo archivos viejos en la skill"

[ "$fallos" -eq 0 ] && echo "instalar: ok" || { echo "$fallos falla(s)"; exit 1; }
