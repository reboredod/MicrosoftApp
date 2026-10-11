# Prompt de hand-off — Crear la pantalla de detalle (scrDetalle)

**Uso:** chat en **claude.ai** con la extensión de Chrome activa y la pestaña de
**Power Apps Studio** abierta editando la app "Mantenimiento CChC".

> Si la automatización se traba (sobre todo en "Editar campos" del formulario), los
> mismos pasos están en `app/App-BuildKit.md` para hacerlos a mano.

---

```text
Tengo abierta en una pestaña de Chrome la aplicación Power Apps Studio editando una
app canvas llamada "Mantenimiento CChC". Necesito que crees una nueva pantalla de
detalle y la conectes con el cronograma que ya existe.

════════════════════════════════════════
CONTEXTO IMPORTANTE ANTES DE EMPEZAR
════════════════════════════════════════

1. El editor está en ESPAÑOL. Eso cambia la sintaxis de las fórmulas:
   - Separador de argumentos: punto y coma `;`  (NO la coma)
   - Separador de instrucciones: doble punto y coma `;;`
   Ejemplo: Navigate(scrDetalle; ScreenTransition.Cover)
   Copia las fórmulas EXACTAMENTE como están escritas más abajo. No las "corrijas"
   cambiando `;` por `,`.

2. Cómo se cambia una propiedad (hazlo siempre así):
   a. En el panel izquierdo "Vista de árbol", haz clic en el control.
   b. Arriba a la izquierda hay un DESPLEGABLE DE PROPIEDADES (muestra el nombre de
      una propiedad, ej. "Fill"). Ábrelo y elige la propiedad, o escribe su nombre
      para filtrarla.
   c. Escribe el valor en la barra de fórmulas y presiona Enter.

3. Cómo se inserta un control dentro de otro (galería/contenedor):
   Primero selecciona el contenedor EN EL LIENZO (no solo en el árbol); si aparece un
   ícono de lápiz, haz clic en él para entrar a la plantilla. Recién entonces usa
   Insertar. Verifica en el árbol que el control nuevo quedó INDENTADO bajo su padre.

4. ADVERTENCIAS (respétalas):
   - NO toques la propiedad "Diseño" (Layout) de una galería: al cambiarla, Power Apps
     BORRA los controles que tiene dentro.
   - Si una propiedad muestra un error en rojo, DETENTE y cópiame el mensaje.
   - Si un control no aparece con el nombre exacto que te doy, DETENTE y pregúntame.

════════════════════════════════════════
ESTADO ACTUAL DE LA APP
════════════════════════════════════════

Pantallas existentes: scrCronograma (la principal) y MainScreen1 (no la toques).

Árbol de scrCronograma:
  scrCronograma
  ├─ lblTitulo, lblSubtitulo, lblKpiEjecutados, lblKpiAtrasados, lblKpiAvance
  ├─ btnActualizar
  ├─ galHeaderMeses → lblHeaderMes
  └─ galEsp  (Items = Especialidades As Esp)
      ├─ Title2, Rectangle2, Separator2
      └─ GalMeses  (Items = colMeses)
          └─ lblCelda

Variables y colecciones que ya existen (creadas en App.OnStart):
  colMant   = copia de la lista SharePoint "Mantenimientos2026" (78 registros)
  colMeses  = tabla de 12 meses con columnas N (número) y Etq (ENE, FEB, ...)

════════════════════════════════════════
TAREAS (en este orden exacto)
════════════════════════════════════════

PASO 1 — Crear la pantalla de detalle
  - Menú superior: "Nueva pantalla" → opción "En blanco".
  - Renombra la pantalla nueva a:  scrDetalle
    (En el árbol: clic en los tres puntos ⋯ del nombre → Cambiar nombre.)

PASO 2 — Hacer clicables las celdas del cronograma
  - Ve a scrCronograma y selecciona el control  lblCelda
    (está dentro de GalMeses, que está dentro de galEsp).
  - Propiedad: OnSelect
  - Pega exactamente esto:

Set(varMant; LookUp(colMant; Especialidad.Id = Esp.ID && Month(FechaProgramada) = ThisItem.N));; If(!IsBlank(varMant.ID); Navigate(scrDetalle; ScreenTransition.Cover))

PASO 3 — Botón para volver
  - Ve a scrDetalle. Asegúrate de que NO haya ningún control seleccionado dentro de
    otro contenedor (haz clic en una zona vacía de la pantalla).
  - Insertar → Botón.
  - Renómbralo:  btnVolver
  - Propiedades:
      Text    = "← Volver al cronograma"
      OnSelect = Back()
      X = 40    Y = 24    Ancho = 200    Alto = 36

PASO 4 — Formulario con los datos del mantenimiento
  - En scrDetalle: Insertar → busca "Formulario de visualización"
    (en inglés: Display form). Insértalo.
  - Renómbralo:  frmDetalle
  - Propiedades:
      DataSource = Mantenimientos2026
      Item       = varMant
      X = 40    Y = 80    Ancho = 900    Alto = 500
  - Con frmDetalle seleccionado, en la barra superior aparece "Editar campos"
    (o en el panel derecho, sección Campos). Ábrelo y AGREGA estos campos:
      Título, Especialidad, TipoMantenimiento, FechaProgramada, FechaEjecucion,
      Estado, Proveedor, ResponsableInterno, Observaciones, Sede
    Si alguno no está disponible, agrégalos igual y dime cuál faltó.

PASO 5 — Guardar
  - Ctrl+S (o el icono de guardar arriba a la derecha).

════════════════════════════════════════
CÓMO QUIERO QUE TRABAJES
════════════════════════════════════════
- Ve paso por paso, en orden. No saltes pasos.
- Después de cada PASO, dime qué hiciste y si hubo algún problema.
- Si algo no coincide con lo que te describí, DETENTE y pregúntame antes de improvisar.
- Si aparece un error en rojo, DETENTE y cópiame el texto exacto.
- Al terminar, manda una captura de scrDetalle.

PRUEBA FINAL (hazla tú y cuéntame el resultado):
  1. Presiona el botón ▶ (Vista previa / Play).
  2. En el cronograma, haz clic en una celda QUE TENGA COLOR (no en una celda casi
     blanca, esas no tienen mantención).
  3. Debe abrirse scrDetalle mostrando los datos de ese mantenimiento.
  4. El botón "← Volver al cronograma" debe regresar al cronograma.
  5. Presiona Esc para salir de la vista previa.
```
