#!/usr/bin/env bash
# Prueba los ganchos de plantilla en un repo temporal.
set -uo pipefail
raiz="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
r="$tmp/repo"; mkdir -p "$r"; cd "$r"
git init -q -b main
mkdir -p .githooks scripts
cp "$raiz/skill/plantillas/githooks/"* .githooks/
git config core.hooksPath .githooks
git config user.name t; git config user.email t@t
fallos=0
espera() { # espera <0|1> <descripcion> <orden...>
  local quiere=$1 desc=$2; shift 2
  "$@" > "$tmp/salida" 2>&1; local obtuvo=$?
  if { [ "$quiere" = 0 ] && [ "$obtuvo" -ne 0 ]; } || { [ "$quiere" = 1 ] && [ "$obtuvo" -eq 0 ]; }; then
    echo "FALLA: $desc (salida: $(tr '\n' ' ' < "$tmp/salida"))"; fallos=$((fallos + 1))
  fi
}

echo 'const a = 1' > a.ts; git add a.ts
espera 0 "commit normal pasa" git commit -q -m normal

printf 'const b = 1\0\0' > b.ts; git add b.ts
espera 1 "archivo de texto con bytes nulos se rechaza" git commit -q -m nulos
git rm -q --cached b.ts; rm b.ts

printf 'const t = "hol' > t.ts; git add t.ts
espera 1 "archivo de texto cortado (sin salto final) se rechaza" git commit -q -m truncado
git rm -q --cached t.ts; rm t.ts

: > vacio.md; git add vacio.md
espera 0 "archivo vacio pasa" git commit -q -m vacio

# Largo para que git lo vea como renombre (R) y no como borrado + alta.
for i in $(seq 1 40); do echo "const d$i = $i"; done > d.ts; git add d.ts; git commit -q -m d
git mv d.ts e.ts; printf 'x\0\n' >> e.ts; git add e.ts
git diff --cached --name-status | grep -q '^R' || echo "AVISO: la prueba de renombre no produjo un renombre"
espera 1 "renombre con bytes nulos se rechaza" git commit -q -m renombre
git reset -q --hard HEAD

seq 1 201 > CLAUDE.md; git add CLAUDE.md
espera 1 "CLAUDE.md de 201 lineas se rechaza" git commit -q -m largo
seq 1 200 > CLAUDE.md; git add CLAUDE.md
espera 0 "CLAUDE.md de 200 lineas pasa" git commit -q -m justo

printf '#!/usr/bin/env bash\nexit 1\n' > scripts/verificar-rapido.sh
echo 'const c = 1' > c.ts; git add c.ts scripts/verificar-rapido.sh
espera 1 "verificar-rapido en rojo bloquea el commit" git commit -q -m rapido-rojo
printf '#!/usr/bin/env bash\nexit 0\n' > scripts/verificar-rapido.sh; git add scripts/verificar-rapido.sh
espera 0 "verificar-rapido en verde deja pasar" git commit -q -m rapido-verde

espera 1 "pre-push sin verificar-todo falla (omitido no es verde)" bash .githooks/pre-push origin x
printf '#!/usr/bin/env bash\nexit 1\n' > scripts/verificar-todo.sh
espera 1 "pre-push con verificar-todo en rojo falla" bash .githooks/pre-push origin x
printf '#!/usr/bin/env bash\nexit 0\n' > scripts/verificar-todo.sh
espera 0 "pre-push con verificar-todo en verde pasa" bash .githooks/pre-push origin x

[ "$fallos" -eq 0 ] && echo "ganchos: ok" || { echo "$fallos falla(s)"; exit 1; }
