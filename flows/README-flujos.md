# Flujos de Power Automate — Mantenimiento CChC Apoquindo 2026

Cuatro flujos. Créalos en https://make.powerautomate.com con el conector **SharePoint**
(estándar, sin costo premium). Reemplaza `<SITE_URL>` por la URL de tu sitio en todos.

> Convención: los nombres internos de columnas coinciden con los creados por
> `deploy/Provision-SharePoint.ps1` (Fase, Frecuencia, MesesProgramados, Especialidad,
> TipoMantenimiento, FechaProgramada, FechaEjecucion, Estado, CarpetaDocumentos, etc.).

---

## FLX-GenerarPlanAnual
**Tipo:** Instantáneo (Desencadenar manualmente). Se corre **una vez** para generar el plan 2026.
**Qué hace:** por cada especialidad activa, crea un registro de mantenimiento por cada mes de
`MesesProgramados`, con su carpeta de documentos, y guarda el enlace de la carpeta en el registro.

1. **Desencadenador:** *Desencadenar manualmente un flujo*. (Opcional entrada `Anio` texto, por defecto `2026`.)
2. **Inicializar variable** `varAnio` (Cadena) = `2026`.
3. **Obtener elementos** (SharePoint) — Lista `Especialidades`
   - *Filtro de consulta (ODATA):* `Activa eq 1`
4. **Aplicar a cada uno** → salida de "Obtener elementos" (cada `especialidad`):
   1. **Componer** `Meses` = expresión `split(item()?['MesesProgramados'], ',')`
   2. **Aplicar a cada uno** → `outputs('Componer_Meses')` (cada `mes`):
      1. **Componer** `FechaProg` = `concat(variables('varAnio'), '-', item(), '-05')`
         → produce p.ej. `2026-02-05` (día 5 como fecha tentativa; se ajusta luego en la app).
      2. **Componer** `TituloMant` = `concat(items('Aplicar_a_cada_uno')?['Title'], ' - ', variables('varAnio'), '-', item())`
         *(referencia al Title de la especialidad del bucle externo)*
      3. **Componer** `RutaCarpeta` = `concat('DocumentosMantenimiento/', variables('varAnio'), '/', items('Aplicar_a_cada_uno')?['Fase']?['Value'], '/', items('Aplicar_a_cada_uno')?['Title'], '/', outputs('Componer_TituloMant'))`
      4. **Crear nueva carpeta** (SharePoint)
         - Dirección del sitio: `<SITE_URL>`
         - Lista/biblioteca: `DocumentosMantenimiento`
         - Ruta de carpeta: `outputs('Componer_RutaCarpeta')` sin el prefijo de biblioteca →
           usar `concat(variables('varAnio'), '/', items('Aplicar_a_cada_uno')?['Fase']?['Value'], '/', items('Aplicar_a_cada_uno')?['Title'], '/', outputs('Componer_TituloMant'))`
      5. **Crear elemento** (SharePoint) — Lista `Mantenimientos2026`
         - Title = `outputs('Componer_TituloMant')`
         - Especialidad Id = `items('Aplicar_a_cada_uno')?['ID']`  *(campo "Especialidad Id" del lookup)*
         - TipoMantenimiento Value = `Preventivo`
         - FechaProgramada = `outputs('Componer_FechaProg')`
         - Estado Value = `Programado`
      6. **Actualizar elemento** (SharePoint) — Lista `Mantenimientos2026`
         - Id = `body('Crear_elemento')?['ID']`
         - CarpetaDocumentos (URL) = enlace de la carpeta: `body('Crear_nueva_carpeta')?['{Link}']`
         - CarpetaDocumentos (Descripción) = `Abrir carpeta`

> Nota "Diario"/"Mensual": el catálogo trae los 12 meses, así que se generan 12 registros
> de control (uno por mes). No 365 — así el cronograma es legible.

---

## FLX-GuardarDocumento
**Tipo:** Instantáneo, **llamado desde Power Apps** (trigger *PowerApps V2*).
**Qué hace:** recibe un archivo desde la app, lo guarda renombrado en la carpeta del
mantenimiento, escribe metadatos y devuelve el enlace.

1. **Desencadenador:** *PowerApps (V2)* — entradas:
   - `ArchivoContenido` (tipo **Archivo**)
   - `NombreArchivo` (Texto)
   - `IDMantenimiento` (Número)
   - `TipoDocumento` (Texto)
   - `Comentario` (Texto)
2. **Ámbito: TRY** (mete dentro los pasos 3–9):
3. **Obtener elemento** (SharePoint) `Mantenimientos2026`, Id = `triggerBody()?['number']` (IDMantenimiento)
4. **Obtener elemento** (SharePoint) `Especialidades`, Id = `outputs('Obtener_elemento_Mant')?['body/Especialidad/Id']`
   *(para conocer la Fase)*
