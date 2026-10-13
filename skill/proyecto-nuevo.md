# Proyecto nuevo

Checklist para arrancar un repo. Cada punto dice qué plantilla usa (en `plantillas/`). Las plantillas no
dependen del stack; donde hace falta un ejemplo, es de Next.js + Supabase.

- [ ] **0. El mapa** (`plantillas/mapa.md`), en `<tablero>/mapa.md`, fuera del repo para que todas las
  ramas vean el mismo: las piezas del proyecto, cada una algo que el usuario puede ver funcionando. Es lo
  primero que se arma, con él, y lo único que él lee para saber dónde va el proyecto.
- [ ] **1. `CLAUDE.md` como índice** (`plantillas/CLAUDE.md`), máximo ~200 líneas. Tres niveles: la raíz
  para lo catastrófico o transversal, `.claude/rules/*.md` con `paths:` para lo que solo aplica al tocar
  ciertos archivos, y `docs/` para lo que se consulta a propósito. Anota ahí el ID de cada servicio
  externo.
- [ ] **2. `docs/decisiones-vigentes.md`** (`plantillas/decisiones-vigentes.md`), con la precedencia:
  ADR aceptado > CLAUDE.md > specs y planes.
- [ ] **3. `docs/adr/`** (`plantillas/adr.md`). Un ADR solo si hay 2 o más enfoques viables, cambia un
  comportamiento existente o entra una dependencia o convención nueva.
- [ ] **4. Ciclo spec → plan → reporte** (`plantillas/spec.md`, `plantillas/plan.md`,
  `plantillas/reporte.md`).
- [ ] **5. Ganchos y fin de línea.**
  - Copia `plantillas/githooks/` como `.githooks/` y `plantillas/gitattributes` como `.gitattributes`.
  - Instala con `git config core.hooksPath .githooks`. Nunca con enlace simbólico: en un worktree corre la
    versión de otro árbol.
  - Agrega `.claude/worktrees/` al `.gitignore`: ahí viven los worktrees (`coordinacion.md`, «Worktrees»).
  - Márcalos ejecutables en git: `git add --chmod=+x .githooks/*`. En Windows funcionan sin eso, pero en
    Linux y macOS git los ignora en silencio y el push pasa sin la suite.
  - Crea `scripts/verificar-rapido.sh` (opcional: tipos y lint de lo preparado; lo corre el pre-commit) y
    `scripts/verificar-todo.sh` (obligatorio: la suite completa; sin él, el pre-push se detiene).
  - Si hay CI: solo en PR y en push a `main`, con versiones fijadas y saltando los cambios que son solo de
    documentación.
- [ ] **6. Datos y secretos.**
  - `.env.example` versionado; los `.env` reales fuera de git. Se documenta **dónde** vive cada secreto,
    nunca su contenido.
  - Una base de prueba por worktree, o un candado entre procesos si la base local es compartida.
  - Migraciones siempre creadas con el CLI, nunca con el sello a mano; nunca `db reset` sobre una base
    compartida; nunca el seed contra la base del cliente.
  - Para QA local, comprueba que el `.env` no apunte a producción.
- [ ] **7. Arranque con el cliente** (`plantillas/plan-de-arranque.md`,
  `plantillas/preguntas-al-cliente.md`): plan por fases con dueño; cuentas a nombre del cliente con
  dos propietarios; preguntas con ID, qué bloquea y respuesta sugerida.
- [ ] **8. `docs/lecciones.md`** (`plantillas/lecciones.md`): todo bug que tomó más de 10 minutos.

Al terminar el checklist: primer commit en una rama, no en `main`, y que el usuario lo revise.
