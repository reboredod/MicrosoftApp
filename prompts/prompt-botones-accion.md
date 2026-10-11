# Prompt de hand-off — Botones de acción en scrDetalle

Agrega a la pantalla de detalle los controles para **cambiar el estado del
mantenimiento desde la app**, sin entrar a SharePoint.

**Uso:** chat en **claude.ai** con la extensión de Chrome activa y Power Apps Studio
abierto editando "Mantenimiento CChC".

---

```text
Tengo abierta en una pestaña de Chrome la aplicación Power Apps Studio editando una
app canvas llamada "Mantenimiento CChC". Necesito agregar botones de acción a la
pantalla "scrDetalle" para cambiar el estado de los mantenimientos.

════════════════════════════════════════
CONTEXTO IMPORTANTE ANTES DE EMPEZAR
════════════════════════════════════════

1. El editor está en ESPAÑOL. Eso cambia la sintaxis de las fórmulas:
   - Separador de argumentos: punto y coma `;`  (NO la coma)
   - Separador de instrucciones: doble punto y coma `;;`
   Copia las fórmulas EXACTAMENTE como están. No las "corrijas" cambiando `;` por `,`.
   Son largas: pégalas completas, en una sola línea.

2. Cómo se cambia una propiedad:
   a. En "Vista de árbol" (panel izquierdo), haz clic en el control.
   b. Arriba a la izquierda hay un DESPLEGABLE DE PROPIEDADES. Ábrelo y elige la
      propiedad (o escribe su nombre para filtrarla).
   c. Escribe el valor en la barra de fórmulas y presiona Enter.

3. Al insertar un control nuevo en scrDetalle, asegúrate de que NO quede dentro del
   formulario: antes de insertar, haz clic en una zona VACÍA de la pantalla. Verifica
   en el árbol que el control nuevo cuelga de scrDetalle, no de frmDetalle.

4. Si una propiedad da error en rojo, DETENTE y cópiame el mensaje exacto.
   Si un control no aparece con el nombre que te doy, DETENTE y pregúntame.

════════════════════════════════════════
ESTADO ACTUAL
════════════════════════════════════════

Pantalla scrDetalle contiene:
  btnVolver    (botón "← Volver al cronograma")
  frmDetalle   (formulario de visualización, DataSource = Mantenimientos2026,
                Item = varMant)

Variable global existente:
  varMant  = el registro de mantenimiento seleccionado en el cronograma
  colMant  = colección con la copia de la lista "Mantenimientos2026"

════════════════════════════════════════
TAREAS (en este orden exacto)
════════════════════════════════════════

PASO 1 — Arreglar el botón Volver (su texto se corta)
  Selecciona btnVolver y ajusta:
      Ancho (Width) = 240
      Alto (Height) = 36
      Tamaño de fuente = 12

PASO 2 — Título de la sección de acciones
  Insertar → Etiqueta de texto.  Renómbrala:  lblAcciones
      Text = "Registrar avance"
      X = 40    Y = 600    Ancho = 300    Alto = 24
      Espesor de la fuente = Negrita
      Tamaño de fuente = 14

PASO 3 — Selector de fecha
  Insertar → busca "Selector de fecha" (Date picker).  Renómbralo:  dpkFechaAccion
      X = 40    Y = 630    Ancho = 200    Alto = 36
      DefaultDate = Today()

PASO 4 — Campo de observaciones
  Insertar → busca "Entrada de texto" (Text input).  Renómbralo:  txtObservaciones
      X = 260   Y = 630   Ancho = 420   Alto = 36
      Default = ""
      HintText = "Observaciones (opcional)"

PASO 5 — Botón "En ejecución"
  Insertar → Botón.  Renómbralo:  btnEnEjecucion
      Text = "En ejecución"
      X = 40    Y = 680    Ancho = 180    Alto = 40
      Fill = RGBA(255; 214; 0; 1)
      Color = RGBA(31; 41; 55; 1)
      OnSelect = (pega esta fórmula completa, en una sola línea)

Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "En Ejecución"}});; ClearCollect(colMant; Mantenimientos2026);; Set(varMant; LookUp(colMant; ID = varMant.ID));; Notify("Marcado como En Ejecución"; NotificationType.Success)

PASO 6 — Botón "Marcar ejecutado"
  Insertar → Botón.  Renómbralo:  btnEjecutado
      Text = "Marcar ejecutado"
      X = 230   Y = 680   Ancho = 180   Alto = 40
      Fill = RGBA(76; 175; 80; 1)
      OnSelect = (pega esta fórmula completa, en una sola línea)

Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "Ejecutado"}; FechaEjecucion: dpkFechaAccion.SelectedDate; Observaciones: txtObservaciones.Text});; ClearCollect(colMant; Mantenimientos2026);; Set(varMant; LookUp(colMant; ID = varMant.ID));; Notify("Mantenimiento marcado como Ejecutado"; NotificationType.Success)

PASO 7 — Botón "Reprogramar"
  Insertar → Botón.  Renómbralo:  btnReprogramar
      Text = "Reprogramar"
      X = 420   Y = 680   Ancho = 180   Alto = 40
      Fill = RGBA(30; 136; 229; 1)
      OnSelect = (pega esta fórmula completa, en una sola línea)

Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "Reprogramado"}; FechaProgramada: dpkFechaAccion.SelectedDate});; ClearCollect(colMant; Mantenimientos2026);; Set(varMant; LookUp(colMant; ID = varMant.ID));; Notify("Mantenimiento reprogramado"; NotificationType.Success)

PASO 8 — Guardar
  Ctrl+S (o el icono de guardar arriba a la derecha).

════════════════════════════════════════
CÓMO QUIERO QUE TRABAJES
════════════════════════════════════════
- Ve paso por paso, en orden. No saltes pasos.
- Después de cada PASO, dime qué hiciste y si hubo algún problema.
- Las fórmulas de los pasos 5, 6 y 7 son largas: pégalas COMPLETAS y verifica que
  quedaron enteras en la barra de fórmulas antes de seguir.
- Si aparece un error en rojo, DETENTE y cópiame el texto exacto.
- Al terminar, manda una captura de scrDetalle.

PRUEBA FINAL (hazla tú y cuéntame el resultado):
  1. Presiona ▶ (Vista previa).
  2. En el cronograma, clic en una celda con color (por ejemplo FEB de "Lavado de
     Alfombra y Muebles").
  3. En scrDetalle, elige una fecha, escribe una observación y presiona
     "Marcar ejecutado".
  4. Debe aparecer un aviso verde y el campo Estado del formulario debe cambiar a
     "Ejecutado".
  5. Vuelve al cronograma con "← Volver": esa celda debe estar ahora VERDE.
  6. Esc para salir.
```
