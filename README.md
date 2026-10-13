# Agentes con método

Un método de trabajo para agentes de programación. Con él, el agente te muestra cómo va a funcionar cada
pieza antes de construirla y funcionando después, siempre te dice dónde va el proyecto y cuánto falta, se
adapta a tu nivel en cada tecnología, verifica antes de decir que algo está listo y solo trabaja solo
cuando tú se lo pides, después de resolver contigo las dudas.

Es un proyecto personal y no oficial: no está afiliado a Anthropic ni a ningún otro proveedor.

## Dos caminos

**¿Usas Claude Code?** Instala la versión completa, una *skill* con plantillas, coordinación entre
sesiones y pruebas. Sigue «Instalar en Claude Code».

**¿Usas otro agente** (Codex, Cursor, Gemini, Copilot…)? Usa `universal/AGENTS.md`: el mismo método en un
solo archivo de instrucciones. Dónde ponerlo según tu herramienta está en `universal/LEEME.md`. Al final
del archivo hay una sección para tu perfil.

## Instalar en Claude Code

Necesitas git y bash (en Windows, Git Bash).

```bash
git clone <la dirección de este repo: botón «Code» en GitHub>
```

```bash
cd agentes-con-metodo && bash instalar.sh
```

Si no usas la terminal, pídeselo a Claude Code: «clona este repo e instala la skill con instalar.sh».

El instalador copia la skill a `~/.claude/skills/metodo-de-trabajo/` y, en tu `~/.claude/CLAUDE.md`, solo
escribe un bloque marcado entre `<!-- metodo-de-trabajo:inicio -->` y `<!-- metodo-de-trabajo:fin -->`:

- Si no tienes `CLAUDE.md`, lo crea solo con ese bloque.
- Si ya tienes uno, agrega el bloque al final y guarda antes una copia de respaldo. Lo que hay fuera del
  bloque no se toca nunca.
- Reinstalar no duplica el bloque: lo reemplaza en su lugar, y si nada cambió, no reescribe el archivo.

La skill guarda tu nombre, tu nivel por tecnología y cómo prefieres que te expliquen en
`~/.claude/perfil.md`; en tu primera sesión te propone crearlo y solo lo cambia con tu sí.

Para actualizar, en la carpeta donde clonaste:

```bash
git pull && bash instalar.sh
```

Para correr las pruebas: `bash pruebas/validar.sh`. Si quieres que vigilen que la skill no mencione tus
proyectos o clientes, crea `pruebas/nombres-privados.txt` con un nombre por línea; git lo ignora.

## Cómo se ve un día de trabajo

Al abrir la sesión, el agente te ubica con el mapa del proyecto: «vamos en 7 de 12 piezas; hoy toca X».
Antes de construir, te enseña cómo va a funcionar la pieza y te hace una pregunta a la vez. Mientras
trabaja, te dice «pieza 2 de 3 · faltan ~15 min», no «terminé» cuando aún falta algo. Al acabar, te
muestra la pieza funcionando. Specs, planes y bitácoras existen, pero son para los agentes, no para ti.

## Sugerencias

Si algo no funciona o tienes una idea, abre un *issue* en este repo.

## Licencia

MIT. Ver `LICENSE`.
