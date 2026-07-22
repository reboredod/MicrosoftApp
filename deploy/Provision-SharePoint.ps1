<#
.SYNOPSIS
    Provisiona el modelo de datos SharePoint para la app de Mantenimiento CChC Apoquindo 2026.

.DESCRIPTION
    Crea de forma automatizada:
      - Lista "Especialidades" (catálogo maestro) + columnas + catálogo inicial (19 especialidades
        extraídas de la planilla 2025).
      - Lista "Mantenimientos2026" (plan y seguimiento) + columnas + índices.
      - Biblioteca "DocumentosMantenimiento" + columnas de metadatos.
      - Estructura de carpetas /2026/[Fase]/[Especialidad]/ dentro de la biblioteca.

.PREREQUISITOS
    - PowerShell 7 (pwsh).  Windows PowerShell 5.1 puede corromper los acentos.
    - Módulo PnP.PowerShell:   Install-Module PnP.PowerShell -Scope CurrentUser
    - Ser Propietario (Owner) del sitio de SharePoint destino.
    - Si tu organización bloquea el inicio de sesión interactivo de PnP, registra una app:
        Register-PnPEntraIDApp -ApplicationName "PnP-Mantenimiento" -Tenant cchccl.onmicrosoft.com -Interactive
      y luego conéctate con -ClientId. Alternativa sencilla: ejecutar todo desde Azure Cloud Shell.

.EJEMPLO
    ./Provision-SharePoint.ps1
    ./Provision-SharePoint.ps1 -SiteUrl "https://cchccl.sharepoint.com/sites/Administracion"
#>

