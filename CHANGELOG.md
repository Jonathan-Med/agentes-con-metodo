# Historial

Una línea por cambio. La versión más reciente arriba. `instalar.sh` lee la primera.

## 2.2.0 · 2026-10-13

- Versión universal en `universal/AGENTS.md`: el mismo método en un solo archivo, sin nada propio de una
  herramienta, para cualquier agente; `universal/LEEME.md` dice dónde lo lee cada uno. Una prueba revisa
  que las reglas clave digan lo mismo en la skill y en la universal.
- Se publica como `agentes-con-metodo`, con licencia MIT.

## 2.1.2 · 2026-10-13

- Primera versión que se publica en el repo compartido, sin historial ni documentos internos. Las pruebas
  leen de `pruebas/nombres-privados.txt` los nombres que la skill no debe mencionar; si no existe, avisan
  y no los buscan.

## 2.1.1 · 2026-10-13

- Worktrees: advertencia de enlaces (junction) que `git worktree remove` deja y que un borrado recursivo
  puede seguir hasta vaciar el `node_modules` real; se quita solo el enlace y se cuenta antes y después.

## 2.1.0 · 2026-10-13

- El instalador escribe en el `CLAUDE.md` global solo un bloque marcado: lo crea si no existe, lo agrega si
  hay uno propio y lo reemplaza en su lugar al actualizar. Reinstalar no duplica. Sale `--reemplazar-global`.
- Worktrees dentro del repo (`.claude/worktrees/`) y borrados al fusionar su rama, sin `--force`; al
  terminar la sesión se borra su archivo del tablero.

## 2.0.1 · 2026-10-13

- El `CLAUDE.md` global ya no nombra a un usuario concreto: se puede compartir. Lo personal vive en el perfil.

## 2.0.0 · 2026-10-13

- Lo que el usuario lee es poco: el mapa, el recorrido, la demostración y una pregunta a la vez; lo demás es para agentes.
- Mapa del proyecto (`docs/mapa.md`, plantilla nueva): cada sesión empieza con «X de Y piezas; hoy toca…».
- Cada pieza: mostrar cómo va a funcionar antes de construir y mostrarla funcionando después.
- Avance siempre respecto del todo («pieza 2 de 3 del encargo · faltan ~15 min»), estimado contra real, cuidar la memoria y no rehacer en silencio.
- Specs y planes revisados por otro agente antes de mostrarse.
- Modo autónomo: pre-vuelo (estimación, cola del mapa, recorridos y preguntas por adelantado), la cola llena el tiempo, una duda nueva salta la pieza; al volver, demostración y una pregunta.
- Mensajes cortos y en prosa; sin listas de pendientes. Límite de proyectos a la vez como sugerencia del perfil.

## 1.1.0 · 2026-10-02

- Perfil del usuario en `~/.claude/perfil.md` (plantilla en `plantillas/perfil.md`); el instalador no lo toca.
- Se adapta por tema: domina / conoce / nuevo; detecta, lo dice y solo anota con el sí del usuario.
- Regla explícita: lidera la conversación, no la decisión.
- La skill ya no nombra a un usuario concreto: sirve para cualquiera.

## 1.0.2 · 2026-10-02

- Coordinación: qué lleva el encargo a un subagente, cómo reporta y qué sigue siendo de quien lo lanzó.

## 1.0.1 · 2026-10-01

- Lo instalable ya no nombra proyectos del usuario; el origen de cada regla queda en los documentos internos.
- Nueva regla en Comunicación: habla solo del proyecto en el que estás.

## 1.0.0 · 2026-10-01

- Versión inicial: núcleo, modo autónomo, coordinación, verificación, proyecto nuevo y plantillas.
