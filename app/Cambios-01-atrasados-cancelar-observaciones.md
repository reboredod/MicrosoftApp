# Cambios 01 — Atrasados automáticos, botón Cancelar y Observaciones

Resuelve los puntos 1, 3 y 4 de la lista de mejoras. Son **ediciones de fórmulas** sobre
lo que ya existe, más **un botón nuevo**. No se crean pantallas.

> ✍️ **Hazlo tú con copiar/pegar**, no con el agente de la extensión: las fórmulas son
> largas y el agente escribe a mano. Pegar es más rápido y sin riesgo de tipeo.
>
> Recuerda: separadores **`;`** entre argumentos y **`;;`** entre instrucciones.

---

## La idea detrás del cambio

"Atrasado" no es un estado que alguien elija: **se deduce** de que la fecha pasó y nadie
ejecutó ni reprogramó. Por eso no lo escribimos en SharePoint — lo **calculamos al cargar
los datos**, en una columna nueva llamada `EstadoReal`.

```
EstadoReal = "Atrasado"  si la fecha ya pasó y el estado es Programado o Reprogramado
EstadoReal = el estado guardado  en cualquier otro caso
```

Ventaja: siempre está correcto, sin depender de que un flujo corra cada día. A partir de
aquí, **todas las pantallas leen `EstadoReal`** en vez de `Estado.Value`.

---

## BLOQUE A — Atrasados automáticos

### A1. App → `OnStart`
Reemplaza **todo** el contenido por esto:

```
Set(clrProgramado; RGBA(200; 200; 200; 1));;
Set(clrEjecucion; RGBA(255; 214; 0; 1));;
Set(clrEjecutado; RGBA(76; 175; 80; 1));;
Set(clrAtrasado; RGBA(229; 57; 53; 1));;
Set(clrReprogramado; RGBA(30; 136; 229; 1));;
Set(clrCancelado; RGBA(120; 120; 120; 1));;
Set(clrVacio; RGBA(245; 245; 245; 1));;
Set(clrCorporativo; RGBA(0; 51; 102; 1));;
Set(varAnio; 2026);;
ClearCollect(colMant; AddColumns(Mantenimientos2026; "EstadoReal"; If(FechaProgramada < Today() && (Estado.Value = "Programado" || Estado.Value = "Reprogramado"); "Atrasado"; Estado.Value)));;
ClearCollect(colMeses; Table({N:1; Etq:"ENE"}; {N:2; Etq:"FEB"}; {N:3; Etq:"MAR"}; {N:4; Etq:"ABR"}; {N:5; Etq:"MAY"}; {N:6; Etq:"JUN"}; {N:7; Etq:"JUL"}; {N:8; Etq:"AGO"}; {N:9; Etq:"SEP"}; {N:10; Etq:"OCT"}; {N:11; Etq:"NOV"}; {N:12; Etq:"DIC"}))
```

Después: clic derecho en **App → Ejecutar OnStart**.

### A2. `btnActualizar` → `OnSelect`  (en scrCronograma)

```
ClearCollect(colMant; AddColumns(Mantenimientos2026; "EstadoReal"; If(FechaProgramada < Today() && (Estado.Value = "Programado" || Estado.Value = "Reprogramado"); "Atrasado"; Estado.Value)))
```

### A3. `lblCelda` → `Fill`  (dentro de GalMeses)
Usa `EstadoReal` y además **filtra por año** (blinda el cronograma para 2027):

```
With({reg: LookUp(colMant; Especialidad.Id = Esp.ID && Month(FechaProgramada) = ThisItem.N && Year(FechaProgramada) = varAnio)}; Switch(reg.EstadoReal; "Ejecutado"; clrEjecutado; "En Ejecución"; clrEjecucion; "Atrasado"; clrAtrasado; "Reprogramado"; clrReprogramado; "Cancelado"; clrCancelado; "Programado"; clrProgramado; clrVacio))
```

### A4. `lblCelda` → `OnSelect`

```
Set(varMant; LookUp(colMant; Especialidad.Id = Esp.ID && Month(FechaProgramada) = ThisItem.N && Year(FechaProgramada) = varAnio));; If(!IsBlank(varMant.ID); Navigate(scrDetalle; ScreenTransition.Cover))
```

### A5. Los tres KPIs

**lblKpiEjecutados → Text**
```
"Ejecutados: " & CountRows(Filter(colMant; EstadoReal = "Ejecutado"))
```

**lblKpiAtrasados → Text**
```
"Atrasados: " & CountRows(Filter(colMant; EstadoReal = "Atrasado"))
```

**lblKpiAvance → Text**
```
"Avance: " & Round(CountRows(Filter(colMant; EstadoReal = "Ejecutado")) / Max(CountRows(colMant); 1) * 100; 0) & "%"
```

### A6. Pantalla scrLista

