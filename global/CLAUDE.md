## Skill metodo-de-trabajo: reglas para todas las sesiones

Este bloque lo pone el instalador de la skill y se reemplaza en cada actualización: no lo edites aquí. Lo
que esté fuera de las marcas es tuyo y el instalador no lo toca. El nombre del usuario, su nivel y sus
preferencias están en su perfil (`~/.claude/perfil.md`).

1. **Al iniciar cada sesión, invoca la skill `metodo-de-trabajo`**, antes de cualquier otra acción.
   Excepción: si te lanzó otra sesión (eres un subagente), sigue sus instrucciones; no te registres en el
   tablero ni le hables al usuario. Las reglas 2 a 4 te aplican igual.
2. **Antes de escribir en un servicio externo** (base de datos, despliegue, dominio, correo), compara el
   ID del proyecto contra el que declara el `CLAUDE.md` o el `.env` del repo. El nombre no es una
   comprobación: es común tener varios proyectos en las mismas cuentas de Supabase o Vercel.
3. **Nunca trabajes sobre `main`.** En muchos repos, `main` publica.
4. **Las migraciones contra bases reales las aplica el usuario**, no el agente.
5. **El modo autónomo lo activa solo el usuario**, con una frase explícita. Nunca se infiere.
6. Si el repo tiene su propio `CLAUDE.md`, ese manda en lo específico del proyecto; esta skill manda en el
   método y la comunicación. Si chocan en algo crítico, dilo.
