# Power App "Mantenimiento CChC" — Kit de construcción

App **canvas** (formato tableta), conectada a SharePoint estándar. No requiere Dataverse
ni licencia premium. Todas las fórmulas están listas para copiar y pegar.

> ⚠️ **Separador de fórmulas según idioma del editor.** Las fórmulas de este documento
> usan la sintaxis **en inglés** (coma `,` entre argumentos, punto y coma `;` entre
> instrucciones). Si tu Power Apps está en **español** (u otro idioma con coma decimal),
> el editor usa **`;` entre argumentos** y **`;;` entre instrucciones**. Regla de
> traducción: cambia cada `,` por `;`, y cada `;` que separa instrucciones completas por
> `;;`. Ej: `Set(a, 1); Set(b, 2)` → `Set(a; 1);; Set(b; 2)`. Power Apps guarda la fórmula
> igual internamente; solo cambia cómo se escribe/ve según tu idioma.

## Arranque rápido (recomendado)
1. En https://make.powerapps.com → **+ Crear** → **Aplicación en lienzo** → formato *Tableta*.
   (Atajo: desde tu lista `Mantenimientos2026` en SharePoint → **Integrar → Power Apps →
   Crear una aplicación** genera una app base de 3 pantallas que luego personalizas.)
2. **Datos → Agregar datos:** conecta `Especialidades`, `Mantenimientos2026` y la biblioteca
   `DocumentosMantenimiento` (SharePoint).
3. Crea las 5 pantallas siguientes y pega las fórmulas.

## Convenciones de nombres
`scr` pantalla · `gal` galería · `frm` formulario · `btn` botón · `lbl` etiqueta ·
`txt` entrada de texto · `drp` desplegable · `dpk` selector de fecha · `ico` icono ·
`var` variable global · `loc` variable de contexto · `col` colección.

---

## App.OnStart — variables de color y datos
```powerfx
// Paleta de estados (misma lógica de colores que la planilla original)
Set(clrProgramado,   RGBA(200, 200, 200, 1));   // gris  = programado
Set(clrEjecucion,    RGBA(255, 214,  0, 1));     // amarillo = en ejecución
Set(clrEjecutado,    RGBA(76, 175, 80, 1));      // verde = ejecutado
Set(clrAtrasado,     RGBA(229, 57, 53, 1));      // rojo  = atrasado
Set(clrReprogramado, RGBA(30, 136, 229, 1));     // azul  = reprogramado
Set(clrVacio,        RGBA(245, 245, 245, 1));    // sin programación
Set(clrCorporativo,  RGBA(0, 51, 102, 1));       // azul CChC (cabeceras)
Set(varAnio, 2026);
```

---

## scrCronograma — carta Gantt (pantalla principal)

Réplica visual de la planilla: filas = especialidades por fase, columnas = ENE…DIC.

**scrCronograma.OnVisible**
```powerfx
ClearCollect(colMant, Mantenimientos2026);   // copia en memoria: Month()/Year() no son delegables
ClearCollect(
    colMeses,
    Table(
        {N:1,Etq:"ENE"},{N:2,Etq:"FEB"},{N:3,Etq:"MAR"},{N:4,Etq:"ABR"},
        {N:5,Etq:"MAY"},{N:6,Etq:"JUN"},{N:7,Etq:"JUL"},{N:8,Etq:"AGO"},
        {N:9,Etq:"SEP"},{N:10,Etq:"OCT"},{N:11,Etq:"NOV"},{N:12,Etq:"DIC"}
    )
);
```

**Cabecera (etiquetas):**
- `lblTitulo.Text = "CRONOGRAMA DE MANTENIMIENTO " & varAnio`
- `lblProyecto.Text = "Cámara Chilena de la Construcción — Apoquindo"`
- `lblResponsable.Text = "Responsable: Operaciones CChC - David Reboredo"`

