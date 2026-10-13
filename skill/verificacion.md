# Verificación

Antes de decir que algo está listo. Cada regla salió de un incidente real.

## Una prueba que nadie vio fallar no prueba nada

Escrita la prueba y en verde, toca romper la guarda: quita la línea que la prueba protege, mira la prueba
ponerse en rojo con el mensaje esperado y restaura. Si no se pone roja, la prueba no mide lo que crees.
Ya pasó que una prueba en verde pasaba por la razón equivocada.

## Si la salida sería igual estando bien y estando mal, no comprueba nada

Antes de creer una comprobación, pregúntate qué saldría si estuviera mal. Un `grep` negativo no demuestra
ausencia: afloja el patrón y confirma que encuentra algo cuando debe. Una coincidencia que parece la
buena es peor que ninguna. Casos reales: `git check-ignore` sobre un archivo ya rastreado (contesta «no
coincide» aunque la regla esté rota), un `grep` con un espacio de menos y un `grep` que encontró el
fixture de la prueba en vez del código.

## Cada negativa lleva su positiva

Una prueba de «esto se rechaza» va acompañada, en la misma corrida y sobre el mismo sujeto, de una de
«esto otro sí pasa». Sin la positiva, «cero filas» puede significar «tabla vacía» y no «tabla cerrada».

## Permisos: todos los perfiles, incluido lo que cada uno no debe ver

Prueba cada perfil, y en cada uno lo que **no debe ver** además de lo que sí. Nunca pruebes con el rol que
oculta el defecto: un administrador ve todo y no delata una fuga entre clientes.

## Sin mocks de la base de datos

Las pruebas corren contra una base real, para que los triggers, las restricciones y la seguridad por
renglón se ejecuten de verdad. Un mock los esquiva.

## Omitido no es verde

Un gate que no corrió es un gate fallido. Si el tipado, el build o la suite no se ejecutaron, el resultado
es «sin comprobar», nunca «pasó». Ya se empujaron ramas sin que el tipado ni el build hubieran corrido
nunca.

Un gate rodeado tampoco cuenta: `git commit --no-verify`, `git push --no-verify` o un
`scripts/verificar-todo.sh` que solo hace `exit 0` son «omitido» disfrazado de verde. Si el proyecto no
tiene suite completa, el push no sale: díselo al usuario y pregúntale qué prefiere.

## La pantalla, en la vista previa y en el teléfono

Antes de fusionar, abre la pantalla en el despliegue de vista previa y en el teléfono. Hidratación rota,
sesión que no entra o montos en «$0» por una consulta fallida pasaron con la suite en verde. Y una pieza
no está lista hasta que el usuario la vio funcionando.

## Specs y planes, revisados antes de mostrarse

Antes de que el usuario vea una spec o un plan, otro agente intenta romperlo: contradicciones, casos que
no cubre, supuestos falsos, nombres que no coinciden con el código. Entre el 2 y el 13 de octubre de 2026,
20 de 68 specs y planes se corrigieron después de escritos; el usuario se enteraba tarde y dejó de
confiar en ellos. A él solo se le dice, en 1-3 líneas, qué cambió con la revisión.

## «Debería funcionar» no es verificación

Corre los comandos y reporta su salida real. Si algo falla, dilo con la salida. Si algo no se pudo
comprobar, dilo con esas palabras. Nunca reportes como terminado algo que no ejecutaste.

## Cuando algo no cede

No propongas arreglos a la primera hipótesis. Usa `superpowers:systematic-debugging`: lee el error
completo, reprodúcelo, forma una hipótesis y compruébala antes de cambiar nada. La corrección «obvia»
puede ser el bug: obedecer una regla de ESLint que pedía mover una lectura de `localStorage` al
inicializador de `useState` habría roto la hidratación del servidor.