5. **Componer** `Ext` = `last(split(triggerBody()?['text_1'], '.'))`  *(extensión del NombreArchivo)*
6. **Componer** `RutaCarpetaRel` = `concat('2026/', outputs('Obtener_elemento_Esp')?['body/Fase/Value'], '/', outputs('Obtener_elemento_Esp')?['body/Title'], '/', outputs('Obtener_elemento_Mant')?['body/Title'])`
7. **Obtener archivos (solo propiedades)** (SharePoint) `DocumentosMantenimiento`
   - *Filtrar por carpeta:* la ruta anterior · *Filtro ODATA:* `TipoDocumento eq '<TipoDocumento>'`
   - Sirve para el correlativo → `formatNumber(add(length(body('Obtener_archivos')?['value']),1),'000')`
8. **Componer** `NombreFinal` =
   `concat(formatDateTime(outputs('Obtener_elemento_Mant')?['body/FechaProgramada'],'yyyy-MM-dd'), '_', outputs('Obtener_elemento_Esp')?['body/Title'], '_', triggerBody()?['text_2'], '_', outputs('Componer_Correlativo'), '.', outputs('Componer_Ext'))`
9. **Crear archivo** (SharePoint)
   - Sitio `<SITE_URL>` · Ruta de carpeta = `concat('DocumentosMantenimiento/', outputs('Componer_RutaCarpetaRel'))`
   - Nombre = `outputs('Componer_NombreFinal')` · Contenido = `triggerBody()?['file']` (ArchivoContenido)
10. **Actualizar propiedades de archivo** (SharePoint) `DocumentosMantenimiento`
    - Id = `body('Crear_archivo')?['ItemId']`
    - TipoDocumento Value = `triggerBody()?['text_2']`
    - EspecialidadDoc = `outputs('Obtener_elemento_Esp')?['body/Title']`
    - FechaMantenimiento = `outputs('Obtener_elemento_Mant')?['body/FechaProgramada']`
    - IDMantenimiento = `triggerBody()?['number']`
11. **Responder a Power Apps** — salida `EnlaceArchivo` (Texto) = `body('Crear_archivo')?['{Link}']`
12. **Ámbito: CATCH** (configurar *Ejecutar después* → "ha fallado" / "ha superado el tiempo de espera" del ámbito TRY):
    - **Enviar un correo (V2)** a `david.reboredo@outlook.com` con el error `result('TRY')`.
    - **Responder a Power Apps** con `EnlaceArchivo` = `ERROR`.

---

## FLX-Recordatorios
**Tipo:** Programado (Recurrencia **diaria 08:00**, zona horaria *(UTC-04:00/-03:00) Santiago*).
**Qué hace:** avisa mantenimientos próximos (7 días) y marca/avisa los atrasados.

1. **Recurrencia:** Frecuencia Día, Hora 08:00, Zona horaria Santiago.
2. **Componer** `Hoy` = `formatDateTime(convertFromUtc(utcNow(),'Pacific SA Standard Time'),'yyyy-MM-dd')`
3. **Componer** `En7` = `formatDateTime(addDays(convertFromUtc(utcNow(),'Pacific SA Standard Time'),7),'yyyy-MM-dd')`
4. **Obtener elementos** `Mantenimientos2026` — *Próximos*
   - ODATA: `Estado eq 'Programado' and FechaProgramada ge '@{outputs('Componer_Hoy')}' and FechaProgramada le '@{outputs('Componer_En7')}'`
5. **Obtener elementos** `Mantenimientos2026` — *Atrasados*
   - ODATA: `(Estado eq 'Programado' or Estado eq 'En Ejecución') and FechaProgramada lt '@{outputs('Componer_Hoy')}'`
6. **Aplicar a cada uno** (Atrasados) → **Actualizar elemento**: Estado Value = `Atrasado`.
7. **Crear tabla HTML** con los "Próximos" (columnas Title, Especialidad, FechaProgramada) y otra con "Atrasados".
8. **Enviar un correo (V2)** al responsable (`david.reboredo@outlook.com`) con ambas tablas.
   *(Opcional: acción "Publicar mensaje en un chat o canal" de Teams.)*

---

## FLX-CierreMantenimiento
**Tipo:** Automatizado — *Cuando se crea o modifica un elemento* en `Mantenimientos2026`.
**Qué hace:** al marcar Ejecutado, valida que exista respaldo documental.

1. **Desencadenador:** *Cuando se crea o modifica un elemento*, Lista `Mantenimientos2026`.
2. **Condición:** `Estado Value` **es igual a** `Ejecutado`. (Rama *En caso afirmativo*:)
3. **Componer** `RutaCarpetaRel` = como en FLX-GuardarDocumento (usando el item disparador y su Especialidad; añade un *Obtener elemento* de `Especialidades` para la Fase).
4. **Obtener archivos (solo propiedades)** filtrando la carpeta y
   `TipoDocumento eq 'Orden de Trabajo' or TipoDocumento eq 'Comprobante de Mantenimiento'`.
5. **Condición:** `length(body('Obtener_archivos')?['value'])` **es igual a** `0` →
   **Enviar un correo (V2)** al responsable pidiendo subir la orden de trabajo o comprobante.

> Para evitar correos repetidos, puedes añadir una columna `RespaldoValidado` (Sí/No) y
> filtrar el disparador con *Condición de desencadenador*: `@not(equals(triggerBody()?['RespaldoValidado'], true))`.
