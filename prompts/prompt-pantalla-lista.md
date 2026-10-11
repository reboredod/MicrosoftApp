# Prompt de hand-off — Pantalla de lista filtrable (scrLista)

Agrega una pantalla para buscar y filtrar los mantenimientos por estado, texto y ver
cuántos resultados hay. Complementa al cronograma (vista anual) con la vista operativa
del día a día.

**Uso:** chat en **claude.ai** con la extensión de Chrome activa y Power Apps Studio
abierto editando "Mantenimiento CChC".

---

```text
Tengo abierta en una pestaña de Chrome la aplicación Power Apps Studio editando una
app canvas llamada "Mantenimiento CChC". Necesito crear una pantalla de lista
filtrable de los mantenimientos.

════════════════════════════════════════
CONTEXTO IMPORTANTE ANTES DE EMPEZAR
════════════════════════════════════════

1. El editor está en ESPAÑOL. Eso cambia la sintaxis de las fórmulas:
   - Separador de argumentos: punto y coma `;`  (NO la coma)
   - Separador de instrucciones: doble punto y coma `;;`
   Copia las fórmulas EXACTAMENTE como están. No las "corrijas" cambiando `;` por `,`.

2. Cómo se cambia una propiedad:
   a. En "Vista de árbol" (panel izquierdo), haz clic en el control.
   b. Arriba a la izquierda hay un DESPLEGABLE DE PROPIEDADES. Ábrelo y elige la
      propiedad (o escribe su nombre para filtrarla).
   c. Escribe el valor en la barra de fórmulas y presiona Enter.

3. CÓMO INSERTAR UN CONTROL DENTRO DE UNA GALERÍA (esto es lo que más falla):
   - Haz clic en la galería EN EL LIENZO (no solo en el árbol).
   - Aparece un ícono de LÁPIZ en la primera fila: haz clic en el lápiz.
   - Recién entonces usa Insertar.
   - VERIFICA en el árbol que el control quedó INDENTADO bajo la galería.
   Si queda fuera, bórralo y repite. No sigas si quedó fuera.

4. ADVERTENCIAS:
   - NO toques la propiedad "Diseño" (Layout) de una galería: al cambiarla, Power Apps
     BORRA los controles que tiene dentro.
   - Si una propiedad da error en rojo, DETENTE y cópiame el mensaje exacto.
   - Si un control no aparece con el nombre que te doy, DETENTE y pregúntame.

════════════════════════════════════════
ESTADO ACTUAL DE LA APP
════════════════════════════════════════

Pantallas: scrCronograma (principal), scrDetalle, MainScreen1 (no la toques).

Variables globales y colecciones (creadas en App.OnStart):
  colMant  = copia de la lista SharePoint "Mantenimientos2026" (78 registros).
             Columnas: Título, Especialidad (búsqueda), TipoMantenimiento,
             FechaProgramada, FechaEjecucion, Estado, Proveedor, Observaciones, Sede.
  varMant  = el mantenimiento seleccionado (lo lee scrDetalle).
  Colores:  clrEjecutado, clrEjecucion, clrAtrasado, clrReprogramado,
            clrProgramado, clrCancelado, clrCorporativo.

════════════════════════════════════════
TAREAS (en este orden exacto)
════════════════════════════════════════

PASO 1 — Crear la pantalla
  - "Nueva pantalla" → "En blanco".
  - Renómbrala:  scrLista

PASO 2 — Encabezado
  Insertar → Etiqueta de texto.  Renómbrala:  lblTituloLista
      Text = "MANTENIMIENTOS 2026"
      X = 40   Y = 24   Ancho = 500   Alto = 32
      Tamaño de fuente = 20   Espesor = Negrita
      Color = clrCorporativo

  Insertar → Botón.  Renómbralo:  btnVolverCron
      Text = "← Cronograma"
      X = 1138   Y = 24   Ancho = 180   Alto = 36
      OnSelect = Navigate(scrCronograma; ScreenTransition.UnCover)

PASO 3 — Filtro por estado
  Insertar → busca "Lista desplegable" (Dropdown).  Renómbralo:  drpEstado
      X = 40   Y = 80   Ancho = 220   Alto = 40
      Items = ["Todos"; "Programado"; "En Ejecución"; "Ejecutado"; "Atrasado"; "Reprogramado"; "Cancelado"]
      Default = "Todos"

PASO 4 — Buscador de texto
  Insertar → "Entrada de texto" (Text input).  Renómbralo:  txtBuscar
      X = 280   Y = 80   Ancho = 400   Alto = 40
      Default = ""
      HintText = "Buscar por nombre..."

PASO 5 — Contador de resultados
  Insertar → Etiqueta de texto.  Renómbrala:  lblContador
      X = 700   Y = 88   Ancho = 300   Alto = 24
      Text = CountRows(galLista.AllItems) & " resultados"
  (Si da error porque galLista todavía no existe, déjalo para el final: crea primero
   la galería del PASO 6 y luego vuelve a poner esta fórmula.)

PASO 6 — La galería de resultados
  Insertar → "Galería vertical en blanco".  Renómbrala:  galLista
      X = 40   Y = 140   Ancho = 1286   Alto = 580
      Tamaño de plantilla (TemplateSize) = 44
      Items = (pega completa, una sola línea)

Sort(Filter(colMant; (drpEstado.Selected.Value = "Todos" || Estado.Value = drpEstado.Selected.Value) && (IsBlank(txtBuscar.Text) || StartsWith(Título; txtBuscar.Text))); FechaProgramada; SortOrder.Ascending)

PASO 7 — Contenido de cada fila (usa el truco del LÁPIZ del punto 3)
  Inserta DENTRO de galLista estas 4 etiquetas, una por una:

  a) lblLTitulo
       Text = ThisItem.Título
       X = 10   Y = 0   Ancho = 420   Alto = 44
       Tamaño de fuente = 12

  b) lblLEspecialidad
       Text = ThisItem.Especialidad.Value
       X = 440   Y = 0   Ancho = 300   Alto = 44
       Tamaño de fuente = 11
       Color = RGBA(75; 85; 99; 1)

  c) lblLFecha
       Text = Text(ThisItem.FechaProgramada; "dd/mm/yyyy")
       X = 750   Y = 0   Ancho = 120   Alto = 44
       Tamaño de fuente = 11

  d) lblLEstado
       Text = ThisItem.Estado.Value
       X = 890   Y = 7   Ancho = 160   Alto = 30
       Tamaño de fuente = 11
       Alineación de texto = Centro
       Fill = (pega completa, una sola línea)

Switch(ThisItem.Estado.Value; "Ejecutado"; clrEjecutado; "En Ejecución"; clrEjecucion; "Atrasado"; clrAtrasado; "Reprogramado"; clrReprogramado; "Cancelado"; clrCancelado; clrProgramado)

PASO 8 — Hacer clicable cada fila
  Selecciona galLista (la galería, no una etiqueta) → propiedad OnSelect:

Set(varMant; ThisItem);; Navigate(scrDetalle; ScreenTransition.Cover)

PASO 9 — Botón de acceso desde el cronograma
  - Ve a la pantalla scrCronograma.
  - Haz clic en una zona VACÍA (para no insertar dentro de una galería).
  - Insertar → Botón.  Renómbralo:  btnVerLista
      Text = "Ver lista"
      X = 978   Y = 24   Ancho = 140   Alto = 36
      OnSelect = Navigate(scrLista; ScreenTransition.Cover)

PASO 10 — Guardar
  Ctrl+S (o el icono de guardar arriba a la derecha).

════════════════════════════════════════
CÓMO QUIERO QUE TRABAJES
════════════════════════════════════════
- Ve paso por paso, en orden. No saltes pasos.
- Después de cada PASO, dime qué hiciste y si hubo algún problema.
- En el PASO 7, verifica SIEMPRE que la etiqueta quedó dentro de galLista antes de
  pasar a la siguiente.
- Las fórmulas largas (PASO 6 y PASO 7d) van COMPLETAS en una sola línea: verifica
  que no quedaron cortadas en la barra de fórmulas.
- Si aparece un error en rojo, DETENTE y cópiame el texto exacto.
- Al terminar, manda una captura de scrLista.

PRUEBA FINAL (hazla tú y cuéntame el resultado):
  1. Presiona ▶ (Vista previa).
  2. En el cronograma, presiona "Ver lista".
  3. Deben aparecer los 78 mantenimientos ordenados por fecha, con su estado en color.
  4. En el desplegable elige "Ejecutado": debe quedar solo el que marcaste antes.
  5. Vuelve a "Todos" y escribe "Clima" en el buscador: deben quedar los 4 de
     Mantenimiento Clima.
  6. Haz clic en una fila: debe abrirse scrDetalle con ese mantenimiento.
  7. Esc para salir.
```
