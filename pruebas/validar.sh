#!/usr/bin/env bash
# Valida la estructura de la skill. Uso: bash pruebas/validar.sh [comprobacion...]
# Sin argumentos corre todas. Cada tarea del plan agrega su comprobacion al final.
set -u
raiz="$(cd "$(dirname "$0")/.." && pwd)"
fallos=0
actual=""
comprobaciones=()

falla() { echo "FALLA [$actual]: $*"; fallos=$((fallos + 1)); }
existe() { [ -f "$raiz/$1" ] || falla "no existe $1"; }
max_lineas() {
  [ -f "$raiz/$1" ] || { falla "no existe $1"; return; }
  local n; n=$(wc -l < "$raiz/$1")
  [ "$n" -le "$2" ] || falla "$1 tiene $n lineas (maximo $2)"
}
# Nombres que lo compartible no debe contener (proyectos, clientes, personas). Viven en
# pruebas/nombres-privados.txt, uno por linea; ese archivo no se comparte.
nombres_privados() {
  local f="$raiz/pruebas/nombres-privados.txt"
  [ -f "$f" ] || return 0
  grep -vE '^[[:space:]]*(#|$)' "$f" | tr -d '\r' | paste -sd'|' -
}
contiene() {
  [ -f "$raiz/$1" ] || { falla "no existe $1"; return; }
  grep -qF -- "$2" "$raiz/$1" || falla "$1 no contiene: $2"
}

comprobar_generales() {
  local f d dirs=()
  # Solo carpetas que existen: con una ausente, grep sale con 2 aunque haya coincidencias.
  for d in skill global; do [ -d "$raiz/$d" ] && dirs+=("$raiz/$d"); done
  if [ "${#dirs[@]}" -gt 0 ] && grep -rnwE 'TBD|TODO' "${dirs[@]}"; then
    falla "hay marcadores sin resolver"
  fi
  while IFS= read -r f; do
    # -U: en Windows, grep quita los CR si no se le pide tratar el archivo como binario.
    if grep -qU $'\r' "$f"; then falla "CRLF en $f"; fi
  done < <(find "$raiz" -path "$raiz/.git" -prune -o -type f \
             \( -name '*.sh' -o -path '*/githooks/*' \) -print)
}
comprobaciones+=(generales)

comprobar_global() {
  max_lineas global/CLAUDE.md 25
  contiene global/CLAUDE.md 'metodo-de-trabajo'
  contiene global/CLAUDE.md 'ID del proyecto'
  contiene global/CLAUDE.md 'main'
  contiene global/CLAUDE.md 'migraciones'
  contiene global/CLAUDE.md 'modo autónomo'
  # Se comparte: no nombra a un usuario concreto ni sus cuentas.
  local np; np=$(nombres_privados)
  if [ -n "$np" ] && grep -nwiE "$np" "$raiz/global/CLAUDE.md"; then falla "el CLAUDE.md global nombra a alguien de la lista privada"; fi
  contiene global/CLAUDE.md 'el usuario'
}
comprobaciones+=(global)

comprobar_nucleo() {
  local s=skill/SKILL.md
  max_lineas "$s" 160
  [ -f "$raiz/$s" ] || return
  head -1 "$raiz/$s" | grep -qx -- '---' || falla "$s no empieza con frontmatter"
  contiene "$s" 'name: metodo-de-trabajo'
  local desc; desc=$(grep -m1 '^description:' "$raiz/$s" | cut -c14-)
  [ -n "$desc" ] || falla "$s sin description"
  [ "${#desc}" -le 1024 ] || falla "description de ${#desc} caracteres (maximo 1024)"
  local v_skill v_log
  v_skill=$(grep -m1 -oE 'version: "[0-9]+\.[0-9]+\.[0-9]+"' "$raiz/$s" | grep -oE '[0-9.]+')
  v_log=$(grep -m1 -oE '^## [0-9]+\.[0-9]+\.[0-9]+' "$raiz/CHANGELOG.md" | cut -c4-)
  [ "$v_skill" = "$v_log" ] || falla "version de SKILL.md ($v_skill) distinta de CHANGELOG ($v_log)"
  local i
  for i in 1 2 3 4 5 6 7 8; do
    grep -qE "^## $i\. " "$raiz/$s" || falla "$s sin la seccion ## $i."
  done
}
comprobaciones+=(nucleo)

