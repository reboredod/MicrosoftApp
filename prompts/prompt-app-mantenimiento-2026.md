# Prompt maestro — App de Mantenimiento CChC Apoquindo 2026

**Uso:** copia el prompt del bloque siguiente en el agente de IA que vayas a usar
(Copilot de Power Apps al crear la app, Copilot Studio, o un agente tipo Claude/ChatGPT
que te guíe paso a paso). Al final del documento hay una versión dividida en 3 fases
por si el agente funciona mejor con instrucciones incrementales.

---

## Prompt maestro (copiar completo)

```text
Actúa como arquitecto experto en Microsoft Power Platform (Power Apps, Power Automate,
SharePoint y Microsoft Lists). Necesito construir una solución completa de gestión de
mantenimiento para el edificio CChC Apoquindo (Cámara Chilena de la Construcción),
año 2026, que reemplace una planilla Excel tipo carta Gantt. Responsable: Operaciones
CChC - David Reboredo. Todo debe almacenarse en un sitio de SharePoint al que tengo
acceso; yo te indicaré la URL del sitio cuando la necesites.

════════════════════════════════════════
1. MODELO DE DATOS (SharePoint / Microsoft Lists)
════════════════════════════════════════

Crea en mi sitio de SharePoint:

A) Lista "Especialidades" (catálogo maestro), columnas:
   - Título (nombre de la especialidad)
   - Fase (elección): "1. Aseo, Higiene y Seguridad" / "2. Infraestructura, Cocina y
     Control Centralizado" / "3. Otros"
   - Frecuencia (elección): Diario / Mensual / Trimestral / Semestral / Anual / Inspección
   - MesesProgramados (texto, ej: "02,08" para semestral en feb y ago)
   - Proveedor (texto), ContactoProveedor (texto), Activa (sí/no)

   Carga estos registros iniciales (fase | especialidad | frecuencia | meses):
   1 | Aseo, Higiene y Seguridad (general)      | Diario     | todos
   1 | Lavado de Alfombra y Muebles             | Semestral  | 02,08
   1 | Control de Plagas                        | Mensual    | todos
   1 | Mantención de Extintores                 | Anual      | 07
   2 | Mantenimiento Eléctrico                  | Semestral  | 02,08
   2 | Mantenimiento Clima                      | Trimestral | 03,06,09,12
   2 | Mantenimiento Sanitario                  | Inspección | 02,05,08,11
   2 | Mantenimiento Cortinas Roller            | Semestral  | 02,08
   2 | Mantenimiento Puertas y Mamparas         | Semestral  | 01,07
   2 | Mantenimiento Equipos de Cocina          | Semestral  | 01,07
   2 | Mantenimiento Ductos de Cocina           | Semestral  | 05,11
   2 | Mantenimiento Cocina Caliente            | Trimestral | 02,05,08
   2 | Mantenimiento Salva Escalera             | Trimestral | 01,04,07,10
   2 | Mantenimiento BMS                        | Trimestral | 01,04,07,10
   3 | Dispensadores de Agua                    | Trimestral | 01,04,07,10
   3 | Control de Acceso - Safecard             | Mensual    | todos
   3 | PCI - ANSUL                              | Semestral  | 04,10
   3 | PCI - Detección (APLC)                   | Anual      | 12
   3 | PCI - Extinción (APLC)                   | Anual + inspecciones | 03 (anual), 07,11 (inspección)

B) Lista "Mantenimientos2026" (plan y seguimiento), columnas:
   - Título (autogenerado: "[Especialidad] - [AAAA-MM]")
   - Especialidad (búsqueda a lista Especialidades)
   - TipoMantenimiento (elección): Preventivo / Correctivo
   - FechaProgramada (fecha), FechaEjecucion (fecha)
   - Estado (elección): Programado / En Ejecución / Ejecutado / Atrasado /
     Reprogramado / Cancelado  (valor por defecto: Programado)
   - Proveedor (texto), ResponsableInterno (persona)
   - Observaciones (varias líneas)
   - CarpetaDocumentos (hipervínculo a la carpeta de documentos del mantenimiento)
   - CostoAsociado (moneda, opcional)
   Indexa las columnas Especialidad, Estado y FechaProgramada.

C) Biblioteca de documentos "DocumentosMantenimiento" con esta estructura de carpetas,
   creada AUTOMÁTICAMENTE por el flujo (no a mano):
     /2026/[Fase]/[Especialidad]/[AAAA-MM - Título del mantenimiento]/
   Columnas de metadatos de la biblioteca:
   - TipoDocumento (elección): Orden de Trabajo / Comprobante de Mantenimiento /
     Informe Técnico / Certificado / Cotización / Otro
   - EspecialidadDoc (texto o búsqueda), FechaMantenimiento (fecha),
     IDMantenimiento (número: ID del elemento en Mantenimientos2026)
   Convención de nombres de archivo:
     AAAA-MM-DD_[Especialidad]_[TipoDocumento]_[correlativo].ext
   (así los documentos son ubicables navegando SharePoint directamente, sin abrir la app)

════════════════════════════════════════
2. POWER APP (canvas, formato tableta)
════════════════════════════════════════

Crea una app canvas llamada "Mantenimiento CChC" conectada a las listas y
biblioteca anteriores, con estas pantallas:

P1. INICIO / CRONOGRAMA: réplica visual de la carta Gantt de la planilla original:
    filas = especialidades agrupadas por fase; columnas = meses ENE–DIC de 2026;
    cada celda muestra el estado del mantenimiento de ese mes con colores:
    gris = programado, amarillo = en ejecución, verde = ejecutado, rojo = atrasado,
    azul = reprogramado. Incluir en la cabecera: título del proyecto, responsable,
    año y KPIs (total ejecutados, % avance, atrasados). Al tocar una celda se navega
    al detalle de ese mantenimiento.

P2. LISTA DE MANTENIMIENTOS: galería filtrable por fase, especialidad, tipo
    (preventivo/correctivo), estado y mes. Buscador de texto. Ordenada por
    FechaProgramada. Usar solo funciones delegables sobre SharePoint.

P3. DETALLE DE MANTENIMIENTO: todos los campos del registro + galería con los
    documentos de su carpeta en DocumentosMantenimiento (nombre, tipo, fecha, enlace
    para abrir en SharePoint) + botones: "Marcar en ejecución", "Marcar ejecutado"
    (pide fecha de ejecución y observaciones), "Reprogramar" (pide nueva fecha),
    "Subir documento" y "Abrir carpeta en SharePoint" (Launch al hipervínculo
    CarpetaDocumentos).

P4. SUBIR DOCUMENTO: formulario con control de datos adjuntos o control de archivo,
    selección de TipoDocumento y comentario; al enviar llama al flujo
    "FLX-GuardarDocumento" (sección 3.B) pasándole el archivo en base64, el ID del
    mantenimiento y el tipo de documento. Mostrar confirmación con el enlace al
    archivo guardado.

P5. NUEVO MANTENIMIENTO CORRECTIVO: formulario para registrar mantenimientos no
    planificados (falla/emergencia): especialidad, descripción, fecha, proveedor;
    crea el registro con TipoMantenimiento = Correctivo y dispara la creación de su
    carpeta de documentos.

Buenas prácticas exigidas: nomenclatura de controles con prefijos (scr, gal, btn,
lbl, txt), variables con prefijo var/loc, colecciones con col, tema de colores
corporativo sobrio (azul/gris), y sin funciones no delegables sobre listas grandes.

════════════════════════════════════════
3. FLUJOS DE POWER AUTOMATE
════════════════════════════════════════

A) "FLX-GenerarPlanAnual" (instantáneo, se ejecuta una vez por año):
   recorre la lista Especialidades (Activa = sí) y crea en Mantenimientos2026 un
   registro por cada ocurrencia según Frecuencia y MesesProgramados (para "Diario"
   crear UN registro mensual de control, no 365). Estado inicial: Programado.
   Para cada registro creado: crear su carpeta en DocumentosMantenimiento con la ruta
   /2026/[Fase]/[Especialidad]/[AAAA-MM - Título]/ y guardar el enlace en la columna
   CarpetaDocumentos.

B) "FLX-GuardarDocumento" (instantáneo, llamado desde Power Apps):
   entradas: archivo (contenido + nombre), IDMantenimiento, TipoDocumento, comentario.
   Pasos: obtener el registro del mantenimiento → verificar/crear la carpeta →
   guardar el archivo renombrado según la convención
   AAAA-MM-DD_[Especialidad]_[TipoDocumento]_[correlativo].ext → escribir los
   metadatos (TipoDocumento, EspecialidadDoc, FechaMantenimiento, IDMantenimiento) →
   devolver a la app el enlace del archivo. Incluir scope Try/Catch con notificación
   de error a david.reboredo@outlook.com.

C) "FLX-Recordatorios" (programado, diario 08:00 hora de Chile):
   1) Mantenimientos con FechaProgramada en los próximos 7 días y Estado = Programado:
      correo resumen al responsable (y opcionalmente mensaje en Teams).
   2) Mantenimientos con FechaProgramada vencida y Estado = Programado o En Ejecución:
      cambiar Estado a Atrasado y avisar en el mismo correo (sección "Atrasados").

D) "FLX-CierreMantenimiento" (automatizado, al modificar Mantenimientos2026):
   cuando Estado cambia a Ejecutado, verificar que la carpeta tenga al menos un
   documento de tipo "Orden de Trabajo" o "Comprobante de Mantenimiento"; si no hay,
   enviar correo al responsable pidiendo respaldo documental.

════════════════════════════════════════
4. FORMA DE TRABAJO
════════════════════════════════════════
Guíame paso a paso en orden: primero el modelo de datos (sección 1), después los
flujos A y B (sección 3), luego la app (sección 2) y al final los flujos C y D.
En cada paso dame instrucciones exactas de clics/configuración y las fórmulas
Power Fx o expresiones de Power Automate listas para copiar y pegar. Antes de
empezar, pregúntame la URL de mi sitio de SharePoint y valida conmigo los meses
programados de cada especialidad.
```

