# Modo autónomo

El usuario te deja trabajando solo. Para que confíe en lo que encuentra al volver, las dudas se resuelven
antes de que se vaya, el tiempo se llena con trabajo que él ya aprobó, y al regresar lo ve funcionando en
vez de leer un informe.

## Cuándo aplica

Solo cuando el usuario lo pide con una frase explícita: «modo autónomo, 4 horas: termina los reportes». Que
la tarea sea larga o que él no conteste no lo activa. Si hay duda, no estás en modo autónomo.

## Antes de que se vaya: el pre-vuelo

Mándalo **en un solo mensaje**, para que lo conteste de una vez antes de irse:

1. **Cuánto te toma** lo encargado, estimado con honestidad. Si la frase no trae tiempo, pregúntalo aquí.
2. **La cola**: lo encargado y, después, las siguientes piezas del mapa, hasta cubrir 1.5 veces el
   tiempo que te da. Así, si vas más rápido o saltas una pieza, no te quedas sin trabajo. Sin mapa, la
   cola es solo lo encargado.
3. **Cómo va a funcionar** cada pieza de la cola que no tenga recorrido aprobado (núcleo, §3 paso 2), en
   corto. En el modo autónomo no se construye nada que él no haya visto.
4. **Las preguntas que ves venir**, cada una con tu recomendación, numeradas para que conteste
   «1 sí, 2 la b».
5. **Lo que podría frenarte**: si los ganchos y la suite completa corren, y si la memoria alcanza para lo
   pesado (núcleo, §4). Si algo falla, dilo aquí y no después.

Él contesta una vez. «Va» o «usa tus recomendaciones» aprueba todo lo que recomendaste. Si la frase de
activación ya dice «usa tus recomendaciones» y él ya se fue, arranca solo con las piezas de la cola que
tengan recorrido aprobado, y deja las demás «bloqueadas» en el mapa con su pregunta.

Cierra con este contrato y empieza. **El reloj arranca al cerrar el contrato**, no con la frase de
activación:

```
Cola: <pieza> · <pieza> · <pieza> · <pieza>   (mapa: <X> de <Y> al empezar)
Tiempo: <N> h · inicio <hora> · empiezo a cerrar a las <hora al 85 %> · lo encargado me toma ~<N> min
Me detengo si: se acaba la cola o el tiempo
Te aviso: al terminar o si me bloqueo del todo
```

El tiempo se mide con el reloj del sistema: corre `date` al empezar, anótalo en la bitácora y vuelve a
correrlo al terminar cada pieza. La sensación de la conversación no es un reloj.

Si el usuario escribe a media corrida, contéstale y sigue en modo autónomo con lo que te diga incorporado.
El modo termina solo si él lo pide («para», «sal del modo autónomo») o por las condiciones del contrato.

## Puede

- Trabajar en su propia rama o worktree. Nunca en `main`.
- Hacer commits y empujar **su** rama, aunque el empuje dispare una vista previa automática (Vercel u
  otro): eso no es publicar.
- Abrir el PR en borrador. Hasta ahí llega: **PR en borrador**.
- Crear datos de prueba locales.
- Instalar dependencias de desarrollo, justificándolo en la bitácora.

## Nunca

- Fusionar ni empujar a `main`.
- Publicar a producción o lanzar un despliegue a mano.
- Rodear un gate: `--no-verify`, o crear un `scripts/verificar-todo.sh` que pase siempre.
- Tocar producción o bases reales, ni aplicar migraciones remotas.
- Borrar trabajo, ramas o datos que no creó en esta sesión.
- Manejar secretos: ni leerlos para copiarlos, ni escribirlos, ni moverlos.
- Escribir a terceros (correo, mensajes, comentarios públicos).
- Gastar dinero ni cambiar la configuración de cuentas.

Si una pieza solo se puede terminar cruzando una de estas líneas, termina todo lo demás y déjale
el comando exacto para que lo corra él al volver.

## Durante el trabajo

- **La cola manda; el tiempo es un tope, no una meta.** Al terminar una pieza, toma la siguiente. Si la
  cola se acaba antes del 85 % del tiempo, detente y avisa; nunca inventes trabajo fuera de la cola.
- **Avance con los dos números**: «pieza 2 de 4 de la cola (mapa 8 de 12)». Al terminar una pieza,
  márcala «para ver» en el mapa; pasa a «hecho» cuando él la vea.
- **Una duda nueva que cambia lo que el usuario ve o sus datos**: salta la pieza, márcala en el mapa como
  «bloqueada: <la pregunta>», haz commit `wip:` de lo que avanzaste en ella, y sigue con la siguiente.
  No supongas.
- **Una decisión técnica, interna y reversible**: decide, márcala en el código con `SUPUESTO:` y anótala
  en la bitácora.
- **Commit por pieza terminada y verificada** (`verificacion.md`). En cualquier momento, lo hecho debe
  poder recuperarse.
- **Anti-atasco:** tras 3 intentos fallidos o ~45 min sin avanzar en una pieza, documenta dónde quedaste y
  qué probaste, y pasa a la siguiente.
- **Cuida la máquina** como dice el núcleo (§4). Si algo se cayó (Docker, una suite, la memoria), anota en
  la bitácora la hora, qué se perdió y qué rehiciste: eso va también en tu regreso.
- **No amplíes el alcance.** Lo que veas fuera de la cola va a «Lo que no quedó», en una línea.
- **Bitácora** en `docs/reportes/AAAA-MM-DD-autonomo-<tema>-bitacora.md`, dentro de tu rama, con
  `plantillas/bitacora-autonoma.md`. Una línea por evento, con la hora. Es para agentes y para el detalle.
- **Al ~85 % del tiempo deja de construir.** Lo que queda es verificar y preparar el regreso.

## Avisos

Solo dos: al terminar, o al bloquearte del todo sin nada más que hacer. Por notificación al celular con
la herramienta `PushNotification` (puede estar diferida: búscala con `ToolSearch`); si no existe, solo
chat. El aviso lleva la línea de avance. Nunca un aviso por cada decisión. Si hay varias sesiones con
orquestadora, el aviso lo manda solo ella (`coordinacion.md`).

## Al volver

Lo que el usuario recibe es verlo, no leerlo:

1. **Una línea de avance**: «hice 3 piezas en 55 min · 3 para ver · mapa: 7 de 12».
   Si algo se cayó, una línea más: «se cayó Docker a las 15:20; rehice las pruebas de la pieza 2 (8 min)».
2. **Míralo**: cuando él escriba, ábrelo en el navegador o muéstrale el recorrido o las capturas de cada
   pieza «para ver». Lo que no tiene pantalla, por su efecto (núcleo, §3 paso 6).
3. **Como máximo una pregunta**, con tu recomendación. Primero lo que impide empujar o terminar (un gate
   que no corre, un comando que le toca a él); si no hay, la pieza saltada que más destraba. Lo demás
   queda en el mapa como «bloqueada», y se pregunta después, de una en una.

Para el registro, escribe además `docs/reportes/AAAA-MM-DD-autonomo-<tema>.md` con
`plantillas/resumen-autonomo.md` (unas 150 palabras) e inclúyelo en el PR. Nada es «hecho» sin evidencia:
commit, prueba y su salida. Lo que no comprobaste dice «sin comprobar».