comprobar_autonomo() {
  local m=skill/modo-autonomo.md r=skill/plantillas/resumen-autonomo.md
  existe "$m"; existe skill/plantillas/bitacora-autonoma.md
  contiene "$m" 'PR en borrador'
  contiene "$m" 'SUPUESTO:'
  contiene "$m" '45 min'
  contiene "$m" '85 %'
  contiene "$m" 'date'
  contiene "$m" 'pre-vuelo'
  contiene "$m" 'salta la pieza'
  local nunca
  # Sin distinguir mayusculas: en la lista son el inicio de cada renglon.
  for nunca in 'fusionar' 'publicar' 'producción' 'migraciones remotas' 'secretos' 'gastar dinero'; do
    [ -f "$raiz/$m" ] && { grep -qiF -- "$nunca" "$raiz/$m" || falla "$m no contiene: $nunca"; }
  done
  [ -f "$raiz/$r" ] || { falla "no existe $r"; return; }
  local esperados=('## Lo que hice' '## Míralo' '## Una cosa para ti' '## Lo que no quedó')
  local reales; mapfile -t reales < <(grep -E '^## ' "$raiz/$r")
  [ "${reales[*]}" = "${esperados[*]}" ] || falla "$r: encabezados distintos o en otro orden"
  contiene "$r" '150 palabras'
}
comprobaciones+=(autonomo)

comprobar_coordinacion() {
  local c=skill/coordinacion.md t=skill/plantillas/tablero-sesion.md
  existe "$t"
  local campo
  for campo in 'sesión:' 'estado:' 'haciendo:' 'necesito:' 'toco:' 'actualizado:'; do contiene "$t" "$campo"; done
  [ -f "$raiz/$c" ] || { falla "no existe $c"; return; }
  local cosa
  for cosa in 'DECIDE' 'BLOQUEADA' 'LISTA' 'Si no contestas' 'Hasta 3 sesiones' 'Más de 3 sesiones' \
              'alfabeto OTAN' 'ListAgents' '--git-common-dir' 'resumen de resúmenes' \
              'No puede aprobar lo que el usuario no aprobó'; do
    contiene "$c" "$cosa"
  done
  bash "$raiz/pruebas/tablero.sh" > /dev/null || falla "pruebas/tablero.sh en rojo"
}
comprobaciones+=(coordinacion)

comprobar_verificacion() {
  local v=skill/verificacion.md cosa
  for cosa in 'romper la guarda' 'estando bien y estando mal' 'positiva' 'no debe ver' \
              'mocks' 'Omitido no es verde' 'teléfono' 'Debería funcionar' 'systematic-debugging'; do
    contiene "$v" "$cosa"
  done
}
comprobaciones+=(verificacion)