**KPIs:**
```powerfx
// lblKpiEjecutados.Text
"Ejecutados: " & CountRows(Filter(colMant, Estado.Value = "Ejecutado"))
// lblKpiAtrasados.Text
"Atrasados: " & CountRows(Filter(colMant, Estado.Value = "Atrasado"))
// lblKpiAvance.Text
"Avance: " & Round( CountRows(Filter(colMant, Estado.Value="Ejecutado")) /
    Max(CountRows(colMant),1) * 100, 0) & "%"
```

**galEsp** (galería vertical) — filas de especialidades:
- `galEsp.Items = SortByColumns(Especialidades, "Fase", Ascending, "Title", Ascending)`
- Dentro: `lblEsp.Text = ThisItem.Title`  ·  `lblFase.Text = ThisItem.Fase.Value`

**galMeses** (galería horizontal, DENTRO de galEsp) — 12 celdas por fila:
- `galMeses.Items =`
```powerfx
ForAll(colMeses As M, { Mes: M.N, EspTitle: ThisItem.Title })
```
  *(aquí `ThisItem` es la especialidad del galería externa)*

**celda** (etiqueta `lblCelda` dentro de galMeses):
- `lblCelda.Fill =`
```powerfx
With(
    { reg: LookUp(colMant,
        Especialidad.Value = ThisItem.EspTitle && Month(FechaProgramada) = ThisItem.Mes) },
    Switch( reg.Estado.Value,
        "Ejecutado",     clrEjecutado,
        "En Ejecución",  clrEjecucion,
        "Atrasado",      clrAtrasado,
        "Reprogramado",  clrReprogramado,
        "Programado",    clrProgramado,
        clrVacio
    )
)
```
- `lblCelda.OnSelect =`
```powerfx
With(
    { reg: LookUp(colMant,
        Especialidad.Value = ThisItem.EspTitle && Month(FechaProgramada) = ThisItem.Mes) },
    If( !IsBlank(reg.ID),
        Navigate(scrDetalle, ScreenTransition.Cover, { locMant: reg })
    )
)
```

---

## scrLista — lista filtrable (delegable)

**Controles de filtro:** `drpFase` (Items: `["Todas","1. Aseo, Higiene y Seguridad","2. Infraestructura, Cocina y Control Centralizado","3. Otros"]`),
`drpEstado`, `drpTipo`, `txtBuscar`.

**galLista.Items** (funciones delegables sobre columnas indexadas):
```powerfx
Filter(
    Mantenimientos2026,
    (drpEstado.Selected.Value = "Todos" || Estado.Value = drpEstado.Selected.Value) &&
    (drpTipo.Selected.Value = "Todos"  || TipoMantenimiento.Value = drpTipo.Selected.Value) &&
    (IsBlank(txtBuscar.Text) || StartsWith(Title, txtBuscar.Text))
)
```
- Ordenar: envolver en `SortByColumns(..., "FechaProgramada", Ascending)`.
- El filtro por Fase se hace sobre la columna de la especialidad; si se necesita, agregar
  una columna `Fase` calculada al crear el registro para mantener la delegación.

---

## scrDetalle — detalle + documentos + acciones

Recibe `locMant` por `Navigate`. Usa `frmDetalle` (Formulario de edición) con
`DataSource = Mantenimientos2026`, `Item = locMant`.

**galDocs** — documentos de la carpeta del mantenimiento:
```powerfx
// galDocs.Items
Filter('DocumentosMantenimiento', IDMantenimiento = locMant.ID)
```
- `lblDoc.Text = ThisItem.'Nombre del archivo con extensión'`
- `lblTipoDoc.Text = ThisItem.TipoDocumento.Value`
- `icoAbrir.OnSelect = Launch(ThisItem.'Vínculo al elemento')`

