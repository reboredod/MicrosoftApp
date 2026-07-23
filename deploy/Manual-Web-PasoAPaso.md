# Manual 100% web — App de Mantenimiento CChC Apoquindo 2026

Guía para construir **toda la solución desde el navegador**, sin PowerShell ni instalaciones.
Solo necesitas tu cuenta corporativa CChC y acceso al sitio
`https://cchccl.sharepoint.com/sites/Administracion`.

**Orden de trabajo (respétalo):**
1. Crear la estructura en SharePoint (Parte 1)
2. Cargar el catálogo de especialidades (Parte 2)
3. Crear los 4 flujos de Power Automate (Parte 3)
4. Construir la Power App (Parte 4)
5. Verificar (Parte 5)

Tiempo estimado: 2–4 horas la primera vez. Puedes hacerlo por partes.

> 💡 Los nombres de columnas de este manual coinciden exactamente con los flujos
> (`flows/README-flujos.md`) y la app (`app/App-BuildKit.md`). No los cambies.

---

# PARTE 1 — Crear la estructura en SharePoint

Vas a crear **2 listas** y **1 biblioteca** dentro del sitio Administración.

## 1.1 — Lista "Especialidades"

1. Entra a `https://cchccl.sharepoint.com/sites/Administracion`.
2. Clic en **+ Nuevo → Lista**.
3. Elige **Lista en blanco**.
4. Nombre: **`Especialidades`** → clic en **Crear**.
5. Ya dentro de la lista, agrega las columnas con **+ Agregar columna**. Para cada una,
   elige el tipo indicado, escribe el nombre **exacto** y guarda:

| Nombre de columna | Tipo | Configuración |
|---|---|---|
| `Fase` | Opción (Choice) | Opciones (una por línea): `1. Aseo, Higiene y Seguridad` · `2. Infraestructura, Cocina y Control Centralizado` · `3. Otros` |
| `Frecuencia` | Opción (Choice) | Opciones: `Diario` · `Mensual` · `Trimestral` · `Semestral` · `Anual` · `Inspección` |
| `MesesProgramados` | Texto de una sola línea | — |
| `Proveedor` | Texto de una sola línea | — |
| `ContactoProveedor` | Texto de una sola línea | — |
| `Activa` | Sí/No | Valor predeterminado: **Sí** |

> La columna **Título** (Title) ya viene por defecto: ahí irá el nombre de la especialidad.

## 1.2 — Lista "Mantenimientos2026"

1. **+ Nuevo → Lista → Lista en blanco**. Nombre: **`Mantenimientos2026`** → **Crear**.
2. Agrega estas columnas:

| Nombre de columna | Tipo | Configuración |
|---|---|---|
| `Especialidad` | Búsqueda (Lookup) | Obtener información de: **Especialidades**; columna a mostrar: **Título** |
| `TipoMantenimiento` | Opción | Opciones: `Preventivo` · `Correctivo`. Predeterminado: **Preventivo** |
| `FechaProgramada` | Fecha y hora | Formato: **Solo fecha** |
| `FechaEjecucion` | Fecha y hora | Formato: **Solo fecha** |
| `Estado` | Opción | Opciones: `Programado` · `En Ejecución` · `Ejecutado` · `Atrasado` · `Reprogramado` · `Cancelado`. Predeterminado: **Programado** |
| `Proveedor` | Texto de una sola línea | — |
| `ResponsableInterno` | Persona | — |
| `Observaciones` | Varias líneas de texto | — |
| `CarpetaDocumentos` | Hipervínculo | — |
| `CostoAsociado` | Moneda | Símbolo: CLP ($) |

3. **Indexar columnas** (importante para el rendimiento y evitar el límite de 5.000):
   - Clic en el engranaje ⚙️ (arriba a la derecha) → **Configuración de la lista**.
   - En la sección **Columnas**, baja hasta **Columnas indizadas** → **Crear un nuevo índice**.
   - Crea un índice para cada una: **Estado**, **FechaProgramada** y **Especialidad**.

## 1.3 — Biblioteca "DocumentosMantenimiento"

1. En el sitio: **+ Nuevo → Biblioteca de documentos**. Nombre: **`DocumentosMantenimiento`** → **Crear**.
2. Agrega estas columnas (con **+ Agregar columna**):