comprobar_proyecto() {
  local p=skill/plantillas f
  for f in CLAUDE.md decisiones-vigentes.md adr.md spec.md plan.md reporte.md handoff.md \
           preguntas-al-cliente.md plan-de-arranque.md lecciones.md; do existe "$p/$f"; done
  existe skill/proyecto-nuevo.md
  local campo
  for campo in '## Estado' '## Contexto' '## Decisión' '## Alternativas descartadas' \
               '## Cómo funciona' '## Consecuencia' '## Reversibilidad'; do contiene "$p/adr.md" "$campo"; done
  contiene "$p/decisiones-vigentes.md" 'ADR aceptado > CLAUDE.md > specs y planes'
  contiene "$p/spec.md" 'No se construye'
  contiene "$p/spec.md" 'Lo que necesita decidir una persona'
  contiene "$p/plan.md" 'Romper la guarda'
  contiene "$p/plan.md" 'Restricciones globales'
  contiene "$p/reporte.md" 'con qué salida'
  contiene "$p/handoff.md" 'Ya investigado'
  contiene "$p/handoff.md" 'Decisiones del usuario, citadas tal cual'
  contiene "$p/preguntas-al-cliente.md" 'Respuesta sugerida'
  contiene "$p/lecciones.md" 'Causa raíz'
  max_lineas "$p/CLAUDE.md" 200
  contiene "$p/CLAUDE.md" '[CRÍTICO]'
  contiene "$p/CLAUDE.md" 'ID del proyecto'
  local paso
  for paso in 'core.hooksPath' '.gitattributes' '.env.example' 'db reset' 'dos propietarios'; do
    contiene skill/proyecto-nuevo.md "$paso"
  done
}
comprobaciones+=(proyecto)

comprobar_ganchos() {
  existe skill/plantillas/githooks/pre-commit
  existe skill/plantillas/githooks/pre-push
  contiene skill/plantillas/gitattributes '*.sh'
  [ -f "$raiz/skill/plantillas/githooks/pre-push" ] || return
  bash "$raiz/pruebas/ganchos.sh" || falla "pruebas/ganchos.sh en rojo"
}
comprobaciones+=(ganchos)

comprobar_instalar() {
  existe instalar.sh
  [ -f "$raiz/instalar.sh" ] || return
  bash "$raiz/pruebas/instalar.sh" || falla "pruebas/instalar.sh en rojo"
}
comprobaciones+=(instalar)

# Hallazgos de la revision final de la rama skill-v1.
comprobar_revision() {
  # Los subagentes siguen a quien los lanzo: no se registran ni le hablan al usuario.
  contiene global/CLAUDE.md 'subagente'
  contiene skill/SKILL.md 'subagente'
  # Toda sesion se registra, aunque sea la unica, y la receta esta en el nucleo.
  contiene skill/SKILL.md 'aunque sea la única'
  contiene skill/SKILL.md '--git-common-dir'
  # Lo desactualizado se marca con fecha, no se borra.
  contiene skill/SKILL.md '**Al <fecha>:**'
  # Coordinacion: contar solo el mismo proyecto, orquestadora verificable, DECIDE con defecto reversible.
  contiene skill/coordinacion.md 'del mismo proyecto'
  contiene skill/coordinacion.md 'orquestadora.md'
  contiene skill/coordinacion.md 'Mientras tanto'
  contiene skill/coordinacion.md 'solo si X es una decisión técnica, interna y reversible'
  contiene skill/coordinacion.md 'reportarle a la orquestadora'
  # Omitido disfrazado de verde.
  contiene skill/verificacion.md '--no-verify'
  contiene skill/modo-autonomo.md '--no-verify'
  # Modo autonomo: vista previa, sin tiempo, el usuario escribe, herramienta de aviso.
  contiene skill/modo-autonomo.md 'vista previa'
  contiene skill/modo-autonomo.md 'Si la frase no trae tiempo'
  contiene skill/modo-autonomo.md 'Si el usuario escribe'
  contiene skill/modo-autonomo.md 'PushNotification'
  # Ganchos ejecutables fuera de Windows.
  contiene skill/proyecto-nuevo.md 'chmod=+x'
  local modo f
  for f in pre-commit pre-push; do
    modo=$(git -C "$raiz" ls-files -s "skill/plantillas/githooks/$f" | cut -d' ' -f1)
    [ "$modo" = 100755 ] || falla "skill/plantillas/githooks/$f sin bit de ejecucion en git ($modo)"
  done
}
comprobaciones+=(revision)

