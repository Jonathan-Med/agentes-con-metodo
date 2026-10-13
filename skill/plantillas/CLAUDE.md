# <Proyecto> — mapa para agentes

> Índice, no manual: se lee entero en una pasada. Cada fila dice dónde está algo y, si hay trampa, la
> nombra en una línea. Si encuentras algo desactualizado, corrígelo en el mismo PR.

## Qué es

<dos o tres frases: qué hace, para quién, en qué fase está>

## Stack

<lenguajes, framework con versión, base de datos, despliegue>

## Dónde vive lo demás

| Dónde | Qué hay | Cuándo leerlo |
|---|---|---|
| `docs/decisiones-vigentes.md` | Qué está decidido hoy y la precedencia de documentos | **Primera lectura** |
| `docs/adr/` | Decisiones con su contexto y alternativas | Al retomar una decisión |
| `docs/lecciones.md` | Bugs que tomaron más de 10 minutos | Antes de teorizar sobre un fallo |
| `.claude/rules/<tema>.md` | Reglas que se cargan solas al tocar ciertos archivos (`paths:`) | Se cargan solas |
| `<doc>` | <qué> | <cuándo> |

Nada cuyo olvido sea catastrófico y silencioso va en un `.claude/rules` con `paths:`: la acción peligrosa
suele ocurrir antes de abrir cualquier archivo. Eso va aquí.

## Servicios externos

Antes de escribir en cualquiera, compara el ID del proyecto, no el nombre.

| Servicio | ID del proyecto | Cómo comprobarlo |
|---|---|---|
| Supabase | `<ref>` | `grep '^SUPABASE_URL=' .env` |
| Vercel | `<id>` | `vercel project ls` |

## Anti-patterns

### [CRÍTICO]

- **<regla en una línea>.** Caso real: <qué pasó, fecha>.

### [CUIDADO]

- **<regla>.** Caso real: <…>.

### [ESTILO]

- **<regla>.**

## Comandos

```bash
<instalar>
<desarrollo local>
bash scripts/verificar-rapido.sh   # lo corre el pre-commit
bash scripts/verificar-todo.sh     # lo exige el pre-push
```

Ganchos: `git config core.hooksPath .githooks`. Es lo primero que se pierde al clonar.

## Definición de terminado

- Funciona en el teléfono, no solo en la pantalla de quien programa.
- Los permisos se probaron con todos los perfiles, incluido lo que cada uno no debe ver.
- La suite completa está en verde y se vio la pantalla en la vista previa.
- <criterio propio del proyecto>

## Cómo mantener este archivo

- Máximo 200 líneas (lo valida el pre-commit). Lo que no quepa va a `docs/` con una fila aquí.
- Sin bitácoras de sesión ni «estado al <fecha>»: eso es `git log` y los reportes.
- Cada anti-pattern lleva severidad y su caso real. Sin el porqué, la regla se ignora.
- Ninguna cifra sin fecha. Si un comando puede generarla, se escribe el comando, no la cifra.

Última revisión: <AAAA-MM-DD>