| Nombre de columna | Tipo | Configuración |
|---|---|---|
| `TipoDocumento` | Opción | Opciones: `Orden de Trabajo` · `Comprobante de Mantenimiento` · `Informe Técnico` · `Certificado` · `Cotización` · `Otro` |
| `EspecialidadDoc` | Texto de una sola línea | — |
| `FechaMantenimiento` | Fecha y hora | Formato: **Solo fecha** |
| `IDMantenimiento` | Número | 0 decimales |

3. Crea la carpeta raíz del año: dentro de la biblioteca, **+ Nuevo → Carpeta** → nombre **`2026`**.
   (Las subcarpetas por fase/especialidad las creará automáticamente el flujo del Paso 3.)

---

# PARTE 2 — Cargar el catálogo de especialidades

Vamos a llenar la lista **Especialidades** con las 19 filas (ya extraídas de tu planilla 2025).

**Método rápido (pegar en cuadrícula):**
1. Abre la lista **Especialidades**.
2. Clic en **Editar en vista de cuadrícula** (Edit in grid view).
3. Ingresa (o copia y pega) los datos de esta tabla. La columna **Activa** ponla en **Sí**:

| Título | Fase | Frecuencia | MesesProgramados |
|---|---|---|---|
| Aseo, Higiene y Seguridad (general) | 1. Aseo, Higiene y Seguridad | Diario | 01,02,03,04,05,06,07,08,09,10,11,12 |
| Lavado de Alfombra y Muebles | 1. Aseo, Higiene y Seguridad | Semestral | 02,08 |
| Control de Plagas | 1. Aseo, Higiene y Seguridad | Mensual | 01,02,03,04,05,06,07,08,09,10,11,12 |
| Mantención de Extintores | 1. Aseo, Higiene y Seguridad | Anual | 07 |
| Mantenimiento Eléctrico | 2. Infraestructura, Cocina y Control Centralizado | Semestral | 02,08 |
| Mantenimiento Clima | 2. Infraestructura, Cocina y Control Centralizado | Trimestral | 03,06,09,12 |
| Mantenimiento Sanitario | 2. Infraestructura, Cocina y Control Centralizado | Inspección | 02,05,08,11 |
| Mantenimiento Cortinas Roller | 2. Infraestructura, Cocina y Control Centralizado | Semestral | 02,08 |
| Mantenimiento Puertas y Mamparas | 2. Infraestructura, Cocina y Control Centralizado | Semestral | 01,07 |
| Mantenimiento Equipos de Cocina | 2. Infraestructura, Cocina y Control Centralizado | Semestral | 01,07 |
| Mantenimiento Ductos de Cocina | 2. Infraestructura, Cocina y Control Centralizado | Semestral | 05,11 |
| Mantenimiento Cocina Caliente | 2. Infraestructura, Cocina y Control Centralizado | Trimestral | 02,05,08 |
| Mantenimiento Salva Escalera | 2. Infraestructura, Cocina y Control Centralizado | Trimestral | 01,04,07,10 |
| Mantenimiento BMS | 2. Infraestructura, Cocina y Control Centralizado | Trimestral | 01,04,07,10 |
| Dispensadores de Agua | 3. Otros | Trimestral | 01,04,07,10 |
| Control de Acceso - Safecard | 3. Otros | Mensual | 01,02,03,04,05,06,07,08,09,10,11,12 |
| PCI - ANSUL | 3. Otros | Semestral | 04,10 |
| PCI - Detección (APLC) | 3. Otros | Anual | 12 |
| PCI - Extinción (APLC) | 3. Otros | Anual | 03,07,11 |

4. Clic en **Salir de la vista de cuadrícula** para guardar.
5. (Opcional) Completa `Proveedor` y `ContactoProveedor` de cada especialidad cuando los tengas.

> El campo **MesesProgramados** es la clave: indica en qué meses se hace cada mantención
> (MM separados por comas). El flujo del Paso 3 lo usa para generar todo el plan del año.
> **Valida estos meses con tus proveedores** antes de generar el plan.

---

# PARTE 3 — Crear los 4 flujos de Power Automate

Entra a **https://make.powerautomate.com** con tu cuenta CChC (arriba a la derecha,
verifica que el entorno sea el de CChC). Crea los flujos siguiendo, paso a paso y con las
**expresiones exactas**, el documento **`flows/README-flujos.md`** del repositorio:

1. **FLX-GenerarPlanAnual** (instantáneo) — créalo y **ejecútalo una vez**: genera todos
   los mantenimientos del 2026 y sus carpetas dentro de `/2026/…`. *Hazlo primero.*