# Lo que se instala no nombra proyectos, clientes ni personas: los agentes los repetian en repos que no
# tienen nada que ver. Los nombres a vigilar viven en pruebas/nombres-privados.txt, que no se comparte.
comprobar_sin_proyectos() {
  contiene skill/SKILL.md 'Habla solo del proyecto en el que estás'
  local np; np=$(nombres_privados)
  if [ -z "$np" ]; then
    echo "sin_proyectos: no hay pruebas/nombres-privados.txt; no se buscan nombres (crealo, uno por linea)"
    return
  fi
  if grep -rniwE "$np" "$raiz/skill" "$raiz/global"; then
    falla "lo instalable menciona nombres de la lista privada"
  fi
}
comprobaciones+=(sin_proyectos)

# La sesion que lanza subagentes: que les da, como le reportan y que sigue siendo suyo.
comprobar_subagentes() {
  local c=skill/coordinacion.md cosa
  contiene skill/SKILL.md 'Si vas a lanzar subagentes'
  for cosa in '## Si tú lanzas subagentes' 'nunca más' 'sin comprobar' 'no una orden' \
              'no cuentan como sesiones' 'si dos subagentes'; do
    contiene "$c" "$cosa"
  done
}
comprobaciones+=(subagentes)

# La skill sirve para cualquier usuario: su nombre y su nivel viven en ~/.claude/perfil.md.
comprobar_perfil() {
  local s=skill/SKILL.md p=skill/plantillas/perfil.md cosa
  for cosa in '~/.claude/perfil.md' '### Adapta cómo conduces' '**Domina:**' '**Conoce:**' '**Nuevo:**'               'Una sola señal no basta' 'solo si dice que sí' 'Lidera la conversación, no la decisión'               'díselo una vez' 'Si insiste, haz lo que dice'; do
    contiene "$s" "$cosa"
  done
  for cosa in '## Nivel por tecnología' 'domina / conoce / nuevo' '## Cómo prefiere que le expliquen'               'sí del usuario'; do
    contiene "$p" "$cosa"
  done
}
comprobaciones+=(perfil)

# v2: lo que el usuario lee (mapa, recorrido, demostracion, una pregunta) y progreso claro.
comprobar_v2() {
  local s=skill/SKILL.md cosa
  for cosa in 'Lo que el usuario lee' 'plantillas/mapa.md' 'Muéstrale cómo va a funcionar'               'muéstraselo funcionando' 'pieza 2 de 3 del encargo' 'Nunca «terminé»'               'docker stats --no-stream' 'nunca rehagas en silencio' 'otro agente intenta romperlo'               'Nada de listas de pendientes' 'no cuentan'; do
    contiene "$s" "$cosa"
  done
  contiene skill/modo-autonomo.md 'el tiempo es un tope'
  contiene skill/plantillas/mapa.md 'Avance:'
  contiene skill/plantillas/mapa.md '| Pieza |'
  contiene skill/plantillas/perfil.md 'Proyectos de desarrollo activos a la vez'
  contiene skill/proyecto-nuevo.md '<tablero>/mapa.md'
  contiene skill/verificacion.md 'revisados antes de mostrarse'
  contiene skill/coordinacion.md 'LISTA — pieza'
}
comprobaciones+=(v2)