param(
    # Sitio destino CChC (Administración). Se puede sobreescribir al llamar el script.
    [string]$SiteUrl = "https://cchccl.sharepoint.com/sites/Administracion"
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------
# Conexión
# ---------------------------------------------------------
Connect-PnPOnline -Url $SiteUrl -Interactive
Write-Host "== Conectado a $SiteUrl ==" -ForegroundColor Cyan

# Funciones auxiliares -------------------------------------
function Ensure-List {
    param([string]$Title, [string]$Template)
    $l = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if (-not $l) {
        New-PnPList -Title $Title -Template $Template -OnQuickLaunch | Out-Null
        Write-Host "  + Lista/biblioteca '$Title' creada." -ForegroundColor Green
    } else {
        Write-Host "  = '$Title' ya existe (se conserva)." -ForegroundColor DarkGray
    }
}

function Ensure-Field {
    param([string]$List, [hashtable]$Params)
    $exists = Get-PnPField -List $List -Identity $Params.InternalName -ErrorAction SilentlyContinue
    if (-not $exists) {
        Add-PnPField -List $List @Params | Out-Null
        Write-Host "    + columna '$($Params.InternalName)' en '$List'." -ForegroundColor Green
    }
}

# =========================================================
# 1) LISTA: Especialidades (catálogo maestro)
# =========================================================
Write-Host "`n[1/4] Lista Especialidades..." -ForegroundColor Yellow
Ensure-List -Title "Especialidades" -Template GenericList

Ensure-Field "Especialidades" @{ DisplayName="Fase"; InternalName="Fase"; Type="Choice"; AddToDefaultView=$true;
    Choices=@("1. Aseo, Higiene y Seguridad","2. Infraestructura, Cocina y Control Centralizado","3. Otros") }
Ensure-Field "Especialidades" @{ DisplayName="Frecuencia"; InternalName="Frecuencia"; Type="Choice"; AddToDefaultView=$true;
    Choices=@("Diario","Mensual","Trimestral","Semestral","Anual","Inspección") }
Ensure-Field "Especialidades" @{ DisplayName="MesesProgramados"; InternalName="MesesProgramados"; Type="Text"; AddToDefaultView=$true }
Ensure-Field "Especialidades" @{ DisplayName="Proveedor"; InternalName="Proveedor"; Type="Text"; AddToDefaultView=$true }
Ensure-Field "Especialidades" @{ DisplayName="ContactoProveedor"; InternalName="ContactoProveedor"; Type="Text" }
Ensure-Field "Especialidades" @{ DisplayName="Activa"; InternalName="Activa"; Type="Boolean"; AddToDefaultView=$true }
Set-PnPField -List "Especialidades" -Identity "Activa" -Values @{ DefaultValue = "1" } -ErrorAction SilentlyContinue

# Catálogo inicial. MesesProgramados (MM separado por comas) es la fuente de verdad para
# generar el plan anual; Frecuencia es la etiqueta legible.
$catalogo = @(
    @{ Title="Aseo, Higiene y Seguridad (general)"; Fase="1. Aseo, Higiene y Seguridad"; Frecuencia="Diario";     Meses="01,02,03,04,05,06,07,08,09,10,11,12" },
    @{ Title="Lavado de Alfombra y Muebles";        Fase="1. Aseo, Higiene y Seguridad"; Frecuencia="Semestral";  Meses="02,08" },
    @{ Title="Control de Plagas";                   Fase="1. Aseo, Higiene y Seguridad"; Frecuencia="Mensual";    Meses="01,02,03,04,05,06,07,08,09,10,11,12" },
    @{ Title="Mantención de Extintores";            Fase="1. Aseo, Higiene y Seguridad"; Frecuencia="Anual";      Meses="07" },
    @{ Title="Mantenimiento Eléctrico";             Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Semestral";  Meses="02,08" },
    @{ Title="Mantenimiento Clima";                 Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Trimestral"; Meses="03,06,09,12" },
    @{ Title="Mantenimiento Sanitario";             Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Inspección"; Meses="02,05,08,11" },
    @{ Title="Mantenimiento Cortinas Roller";       Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Semestral";  Meses="02,08" },
    @{ Title="Mantenimiento Puertas y Mamparas";    Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Semestral";  Meses="01,07" },
    @{ Title="Mantenimiento Equipos de Cocina";     Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Semestral";  Meses="01,07" },
    @{ Title="Mantenimiento Ductos de Cocina";      Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Semestral";  Meses="05,11" },
    @{ Title="Mantenimiento Cocina Caliente";       Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Trimestral"; Meses="02,05,08" },
    @{ Title="Mantenimiento Salva Escalera";        Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Trimestral"; Meses="01,04,07,10" },
    @{ Title="Mantenimiento BMS";                   Fase="2. Infraestructura, Cocina y Control Centralizado"; Frecuencia="Trimestral"; Meses="01,04,07,10" },
    @{ Title="Dispensadores de Agua";               Fase="3. Otros"; Frecuencia="Trimestral"; Meses="01,04,07,10" },
    @{ Title="Control de Acceso - Safecard";        Fase="3. Otros"; Frecuencia="Mensual";    Meses="01,02,03,04,05,06,07,08,09,10,11,12" },
    @{ Title="PCI - ANSUL";                         Fase="3. Otros"; Frecuencia="Semestral";  Meses="04,10" },
    @{ Title="PCI - Detección (APLC)";              Fase="3. Otros"; Frecuencia="Anual";      Meses="12" },
    @{ Title="PCI - Extinción (APLC)";              Fase="3. Otros"; Frecuencia="Anual";      Meses="03,07,11" }
)

Write-Host "  Cargando catálogo (idempotente)..." -ForegroundColor Yellow
foreach ($e in $catalogo) {
    $q = "<View><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>$($e.Title)</Value></Eq></Where></Query></View>"
    $found = Get-PnPListItem -List "Especialidades" -Query $q -ErrorAction SilentlyContinue
    if (-not $found) {
        Add-PnPListItem -List "Especialidades" -Values @{
            Title            = $e.Title
            Fase             = $e.Fase
            Frecuencia       = $e.Frecuencia
            MesesProgramados = $e.Meses
            Activa           = $true
        } | Out-Null
        Write-Host "    + $($e.Title)" -ForegroundColor Green
    }
}

# =========================================================
# 2) LISTA: Mantenimientos2026 (plan y seguimiento)
# =========================================================
Write-Host "`n[2/4] Lista Mantenimientos2026..." -ForegroundColor Yellow
Ensure-List -Title "Mantenimientos2026" -Template GenericList

# Columna de búsqueda (lookup) hacia Especialidades
$espList = Get-PnPList -Identity "Especialidades"
if (-not (Get-PnPField -List "Mantenimientos2026" -Identity "Especialidad" -ErrorAction SilentlyContinue)) {
    $lookupXml = "<Field Type='Lookup' DisplayName='Especialidad' Name='Especialidad' StaticName='Especialidad' List='{$($espList.Id)}' ShowField='Title' />"
    Add-PnPFieldFromXml -List "Mantenimientos2026" -FieldXml $lookupXml | Out-Null
    Write-Host "    + columna lookup 'Especialidad'." -ForegroundColor Green
}

Ensure-Field "Mantenimientos2026" @{ DisplayName="TipoMantenimiento"; InternalName="TipoMantenimiento"; Type="Choice"; AddToDefaultView=$true;
    Choices=@("Preventivo","Correctivo") }
Set-PnPField -List "Mantenimientos2026" -Identity "TipoMantenimiento" -Values @{ DefaultValue = "Preventivo" } -ErrorAction SilentlyContinue

# Fechas (solo fecha) vía XML
foreach ($f in @("FechaProgramada","FechaEjecucion")) {
    if (-not (Get-PnPField -List "Mantenimientos2026" -Identity $f -ErrorAction SilentlyContinue)) {
        Add-PnPFieldFromXml -List "Mantenimientos2026" -FieldXml "<Field Type='DateTime' DisplayName='$f' Name='$f' StaticName='$f' Format='DateOnly' />" | Out-Null
        Write-Host "    + columna fecha '$f'." -ForegroundColor Green
    }
}

Ensure-Field "Mantenimientos2026" @{ DisplayName="Estado"; InternalName="Estado"; Type="Choice"; AddToDefaultView=$true;
    Choices=@("Programado","En Ejecución","Ejecutado","Atrasado","Reprogramado","Cancelado") }
Set-PnPField -List "Mantenimientos2026" -Identity "Estado" -Values @{ DefaultValue = "Programado" } -ErrorAction SilentlyContinue

Ensure-Field "Mantenimientos2026" @{ DisplayName="Proveedor"; InternalName="Proveedor"; Type="Text" }
Ensure-Field "Mantenimientos2026" @{ DisplayName="ResponsableInterno"; InternalName="ResponsableInterno"; Type="User" }
Ensure-Field "Mantenimientos2026" @{ DisplayName="Observaciones"; InternalName="Observaciones"; Type="Note" }
Ensure-Field "Mantenimientos2026" @{ DisplayName="CarpetaDocumentos"; InternalName="CarpetaDocumentos"; Type="URL" }
Ensure-Field "Mantenimientos2026" @{ DisplayName="CostoAsociado"; InternalName="CostoAsociado"; Type="Currency" }

# Índices (mejoran filtros/delegación y evitan el umbral de 5.000)
foreach ($idx in @("Estado","FechaProgramada","Especialidad")) {
    Set-PnPField -List "Mantenimientos2026" -Identity $idx -Values @{ Indexed = $true } -ErrorAction SilentlyContinue
}
Write-Host "    + índices en Estado, FechaProgramada y Especialidad." -ForegroundColor Green

# =========================================================
# 3) BIBLIOTECA: DocumentosMantenimiento
# =========================================================
Write-Host "`n[3/4] Biblioteca DocumentosMantenimiento..." -ForegroundColor Yellow
Ensure-List -Title "DocumentosMantenimiento" -Template DocumentLibrary

Ensure-Field "DocumentosMantenimiento" @{ DisplayName="TipoDocumento"; InternalName="TipoDocumento"; Type="Choice"; AddToDefaultView=$true;
    Choices=@("Orden de Trabajo","Comprobante de Mantenimiento","Informe Técnico","Certificado","Cotización","Otro") }
Ensure-Field "DocumentosMantenimiento" @{ DisplayName="EspecialidadDoc"; InternalName="EspecialidadDoc"; Type="Text"; AddToDefaultView=$true }
if (-not (Get-PnPField -List "DocumentosMantenimiento" -Identity "FechaMantenimiento" -ErrorAction SilentlyContinue)) {
    Add-PnPFieldFromXml -List "DocumentosMantenimiento" -FieldXml "<Field Type='DateTime' DisplayName='FechaMantenimiento' Name='FechaMantenimiento' StaticName='FechaMantenimiento' Format='DateOnly' />" | Out-Null
}
Ensure-Field "DocumentosMantenimiento" @{ DisplayName="IDMantenimiento"; InternalName="IDMantenimiento"; Type="Number"; AddToDefaultView=$true }

# =========================================================
# 4) ESTRUCTURA DE CARPETAS  /2026/[Fase]/[Especialidad]/
# =========================================================
Write-Host "`n[4/4] Estructura de carpetas 2026..." -ForegroundColor Yellow
$lib = "DocumentosMantenimiento"
Resolve-PnPFolder -SiteRelativePath "$lib/2026" | Out-Null
foreach ($e in $catalogo) {
    $path = "$lib/2026/$($e.Fase)/$($e.Title)"
    Resolve-PnPFolder -SiteRelativePath $path | Out-Null
}
Write-Host "  + $($catalogo.Count) carpetas de especialidad creadas bajo /2026." -ForegroundColor Green

Write-Host "`n== LISTO ==  Modelo de datos provisionado en $SiteUrl" -ForegroundColor Cyan
Write-Host "Siguiente paso: crear los flujos de Power Automate y la Power App (ver carpeta /flows y /app)." -ForegroundColor Cyan