2. **FLX-GuardarDocumento** (llamado desde la app) — permite subir documentos.
3. **FLX-Recordatorios** (programado, diario 08:00) — avisos y marcado de atrasados.
4. **FLX-CierreMantenimiento** (automatizado) — valida respaldo al marcar Ejecutado.
5. **FLX-AvisoProgramacion** ⭐ (programado, configurable) — aviso anticipado por correo
   para programar los mantenimientos **preventivos** antes de su fecha. Ajustas días de
   anticipación, frecuencia y destinatarios a tu gusto.

Cómo crear cada uno en la web:
- **+ Crear** → elige el tipo (Flujo instantáneo / programado / automatizado según el doc).
- Agrega las acciones que indica el README (todas del conector **SharePoint**, estándar).
- En cada acción de SharePoint, "Dirección del sitio" =
  `https://cchccl.sharepoint.com/sites/Administracion`.
- Pega las expresiones tal cual aparecen (botón **fx** para las expresiones).

> Después de crear **FLX-GenerarPlanAnual** y ejecutarlo, revisa la lista
> **Mantenimientos2026**: debe llenarse con ~150–250 registros en estado *Programado*, y
> la biblioteca debe mostrar las subcarpetas por fase y especialidad.

---

# PARTE 4 — Construir la Power App

Entra a **https://make.powerapps.com** con tu cuenta CChC.

**Atajo para empezar:** en la lista **Mantenimientos2026** (en SharePoint), menú
**Integrar → Power Apps → Crear una aplicación**. Power Apps genera una app base de 3
pantallas conectada a la lista. Sobre esa base, aplica el diseño completo (5 pantallas,
cronograma tipo Gantt, colores por estado, subida de documentos y correctivos) siguiendo
**`app/App-BuildKit.md`**, que trae **todas las fórmulas Power Fx listas para copiar**:

- `App.OnStart` — variables de color y datos.
- **scrCronograma** — la carta Gantt (réplica de tu planilla).
- **scrLista** — lista filtrable.
- **scrDetalle** — detalle + documentos + botones de acción.
- **scrSubirDoc** — subir documento (usa FLX-GuardarDocumento).
- **scrNuevoCorrectivo** — registrar mantenciones no planificadas.

Pasos web clave:
1. **Datos → + Agregar datos:** conecta `Especialidades`, `Mantenimientos2026` y
   `DocumentosMantenimiento`.
2. **+ Nueva pantalla** para cada una de las 5; renómbralas como arriba.
3. Pega las fórmulas de cada control desde el build kit.
4. Para la subida de documentos: **Power Automate (panel izquierdo) → + Agregar flujo →
   FLX-GuardarDocumento**, y usa la fórmula del botón `btnGuardar`.
5. **Guardar** (arriba a la derecha) y **Publicar**.
6. **Compartir** la app con quienes harán seguimiento (menú **Compartir**).

---

# PARTE 5 — Verificación final

- [ ] En SharePoint aparecen **Especialidades** (19 filas), **Mantenimientos2026** y
      **DocumentosMantenimiento** (con carpeta `2026`).
- [ ] Las columnas **Estado**, **FechaProgramada** y **Especialidad** están indexadas.
- [ ] **FLX-GenerarPlanAnual** se ejecutó sin errores y llenó Mantenimientos2026.
- [ ] La biblioteca muestra subcarpetas `/2026/[Fase]/[Especialidad]/…`.
- [ ] La app abre, el **cronograma** muestra colores por estado y el detalle lista documentos.
- [ ] Subir un documento de prueba desde la app lo deja en la carpeta correcta de SharePoint
      con el nombre `AAAA-MM-DD_Especialidad_TipoDocumento_correlativo`.
- [ ] Abrir esa carpeta directo en SharePoint (sin la app) funciona.

---

## Consejos y problemas frecuentes

- **Acceso desde PC personal:** si al entrar a SharePoint/Power Apps te pide "dispositivo
  compatible" o bloquea el acceso, es una política de CChC; úsalo desde un equipo corporativo
  o pide a TI que habilite tu acceso.
- **No cambies los nombres internos** de listas ni columnas: los flujos y la app los usan
  literalmente. Si ya creaste una con otro nombre, renómbrala o avísame para ajustar.
- **Umbral de 5.000 elementos:** con el plan anual (~250 registros) estás muy lejos; las
  columnas indexadas te dan margen para años futuros.
- **Un año nuevo (2027):** duplicarás la lógica cambiando el año en el flujo
  FLX-GenerarPlanAnual y creando la carpeta raíz `2027`.
- Si algo no calza con lo que ves en pantalla, cuéntame el paso exacto y lo resolvemos.