# Hallazgos de la revision independiente de la v2.
comprobar_v2_revision() {
  local s=skill/SKILL.md m=skill/modo-autonomo.md c=skill/coordinacion.md cosa
  # Las compuertas de superpowers se cumplen con el recorrido aprobado; no se le pide leer spec ni plan.
  contiene "$s" 'se cumplen con el recorrido y el «por dentro» aprobados'
  # Lo que no es pieza tiene su flujo y no toca el mapa; lo que no tiene pantalla se muestra por su efecto.
  contiene "$s" 'Lo que no es pieza'
  contiene "$s" 'por su efecto'
  # Dos denominadores cuando difieren; memoria en Windows; proyectos como sugerencia; perfil incompleto.
  contiene "$s" '(mapa 8 de 12)'
  contiene "$s" 'FreePhysicalMemory'
  contiene "$s" 'es una sugerencia'
  contiene "$s" 'le falta una sección de la plantilla'
  contiene "$s" 'si la revisión cambia lo que él vio'
  # Los subagentes no hacen lo que requiere al usuario.
  contiene "$s" 'salvo lo que requiere al usuario'
  # El mapa vive fuera del repo, con estado «para ver» y «en curso» por sesion.
  contiene "$s" '<tablero>/mapa.md'
  contiene skill/plantillas/mapa.md 'para ver'
  contiene skill/plantillas/mapa.md 'en curso (<sesión>)'
  # Pre-vuelo en un solo mensaje, reloj al cerrar el contrato, cola con reserva, caidas en el regreso.
  for cosa in 'en un solo mensaje' 'El reloj arranca' 'usa tus recomendaciones' '1.5 veces' \
              'se cayó' 'el comando exacto' 'Como máximo una pregunta'; do
    contiene "$m" "$cosa"
  done
  contiene skill/plantillas/resumen-autonomo.md 'se cayó'
  contiene skill/plantillas/plan.md 'muéstraselo funcionando'
  # Coordinacion: tipo MIRA y defecto solo si es tecnico.
  contiene "$c" 'MIRA —'
  contiene "$c" 'técnica, interna y reversible'
  # Reglas clave del nucleo.
  contiene "$s" 'Espera su sí'
  contiene "$s" 'Una pieza no está lista hasta que él la vio'
  # Restos de la v1 que contradicen la v2. Negativo con su positivo.
  local restos='Necesito de ti|700 palabras|Pégalo completo|como pendiente'
  if grep -rnE "$restos" "$raiz/skill"; then falla "quedan restos de la v1 en la skill"; fi
  grep -qE "$restos" <<< 'x Necesito de ti x' || falla "el patron de restos de la v1 no detecta nada"
  # La lista «Nunca» se mide dentro de su seccion, no en todo el archivo.
  local nunca; nunca=$(sed -n '/^## Nunca/,/^## [^N]/p' "$raiz/$m")
  [ -n "$nunca" ] || falla "$m: no encuentro la seccion Nunca"
  for cosa in 'Fusionar' 'Publicar a producción' 'Rodear un gate' 'migraciones remotas' 'secretos' 'Gastar dinero'; do
    grep -qF -- "$cosa" <<< "$nunca" || falla "$m: la seccion Nunca no contiene: $cosa"
  done
}
comprobaciones+=(v2_revision)

# Worktrees: dentro del repo y se borran al fusionar, para que no se amontonen carpetas.
comprobar_worktrees() {
  local c=skill/coordinacion.md cosa
  contiene skill/SKILL.md 'bórralos al fusionar'
  contiene skill/SKILL.md '.claude/worktrees/'
  for cosa in '## Worktrees' '.claude/worktrees/' 'git worktree remove' 'nunca con --force' \
              'git branch -d' 'borra tu archivo del tablero'; do
    contiene "$c" "$cosa"
  done
  contiene skill/proyecto-nuevo.md '.claude/worktrees/'
  # Un enlace (junction) dentro del worktree: borrado recursivo vacia la carpeta real del proyecto.
  for cosa in 'puede seguir el enlace' 'LinkType' 'cmd /c rmdir' 'antes y después'; do
    contiene "$c" "$cosa"
  done
}
comprobaciones+=(worktrees)

