# Prompt de hand-off — Ajustar el diseño del cronograma en Power Apps

**Uso:** abre un chat en **claude.ai** (donde funciona la extensión de Chrome), deja
abierta la pestaña con **Power Apps Studio** editando la app "Mantenimiento CChC",
y pega el bloque de abajo.

> Nota: Power Apps Studio es un editor tipo lienzo; la automatización de navegador
> puede fallar al seleccionar controles o escribir fórmulas. Si se traba, los mismos
> valores están en `app/App-BuildKit.md` para aplicarlos a mano.

---

```text
Tengo abierta en una pestaña de Chrome la aplicación Power Apps Studio editando una
app canvas llamada "Mantenimiento CChC". Necesito que ajustes las propiedades de los
controles de la pantalla "scrCronograma" según el diseño que te detallo.

════════════════════════════════════════
CONTEXTO IMPORTANTE ANTES DE EMPEZAR
════════════════════════════════════════

1. El editor está en ESPAÑOL. Eso cambia la sintaxis de las fórmulas:
   - Separador de argumentos: punto y coma `;`  (NO la coma)
   - Separador de instrucciones: doble punto y coma `;;`
   Ejemplo: RGBA(255; 255; 255; 1)

2. Cómo se cambia una propiedad (hazlo siempre así):
   a. En el panel izquierdo "Vista de árbol", haz clic en el control.
   b. Arriba a la izquierda hay un DESPLEGABLE DE PROPIEDADES (muestra el nombre de
      una propiedad, ej. "Fill"). Ábrelo y elige la propiedad que vas a cambiar, o
      escribe su nombre para filtrarla.
   c. Escribe el valor en la barra de fórmulas y presiona Enter.
   Alternativa: varias de estas propiedades (X, Y, Ancho, Alto) también están en el
   panel "Propiedades" de la derecha, en los campos Posición y Tamaño. Úsalo si es
   más rápido.

3. ADVERTENCIAS (aprendidas a la mala, respétalas):
   - NO toques la propiedad "Diseño" (Layout) de ninguna galería: al cambiarla,
     Power Apps BORRA los controles que están dentro.
   - "Ajustar recuento" (WrapCount) en una galería HORIZONTAL es el número de FILAS.
     Debe quedar en 1.
   - "Tamaño de plantilla" (TemplateSize) no se puede leer desde otro control; usa
     siempre números literales.
   - Si una propiedad muestra un error en rojo, detente y dime qué dice. No improvises.

════════════════════════════════════════
ÁRBOL DE CONTROLES (así está hoy)
════════════════════════════════════════

scrCronograma
├─ lblTitulo
├─ lblSubtitulo
├─ lblKpiEjecutados
├─ lblKpiAtrasados
├─ lblKpiAvance
├─ btnActualizar
├─ galHeaderMeses
│   └─ lblHeaderMes
└─ galEsp
    ├─ Title2
    ├─ Rectangle2
    ├─ Separator2
    └─ GalMeses
        └─ lblCelda

════════════════════════════════════════
CAMBIOS A APLICAR (en este orden exacto)
════════════════════════════════════════

PASO 1 — galEsp
  Tamaño de plantilla (TemplateSize) = 28
  X = 88
  Y = 158
  Ancho (Width) = 1190
  Alto (Height) = 532

PASO 2 — Title2  (está dentro de galEsp)
  X = 14
  Y = 0
  Ancho = 276
  Alto = 28
  Tamaño de fuente = 11

PASO 3 — GalMeses  (está dentro de galEsp)
  X = 290
  Y = 0
  Ancho = 900
  Alto = 28
  Tamaño de plantilla = 75
  Ajustar recuento = 1
  Espaciado interno = 0

PASO 4 — lblCelda  (está dentro de GalMeses)  ← el cambio más importante
  Text = deja la propiedad VACÍA (borra todo su contenido; las celdas quedan como
         bloques de color sin texto)
  X = 0
  Y = 0
  Ancho (Width) = Parent.TemplateWidth
  Alto (Height) = Parent.TemplateHeight
  Grosor del borde (BorderThickness) = 1
  Color del borde (BorderColor) = RGBA(255; 255; 255; 1)

PASO 5 — galHeaderMeses
  X = 378
  Y = 126
  Ancho = 900
  Alto = 30
  Tamaño de plantilla = 75
  Ajustar recuento = 1
  Espaciado interno = 0

PASO 6 — lblHeaderMes  (está dentro de galHeaderMeses)
  X = 0
  Y = 0
  Ancho = Parent.TemplateWidth
  Alto = Parent.TemplateHeight

PASO 7 — Cabecera (cada uno su X e Y)
  lblTitulo          X = 88    Y = 24    Ancho = 760   Alto = 32
  lblSubtitulo       X = 88    Y = 58    Ancho = 900   Alto = 20
  lblKpiEjecutados   X = 88    Y = 86    Ancho = 180   Alto = 26
  lblKpiAtrasados    X = 268   Y = 86    Ancho = 180   Alto = 26
  lblKpiAvance       X = 448   Y = 86    Ancho = 200   Alto = 26
  btnActualizar      X = 1138  Y = 24    Ancho = 140   Alto = 36

PASO 8 — Guardar
  Presiona Ctrl+S (o el icono de guardar arriba a la derecha).

════════════════════════════════════════
CÓMO QUIERO QUE TRABAJES
════════════════════════════════════════
- Ve paso por paso, en orden. No saltes pasos.
- Después de cada PASO, dime qué aplicaste y si hubo algún problema.
- Si un control no aparece en el árbol con ese nombre exacto, DETENTE y pregúntame
  en vez de adivinar cuál es.
- Si aparece una X roja o un error en una propiedad, DETENTE y cópiame el mensaje.
- Al terminar, dime si quedó todo aplicado y manda una captura de la pantalla.

RESULTADO ESPERADO: un cronograma tipo carta Gantt con las 19 especialidades visibles
sin scroll, una barra azul de meses (ENE a DIC) perfectamente alineada sobre las
columnas, y las celdas como bloques de color sin texto.
```