**galLista → Items**
```
Sort(Filter(colMant; (drpEstado.Selected.Value = "Todos" || EstadoReal = drpEstado.Selected.Value) && (IsBlank(txtBuscar.Text) || StartsWith(Título; txtBuscar.Text))); FechaProgramada; SortOrder.Ascending)
```

**lblLEstado → Text**
```
ThisItem.EstadoReal
```

**lblLEstado → Fill**
```
Switch(ThisItem.EstadoReal; "Ejecutado"; clrEjecutado; "En Ejecución"; clrEjecucion; "Atrasado"; clrAtrasado; "Reprogramado"; clrReprogramado; "Cancelado"; clrCancelado; clrProgramado)
```

---

## BLOQUE B — Botón Cancelar y Observaciones

Los tres botones existentes no guardaban las observaciones (salvo "Marcar ejecutado").
Ahora los cuatro las guardan, **sin borrar** lo anterior si dejas el campo vacío, y
limpian el campo después.

### B1. `btnEnEjecucion` → `OnSelect`
```
Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "En Ejecución"}; Observaciones: If(IsBlank(txtObservaciones.Text); varMant.Observaciones; txtObservaciones.Text)});; ClearCollect(colMant; AddColumns(Mantenimientos2026; "EstadoReal"; If(FechaProgramada < Today() && (Estado.Value = "Programado" || Estado.Value = "Reprogramado"); "Atrasado"; Estado.Value)));; Set(varMant; LookUp(colMant; ID = varMant.ID));; Reset(txtObservaciones);; Notify("Marcado como En Ejecución"; NotificationType.Success)
```

### B2. `btnEjecutado` → `OnSelect`
```
Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "Ejecutado"}; FechaEjecucion: dpkFechaAccion.SelectedDate; Observaciones: If(IsBlank(txtObservaciones.Text); varMant.Observaciones; txtObservaciones.Text)});; ClearCollect(colMant; AddColumns(Mantenimientos2026; "EstadoReal"; If(FechaProgramada < Today() && (Estado.Value = "Programado" || Estado.Value = "Reprogramado"); "Atrasado"; Estado.Value)));; Set(varMant; LookUp(colMant; ID = varMant.ID));; Reset(txtObservaciones);; Notify("Mantenimiento marcado como Ejecutado"; NotificationType.Success)
```

### B3. `btnReprogramar` → `OnSelect`
```
Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "Reprogramado"}; FechaProgramada: dpkFechaAccion.SelectedDate; Observaciones: If(IsBlank(txtObservaciones.Text); varMant.Observaciones; txtObservaciones.Text)});; ClearCollect(colMant; AddColumns(Mantenimientos2026; "EstadoReal"; If(FechaProgramada < Today() && (Estado.Value = "Programado" || Estado.Value = "Reprogramado"); "Atrasado"; Estado.Value)));; Set(varMant; LookUp(colMant; ID = varMant.ID));; Reset(txtObservaciones);; Notify("Mantenimiento reprogramado"; NotificationType.Success)
```

### B4. Botón nuevo: `btnCancelar`

En **scrDetalle**, haz clic en una zona vacía (para no insertarlo dentro del formulario)
y usa **Insertar → Botón**. Renómbralo **`btnCancelar`**.

| Propiedad | Valor |
|---|---|
| Text | `"Cancelar mantención"` |
| X | `610` · Y `680` · Ancho `180` · Alto `40` |
| Fill | `clrCancelado` |

**OnSelect:**
```
Patch(Mantenimientos2026; LookUp(Mantenimientos2026; ID = varMant.ID); {Estado: {Value: "Cancelado"}; Observaciones: If(IsBlank(txtObservaciones.Text); varMant.Observaciones; txtObservaciones.Text)});; ClearCollect(colMant; AddColumns(Mantenimientos2026; "EstadoReal"; If(FechaProgramada < Today() && (Estado.Value = "Programado" || Estado.Value = "Reprogramado"); "Atrasado"; Estado.Value)));; Set(varMant; LookUp(colMant; ID = varMant.ID));; Reset(txtObservaciones);; Notify("Mantención cancelada"; NotificationType.Warning)
```

---

## Verificación

1. **Guardar** y **Publicar**.
2. Abre el cronograma: los meses **ya pasados** de 2026 que siguen en "Programado"
   (enero a septiembre, y octubre hasta el día 5) deben verse **rojos**.
3. El KPI **Atrasados** debe mostrar un número alto (ya no 0).
4. En la lista, filtra por **Atrasado**: deben aparecer todos esos.
5. Entra a un mantenimiento, escribe una observación y presiona **Reprogramar**:
   la observación debe quedar guardada en el formulario.
6. Prueba **Cancelar mantención**: la celda debe quedar gris oscuro.

> ⚠️ Vas a ver **muchos rojos** de golpe: son todas las mantenciones de enero a
> septiembre que nunca se marcaron como ejecutadas. Es correcto — refleja la realidad.
> A medida que las vayas registrando, el cronograma se va poniendo verde.