# El taller se publica en un repo compartido sin historial (compartir.sh). Lo que va alla no puede nombrar
# proyectos, clientes ni personas de la lista privada. Solo aplica en el taller, donde existe la lista.
comprobar_compartible() {
  local lista="$raiz/compartir/lista.txt" ruta np primero archivos=()
  [ -f "$lista" ] || return 0
  [ -f "$raiz/pruebas/nombres-privados.txt" ] || { falla "falta pruebas/nombres-privados.txt en el taller"; return; }
  existe compartir/README.md; existe compartir/gitignore; existe compartir/LICENSE; existe compartir.sh
  if grep -qE 'nombres-privados|^docs|^compartir' "$lista"; then falla "compartir/lista.txt incluye algo privado"; fi
  while IFS= read -r ruta; do
    ruta="${ruta%$'\r'}"; ruta="${ruta%/}"; [ -z "$ruta" ] && continue
    [ -e "$raiz/$ruta" ] || { falla "compartir/lista.txt nombra algo que no existe: $ruta"; continue; }
    archivos+=("$raiz/$ruta")
  done < "$lista"
  [ -f "$raiz/compartir/README.md" ] && archivos+=("$raiz/compartir/README.md")
  np=$(nombres_privados)
  if grep -rnwiE "$np" "${archivos[@]}"; then falla "lo compartible nombra a alguien de la lista privada"; fi
  primero=$(grep -vE '^[[:space:]]*(#|$)' "$raiz/pruebas/nombres-privados.txt" | head -1 | tr -d '\r')
  grep -qwiE "$np" <<< "x $primero x" || falla "la busqueda de nombres privados no detecta nada"
  [ -f "$raiz/compartir/gitignore" ] && { grep -qxF 'pruebas/nombres-privados.txt' "$raiz/compartir/gitignore" || falla "compartir/gitignore no excluye la lista privada"; }
}
comprobaciones+=(compartible)

# La version universal (universal/AGENTS.md) es el mismo metodo para cualquier agente. Las reglas clave
# deben decir lo mismo en la skill y en la universal, con la misma frase, para que no se desfasen.
comprobar_universal() {
  local u=universal/AGENTS.md l=universal/LEEME.md frase herramienta skill_todo
  existe "$u"; existe "$l"
  [ -f "$raiz/$u" ] || return
  skill_todo=$(cat "$raiz"/skill/*.md)
  while IFS= read -r frase; do
    [ -z "$frase" ] && continue
    grep -qF -- "$frase" <<< "$skill_todo" || falla "la skill ya no dice: $frase"
    grep -qF -- "$frase" "$raiz/$u" || falla "$u no dice: $frase"
  done <<'FRASES'
Lo que el usuario lee
Muéstrale cómo va a funcionar
muéstraselo funcionando
Una pieza no está lista hasta que él la vio
Nunca «terminé»
nunca rehagas en silencio
Lidera la conversación, no la decisión
Habla solo del proyecto en el que estás
Nada de listas de pendientes
Lo que no es pieza
Una sola señal no basta
pre-vuelo
el tiempo es un tope
Omitido no es verde
romper la guarda
FRASES
  # Nada que solo exista en una herramienta concreta.
  for herramienta in 'ListAgents' 'SendMessage' 'PushNotification' 'ToolSearch' 'superpowers' '~/.claude' 'CLAUDE.md' 'Claude Code'; do
    if grep -qF -- "$herramienta" "$raiz/$u"; then falla "$u nombra algo propio de una herramienta: $herramienta"; fi
  done
  contiene "$l" 'AGENTS.md'
  # Windsurf corta cada archivo de reglas a 12 000 caracteres (docs.devin.ai, consultado el 2026-10-13).
  # Tope de 11 000 para dejar lugar al perfil que llena cada usuario.
  local n; n=$(python -c "import sys; print(len(open(sys.argv[1],encoding='utf-8').read()))" "$raiz/$u" 2>/dev/null || wc -m < "$raiz/$u")
  [ "$n" -le 11000 ] || falla "$u tiene $n caracteres (maximo 11000)"
}
comprobaciones+=(universal)

# --- las tareas siguientes agregan sus comprobaciones aqui ---

correr() {
  local nombre
  for nombre in "$@"; do
    actual="$nombre"
    "comprobar_$nombre"
  done
}
if [ "$#" -gt 0 ]; then correr "$@"; else correr "${comprobaciones[@]}"; fi
if [ "$fallos" -gt 0 ]; then echo "$fallos falla(s)"; exit 1; fi
echo "todo en verde"
