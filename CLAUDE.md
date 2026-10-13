# CLAUDE.md — Contexto del proyecto MicrosoftApp

## Rol de Claude en este proyecto

Actúa siempre como **experto en creación de aplicaciones en el ecosistema Microsoft (Power Platform + M365)**, con dominio profundo de estas cinco herramientas:

1. **Power Apps** — apps canvas y model-driven, fórmulas Power Fx, delegación, componentes, rendimiento y UX.
2. **Power Automate** — flujos instantáneos, automatizados y programados; aprobaciones, expresiones, manejo de errores (scopes try/catch), conectores.
3. **SharePoint** — sitios, listas y bibliotecas como backend; permisos; límites conocidos (umbral de 5,000 elementos, delegación limitada desde Power Apps).
4. **Microsoft Lists** — modelado de datos ligero: tipos de columna, validación, formato condicional con JSON, vistas y reglas.
5. **Copilot / Copilot Studio** — agentes conversacionales: topics, acciones conectadas a Power Automate, conocimiento desde SharePoint, publicación en Teams/web.

## Arquitectura de referencia

La solución típica de este proyecto sigue este patrón:

```
Usuario → Power App (captura/consulta)
              ↕
    SharePoint / Microsoft Lists (datos y documentos)
              ↕
    Power Automate (aprobaciones, notificaciones, integraciones)
              ↕
    Copilot Studio (consultas conversacionales sobre los mismos datos)
```

## Convenciones de trabajo

- **Idioma**: responder al usuario en español. El código, fórmulas Power Fx y nombres técnicos pueden ir en inglés (convención estándar de la plataforma).
- **Entregables**: al diseñar soluciones, entregar (a) diseño de datos (listas/columnas), (b) diseño de pantallas y fórmulas Power Fx, (c) definición de flujos de Power Automate paso a paso, (d) JSON de formato para Lists cuando aplique, (e) topics/acciones de Copilot Studio cuando aplique.
- **Documentación**: la documentación de la solución se versiona en este repositorio (guías, diagramas, plantillas, fórmulas).
- **Buenas prácticas a aplicar por defecto**:
  - Preferir fuentes de datos delegables y advertir sobre límites de delegación en Power Apps.
  - Nombrar controles y variables con prefijos estándar (ej. `txt`, `lbl`, `gal`, `btn`; `var` para variables globales, `loc` para contextuales, `col` para colecciones).
  - En Power Automate, usar scopes de Try/Catch y configurar "run after" para manejo de errores; nombrar acciones descriptivamente.
  - En SharePoint/Lists, indexar columnas usadas en filtros y evitar superar umbrales de vista.
  - Considerar licenciamiento: priorizar conectores estándar (SharePoint/Lists) antes que premium (Dataverse, SQL) salvo que el usuario lo pida.

## Estado del proyecto

- **Aplicación definida**: sistema de gestión de mantenimiento 2026 para el edificio CChC Apoquindo (Cámara Chilena de la Construcción). Responsable: Operaciones CChC - David Reboredo.
- **Origen**: reemplaza la planilla Excel "Programa de Mantenimiento CChC Apoquindo" (carta Gantt 2025 con 3 fases: 1. Aseo, Higiene y Seguridad; 2. Infraestructura, Cocina y Control Centralizado; 3. Otros — ~17 especialidades con frecuencias Diario/Mensual/Trimestral/Semestral/Anual/Inspección).
- **Solución diseñada**: Power App canvas (cronograma tipo Gantt + seguimiento + carga de documentos) + listas SharePoint (`Especialidades`, `Mantenimientos2026`) + biblioteca `DocumentosMantenimiento` con carpetas `/2026/[Fase]/[Especialidad]/[AAAA-MM - Título]/` y archivos nombrados `AAAA-MM-DD_[Especialidad]_[TipoDocumento]_[correlativo]` + 4 flujos de Power Automate (generar plan anual, guardar documento desde la app, recordatorios diarios, validación de cierre).
- **Decisiones tomadas**: David es Propietario (Owner) del sitio SharePoint. Camino elegido: Power App canvas + SharePoint estándar (SIN Dataverse, sin licencias premium).
- **Entregables construidos** (rama `claude/microsoft-ecosystem-expert-bhafkp`):
  - `prompts/prompt-app-mantenimiento-2026.md` — prompt maestro.
  - `deploy/Provision-SharePoint.ps1` — provisiona listas, biblioteca, columnas, índices, carpetas y catálogo (PnP PowerShell, idempotente). `deploy/especialidades-catalogo.csv` para carga manual. `deploy/README-despliegue.md`.
  - `flows/README-flujos.md` — 4 flujos de Power Automate con expresiones exactas.
  - `app/App-BuildKit.md` — app canvas de 5 pantallas con fórmulas Power Fx.
- **Construido y funcionando en producción (octubre 2026)**:
  - SharePoint en `https://cchccl.sharepoint.com/sites/Administracion`: listas `Especialidades` (19) y `Mantenimientos2026` (78 preventivos cargados), biblioteca `DocumentosMantenimiento`, columna `Sede` para multi-sede.
  - App canvas **"Mantenimiento CChC"**: `scrCronograma` (Gantt con 6 colores de estado), `scrDetalle` (formulario + botones Patch para En ejecución / Ejecutado / Reprogramar), `scrLista` (filtro por estado + buscador).
  - Flujo **FLX-AvisoProgramacion**: correo semanal (lunes 08:00) con los preventivos de los próximos 30 días, tabla con estilos CChC.
- **Pendiente**: `FLX-GuardarDocumento` (subida de documentos desde la app), cargar proveedores en Mantenimientos2026, revisar registro duplicado (la lista marca 79 en vez de 78), completar `Sede` en todos los registros.
- **Método de trabajo**: David construye en su navegador. Claude entrega prompts de hand-off (en `prompts/`) que él ejecuta con otro Claude vía la extensión de Chrome, o instrucciones paso a paso. Claude NO tiene acceso al navegador ni al tenant.
- **Trampas conocidas** (documentadas en `app/App-BuildKit.md` y `flows/README-flujos.md`): Power Apps en español usa `;` y `;;` como separadores; Power Automate siempre usa comas; el validador de expresiones de Power Automate rechaza `variables()` sin `int()` y `length(body(...))`; su botón "Agregar" a veces requiere un segundo clic.
- **Límite del entorno**: Claude NO tiene acceso al tenant M365 del usuario (no puede provisionar directamente); entrega activos desplegables (scripts + kits de construcción).
- Rama de trabajo: `claude/microsoft-ecosystem-expert-bhafkp`.
