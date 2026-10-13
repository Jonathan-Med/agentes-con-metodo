# Dónde poner AGENTS.md

`AGENTS.md` es el método completo en un solo archivo. Puedes usarlo de dos formas:

- **Por proyecto** (lo más compatible): cópialo a la raíz de tu repositorio con el nombre `AGENTS.md`. Si
  tu proyecto ya tiene uno, pega el método al final, bajo un título propio.
- **Para todos tus proyectos**: solo algunas herramientas tienen un lugar global; está en la tabla.

Después, llena la sección «Perfil del usuario» al final del archivo, o deja que el agente te lo proponga.

Comprobado el 13 de octubre de 2026 en la documentación oficial de cada herramienta. Si algo cambió, la
fuente está abajo.

| Herramienta | Por proyecto | Para todos tus proyectos |
|---|---|---|
| Codex (OpenAI) | `AGENTS.md` en la raíz | `~/.codex/AGENTS.md`. Se suma al del proyecto; el más cercano manda. Tope de 32 KiB entre todos. |
| Cursor | `AGENTS.md` en la raíz | No hay archivo global: pega el contenido en Customize → Rules → User Rules. |
| Gemini CLI | Lee `GEMINI.md`. Para que lea `AGENTS.md`, en `.gemini/settings.json` pon `"context": { "fileName": ["AGENTS.md", "GEMINI.md"] }` | `~/.gemini/GEMINI.md`: copia ahí el contenido o impórtalo con `@` y la ruta del archivo. |
| GitHub Copilot (VS Code, CLI y agente en la nube) | `AGENTS.md` en la raíz (en VS Code, con `chat.useAgentsMdFile` activado) | CLI: `~/.copilot/copilot-instructions.md`. VS Code: instrucciones de usuario en tu perfil. |
| Windsurf / Devin Desktop | `AGENTS.md` en la raíz | `~/.codeium/windsurf/memories/global_rules.md`, pero admite 6 000 caracteres y el método no cabe: úsalo por proyecto (12 000 por archivo). |
| Aider | Agrega `read: AGENTS.md` a `.aider.conf.yml` | — |
| Claude Code | Lee `AGENTS.md` si no hay `CLAUDE.md`; si lo hay, agrega una línea `@AGENTS.md` a tu `CLAUDE.md` | Mejor instala la versión completa, la *skill* (ver el README del repo). |

Otras herramientas que leen `AGENTS.md` según el sitio del estándar (agents.md): Jules, Factory, goose,
opencode, Zed, Warp, Junie, Amp, RooCode y Kilo Code, entre otras.

## Fuentes

- Codex: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- Cursor: https://cursor.com/docs/context/rules
- Gemini CLI: https://geminicli.com/docs/cli/gemini-md/ y https://geminicli.com/docs/reference/configuration/
- GitHub Copilot: https://code.visualstudio.com/docs/copilot/customization/custom-instructions,
  https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions y
  https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
- Windsurf / Devin Desktop: https://docs.devin.ai/desktop/cascade/agents-md y
  https://docs.devin.ai/desktop/cascade/memories
- Claude Code: https://code.claude.com/docs/en/memory
- El estándar: https://agents.md/