---

## Versión por fases (si el agente se satura con el prompt completo)

- **Fase 1 — Datos:** pega solo la sección 1 + el párrafo inicial de contexto.
- **Fase 2 — Flujos de generación y documentos:** pega la sección 3 (A y B), recordando al agente que las listas ya existen.
- **Fase 3 — App:** pega la sección 2, indicando los nombres reales de listas/biblioteca ya creadas.
- **Fase 4 — Automatizaciones de seguimiento:** pega la sección 3 (C y D).

## Notas de diseño (por qué está armado así)

- **Lists en vez de solo Excel**: permite estados, vistas filtradas, indexación y conexión delegable desde Power Apps.
- **Carpetas por mantenimiento** (`/2026/Fase/Especialidad/AAAA-MM - Título/`) + **convención de nombres de archivo**: garantiza el requisito de encontrar documentos navegando SharePoint sin abrir la app.
- **"Diario" se controla con un registro mensual**: evita inflar la lista con 365 ítems por especialidad y mantiene el cronograma legible.
- **Meses programados**: se dedujeron de la planilla 2025 (ej. semestrales en feb/ago); validar con proveedores antes de generar el plan 2026.
- **Correctivos separados de preventivos**: mismo modelo de datos, distinto origen (P5), lo que permite comparar plan vs. fallas reales a fin de año.
