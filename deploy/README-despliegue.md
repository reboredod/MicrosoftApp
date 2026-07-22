# Despliegue — Mantenimiento CChC Apoquindo 2026

Este directorio contiene los activos para levantar la solución en tu Microsoft 365.
Orden recomendado: **1) SharePoint → 2) Flujos → 3) Power App**.

## Paso 1 — Provisionar SharePoint (automatizado)

Crea las dos listas, la biblioteca, todas las columnas, índices, la estructura de
carpetas `/2026/[Fase]/[Especialidad]/` y carga el catálogo de 19 especialidades.

### Requisitos
- **PowerShell 7** (`pwsh`). No usar Windows PowerShell 5.1 (rompe acentos).
- Módulo PnP:
  ```powershell
  Install-Module PnP.PowerShell -Scope CurrentUser
  ```
- Ser **Propietario (Owner)** del sitio de SharePoint destino.

### Ejecución
El sitio destino ya viene configurado por defecto (`https://cchccl.sharepoint.com/sites/Administracion`):
```powershell
./Provision-SharePoint.ps1
```
El script es **idempotente**: si lo corres dos veces no duplica listas ni registros.

### Si tu organización bloquea el login interactivo de PnP
Registra una app de Entra ID una sola vez y conéctate con su ClientId:
```powershell
Register-PnPEntraIDApp -ApplicationName "PnP-Mantenimiento" -Tenant "cchccl.onmicrosoft.com" -Interactive
```
Alternativa sin instalar nada local: ejecutar el script desde **Azure Cloud Shell**.

## Paso 1 (alternativa manual)
Si prefieres no usar PowerShell, crea las columnas a mano según la especificación del
script y usa `especialidades-catalogo.csv` con **"Agregar desde Excel"** en Microsoft
Lists para cargar el catálogo. (En "Sí/No", la columna `Activa` acepta `Si`.)

## Nomenclatura y organización de archivos en SharePoint
- Carpetas: `/2026/[Fase]/[Especialidad]/[AAAA-MM - Título del mantenimiento]/`
- Archivos: `AAAA-MM-DD_[Especialidad]_[TipoDocumento]_[correlativo].ext`

Así cualquier comprobante, orden de trabajo o informe se encuentra navegando SharePoint
directamente, sin abrir la app.

## Paso 2 — Flujos de Power Automate
Ver `../flows/README-flujos.md`: FLX-GenerarPlanAnual, FLX-GuardarDocumento,
FLX-Recordatorios y FLX-CierreMantenimiento (conector SharePoint estándar).

## Paso 3 — Power App
Ver `../app/App-BuildKit.md`: app canvas de 5 pantallas (cronograma tipo Gantt,
lista filtrable, detalle con documentos, subida de archivos y correctivos) con todas
las fórmulas Power Fx listas para copiar.