**Botones de acción:**
```powerfx
// btnEnEjecucion.OnSelect
Patch(Mantenimientos2026, locMant, { Estado: {Value:"En Ejecución"} });
Set(locMant, LookUp(Mantenimientos2026, ID = locMant.ID));

// btnEjecutado.OnSelect  (pide fecha en dpkEjec y notas en txtNotas)
Patch(Mantenimientos2026, locMant,
    { Estado: {Value:"Ejecutado"}, FechaEjecucion: dpkEjec.SelectedDate,
      Observaciones: txtNotas.Text });
Set(locMant, LookUp(Mantenimientos2026, ID = locMant.ID));
Notify("Mantenimiento marcado como ejecutado", NotificationType.Success);

// btnReprogramar.OnSelect  (nueva fecha en dpkNueva)
Patch(Mantenimientos2026, locMant,
    { Estado: {Value:"Reprogramado"}, FechaProgramada: dpkNueva.SelectedDate });
Set(locMant, LookUp(Mantenimientos2026, ID = locMant.ID));

// btnAbrirCarpeta.OnSelect  — abre la carpeta directo en SharePoint
Launch(locMant.CarpetaDocumentos.Value)

// btnSubirDoc.OnSelect
Navigate(scrSubirDoc, ScreenTransition.Cover, { locMant: locMant })
```

---

## scrSubirDoc — subir documento (llama a FLX-GuardarDocumento)

Controles: `attArchivo` (control **Adjuntar archivo** o **Agregar imagen**/media),
`drpTipoDoc` (Items = los 6 tipos), `txtComentario`.

**btnGuardar.OnSelect** (el flujo `FLX-GuardarDocumento` debe estar agregado en *Power Automate*):
```powerfx
Set(locResultado,
    FLXGuardarDocumento.Run(
        { file: { name: First(attArchivo.Attachments).Name,
                  contentBytes: First(attArchivo.Attachments).Value } },   // ArchivoContenido
        First(attArchivo.Attachments).Name,                                // NombreArchivo
        locMant.ID,                                                        // IDMantenimiento
        drpTipoDoc.Selected.Value,                                         // TipoDocumento
        txtComentario.Text                                                 // Comentario
    )
);
If( locResultado.enlacearchivo <> "ERROR",
    Notify("Documento guardado en SharePoint", NotificationType.Success);
    Navigate(scrDetalle, ScreenTransition.UnCover, { locMant: locMant }),
    Notify("Error al guardar. Intenta nuevamente.", NotificationType.Error)
)
```
> El nombre exacto de la acción del flujo (`FLXGuardarDocumento.Run`) y de sus parámetros
> los rellena Power Apps al agregar el flujo; ajusta según lo que muestre el editor.

---

## scrNuevoCorrectivo — registrar mantenimiento no planificado

`frmCorrectivo` (Formulario **nuevo**, `DataSource = Mantenimientos2026`, `DefaultMode = New`).

**btnCrear.OnSelect**
```powerfx
Set(locNuevo,
    Patch(Mantenimientos2026, Defaults(Mantenimientos2026),
        { Title: drpEspecialidad.Selected.Title & " - CORRECTIVO " & Text(dpkFecha.SelectedDate,"yyyy-mm-dd"),
          Especialidad: { Id: drpEspecialidad.Selected.ID,
                          Value: drpEspecialidad.Selected.Title },
          TipoMantenimiento: { Value: "Correctivo" },
          FechaProgramada: dpkFecha.SelectedDate,
          Estado: { Value: "Programado" },
          Proveedor: txtProveedor.Text,
          Observaciones: txtDescripcion.Text }
    )
);
Notify("Correctivo registrado. Sube los documentos desde el detalle.", NotificationType.Success);
Navigate(scrDetalle, ScreenTransition.Cover, { locMant: locNuevo })
```
- `drpEspecialidad.Items = Especialidades`
> La carpeta del correctivo se crea al subir el primer documento (FLX-GuardarDocumento la
> resuelve por ruta) o puedes añadir una llamada a un flujo de creación de carpeta aquí.

---

## Notas de delegación y rendimiento
- `colMant` (copia en memoria) permite `Month()`/`Year()` en el cronograma sin advertencias.
  El volumen anual (~150–250 registros) está muy por debajo del umbral. Aun así, sube el
  límite de fila de datos de la app a 2000 (Configuración → General).
- En `scrLista` se usan `Filter`, `StartsWith`, `SortByColumns` sobre columnas **indexadas**
  (Estado, FechaProgramada) para mantener la delegación en SharePoint.
- Colores y estados coinciden 1:1 con la carta Gantt original para que la transición sea natural.
