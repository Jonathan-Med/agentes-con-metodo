<!-- Archivo: docs/superpowers/plans/AAAA-MM-DD-<tema>.md -->

# <Tema> · Plan de implementación

> **Para quien lo ejecute:** SUB-SKILL REQUERIDA: `superpowers:subagent-driven-development` o
> `superpowers:executing-plans`, tarea por tarea. Los pasos usan casillas (`- [ ]`).

**Meta:** <una frase>

**Arquitectura:** <un párrafo>

**Spec:** `docs/superpowers/specs/<archivo>.md`. Se lee junto con este plan; cada tarea cita su sección.

## Restricciones globales

Aplican a todas las tareas y no se repiten en cada una.

- <idioma, versiones, reglas de migraciones y permisos, cómo correr las pruebas>

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|

## Tarea 1 · <resultado, no actividad>

<una frase de por qué>

**Archivos:** Crear `<ruta>` · Modificar `<ruta>`

**Interfaces:** Produce `<nombre y forma exactos>` · Consume `<de qué tarea>`

- [ ] **Paso 1: Escribir la prueba que falla** <código completo>
- [ ] **Paso 2: Verla fallar.** Run: `<comando>` → Esperado: <mensaje>
- [ ] **Paso 3: Implementar** <código completo>
- [ ] **Paso 4: Verla pasar.** Run: `<comando>` → Esperado: <resultado>
- [ ] **Paso 5: Romper la guarda.** Quitar <qué> → Esperado: <qué prueba en rojo y con qué mensaje> →
  restaurar.
- [ ] **Paso 6: Commit.** `git commit -m "feat(<alcance>): <qué>"`

## Tarea final · Cierre

- [ ] Suite completa en verde, con la salida pegada en el reporte.
- [ ] Build.
- [ ] La pantalla en la vista previa y en el teléfono.
- [ ] Al usuario: muéstraselo funcionando y actualiza el mapa (núcleo, §3 paso 6).
- [ ] Reporte con `plantillas/reporte.md`.
- [ ] Rama empujada y PR abierto.

## Autorrevisión

| Sección de la spec | Tarea |
|---|---|

- **Nombres comprobados entre tareas:** <…>
- **Sin huecos:** cada paso lleva el código o el comando completo.
