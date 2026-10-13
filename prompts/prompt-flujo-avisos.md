# Prompt de hand-off — FLX-AvisoProgramacion (correo de aviso anticipado)

Crea el flujo programado que avisa por correo qué mantenimientos **preventivos** hay
que coordinar en los próximos días. Totalmente configurable (días de anticipación,
destinatarios, frecuencia).

**Uso:** chat en **claude.ai** con la extensión de Chrome activa y
**https://make.powerautomate.com** abierto en una pestaña.

> ⚠️ Power Automate es un editor distinto a Power Apps y más difícil de automatizar.
> Si se traba, el paso a paso también está en `flows/README-flujos.md`.

---

```text
Tengo abierta en una pestaña de Chrome la página https://make.powerautomate.com
(Power Automate). Necesito que crees un flujo programado que me envíe por correo los
mantenimientos preventivos próximos a vencer.

════════════════════════════════════════
⚠️ LO MÁS IMPORTANTE: LA SINTAXIS
════════════════════════════════════════

Power Automate NO es Power Apps. Su lenguaje de EXPRESIONES usa **COMAS** como
separador, siempre, sin importar el idioma de la interfaz.

   CORRECTO en Power Automate:  formatDateTime(utcNow(),'yyyy-MM-dd')
   INCORRECTO:                  formatDateTime(utcNow();'yyyy-MM-dd')

Copia las expresiones EXACTAMENTE como te las doy, con comas. No las cambies.

SI EL EDITOR RECHAZA UNA EXPRESIÓN ("Hay un problema en esta expresión"), casi siempre
es una de estas dos causas, no un error de la expresión en sí:

  a) PARÉNTESIS DUPLICADOS. El editor autocompleta el paréntesis de cierre mientras
     escribes, así que te quedan `))` de más. Solución: BORRA todo el campo (Ctrl+A,
     Suprimir), PEGA la expresión completa de una vez (no la escribas carácter a
     carácter) y revisa que el número de paréntesis que abren y cierran coincida.
  b) COMILLAS CURVAS. Deben ser comillas rectas ' ' (apóstrofe simple), no ' '.
     Se ven casi idénticas en pantalla. Si dudas, borra las comillas y reescríbelas
     a mano desde el teclado.

════════════════════════════════════════
DATOS DEL ENTORNO
════════════════════════════════════════

Sitio SharePoint: https://cchccl.sharepoint.com/sites/Administracion
Lista:            Mantenimientos2026
Correo destino:   david.reboredo@outlook.com
Zona horaria:     Santiago de Chile  (en expresiones: 'Pacific SA Standard Time')

Columnas relevantes de la lista:
  Título, Especialidad (columna de búsqueda), TipoMantenimiento (Preventivo/Correctivo),
  FechaProgramada (fecha), Estado (Programado / En Ejecución / Ejecutado / Atrasado /
  Reprogramado / Cancelado), Proveedor.

════════════════════════════════════════
CÓMO TRABAJAR EN POWER AUTOMATE
════════════════════════════════════════

- Para escribir una EXPRESIÓN: haz clic en el campo, se abre el panel de contenido
  dinámico; elige la pestaña "Expresión" (fx), escribe la expresión y presiona Aceptar.
- Para RENOMBRAR una acción: en el diseñador NUEVO (panel lateral) se hace clic sobre
  el TÍTULO de la acción en el panel y se edita ahí; en el clásico está en los tres
  puntos (…) → "Cambiar nombre". RENOMBRA CADA ACCIÓN JUSTO DESPUÉS DE CREARLA, antes
  de pasar a la siguiente: las expresiones posteriores dependen de esos nombres exactos.
- Puede que el editor sea el "nuevo" (panel lateral) o el "clásico" (tarjetas
  verticales). Adáptate al que veas, pero no cambies el orden de las acciones.
- Si una acción pide elegir conexión, usa la cuenta ya conectada.

════════════════════════════════════════
TAREAS (en este orden exacto)
════════════════════════════════════════

PASO 1 — Crear el flujo
  - "+ Crear" → "Flujo de nube programado".
  - Nombre:  FLX-AvisoProgramacion
  - Inicio: mañana · Repetir cada: 1 Semana · Día: Lunes
  - Crear.
  - Abre la acción de Periodicidad / Recurrencia y ajusta:
        Zona horaria = (UTC-04:00) Santiago
        Horas = 8     Minutos = 0

PASO 2 — Variable: días de anticipación
  - Nueva acción → busca "Inicializar variable".
  - RENOMBRA la acción a:  varDias
  - Nombre = varDiasAnticipacion
    Tipo   = Entero
    Valor  = 15

PASO 3 — Variable: destinatarios
  - Nueva acción → "Inicializar variable".
  - RENOMBRA la acción a:  varCorreos
  - Nombre = varDestinatarios
    Tipo   = Cadena
    Valor  = david.reboredo@outlook.com

PASO 4 — Fecha de hoy
  - Nueva acción → busca "Redactar" (está bajo "Operación de datos"; en inglés: Compose).
  - RENOMBRA la acción a:  Hoy
  - En Entradas, pestaña Expresión, escribe:

utcNow('yyyy-MM-dd')

PASO 5 — Fecha límite
  - Nueva acción → "Redactar".
  - RENOMBRA la acción a:  Limite
  - En Entradas, pestaña Expresión, escribe:

addDays(utcNow(),int(variables('varDiasAnticipacion')),'yyyy-MM-dd')

  (El `int()` es necesario: el validador del diseñador nuevo tipa `variables()` como
   "cualquiera" y `addDays` exige un entero. Sin el cast, rechaza la expresión.
   Si aun así la rechaza, usa el literal `addDays(utcNow(),15,'yyyy-MM-dd')` y recuerda
   que entonces el número 15 queda también en el cuerpo del correo del PASO 10: para
   cambiar los días de anticipación habría que editar ambos lugares.)

PASO 6 — Buscar los mantenimientos
  - Nueva acción → busca el conector SharePoint → acción "Obtener elementos".
  - RENOMBRA la acción a:  ObtenerMantenimientos
  - Dirección del sitio = https://cchccl.sharepoint.com/sites/Administracion
    Nombre de la lista   = Mantenimientos2026
  - Despliega "Opciones avanzadas" y en "Consulta de filtro" pega EXACTAMENTE:

TipoMantenimiento eq 'Preventivo' and Estado eq 'Programado' and FechaProgramada ge '@{outputs('Hoy')}' and FechaProgramada le '@{outputs('Limite')}'

  - Pon también: Número máximo de elementos = 500

PASO 7 — Condición: ¿hay resultados?
  - Nueva acción → busca "Condición".
  - Lado izquierdo: pestaña Expresión →

length(body('ObtenerMantenimientos')?['value'])

  - Operador: "es mayor que"
  - Lado derecho: 0
  - TODO LO QUE SIGUE (pasos 8, 9 y 10) va dentro de la rama "En caso afirmativo"
    (If yes). No pongas nada en la rama "En caso negativo".

PASO 8 — Dar formato a los datos  [rama: En caso afirmativo]
  - Nueva acción → busca "Seleccionar" (Select).
  - RENOMBRA la acción a:  SeleccionarCampos
  - En "Desde", pestaña Expresión:

body('ObtenerMantenimientos')?['value']

  - En el "Mapa" cambia a modo de pares clave/valor y agrega estas 4 filas
    (la clave se escribe como texto; el valor va en pestaña Expresión):

      Clave: Mantenimiento   Valor:  item()?['Title']
      Clave: Especialidad    Valor:  item()?['Especialidad']?['Value']
      Clave: Fecha           Valor:  formatDateTime(item()?['FechaProgramada'],'dd-MM-yyyy')
      Clave: Proveedor       Valor:  item()?['Proveedor']

PASO 9 — Crear la tabla HTML  [rama: En caso afirmativo]
  - Nueva acción → busca "Crear tabla HTML".
  - RENOMBRA la acción a:  TablaHTML
  - En "Desde", pestaña Expresión:

body('SeleccionarCampos')

  - Columnas = Automáticas

PASO 10 — Enviar el correo  [rama: En caso afirmativo]
  - Nueva acción → conector "Office 365 Outlook" → "Enviar un correo electrónico (V2)".
  - RENOMBRA la acción a:  EnviarAviso
  - Para: pestaña Expresión →

variables('varDestinatarios')

  - Asunto (escríbelo como texto normal):

Mantenimientos preventivos por programar

  - Cuerpo: cambia el editor a modo código/HTML (botón "</>" en la barra del campo) y
    pega esto tal cual:

<p>Estimado/a:</p><p>Los siguientes mantenimientos preventivos deben coordinarse con el proveedor dentro de los próximos @{variables('varDiasAnticipacion')} días:</p>@{body('TablaHTML')}<p>Favor agendar y dejar la orden de trabajo en la carpeta correspondiente del SharePoint.</p><p>— Enviado automáticamente por el sistema de Mantenimiento CChC.</p>

PASO 11 — Guardar y probar
  - Guardar.
  - Presiona "Probar" → "Manualmente" → "Probar".
  - Dime si la ejecución salió en VERDE (correcto) o en ROJO (error).
  - Si salió en rojo, abre la acción que falló y cópiame el mensaje de error completo.

════════════════════════════════════════
CÓMO QUIERO QUE TRABAJES
════════════════════════════════════════
- Ve paso por paso, en orden. No saltes pasos.
- RENOMBRA cada acción apenas la creas. Si los nombres no coinciden exactamente
  (Hoy, Limite, ObtenerMantenimientos, SeleccionarCampos, TablaHTML), las expresiones
  fallarán.
- Después de cada PASO, dime qué hiciste y si hubo algún problema.
- Las expresiones van con COMAS. No las cambies por punto y coma.
- Si una acción no aparece con el nombre que te doy (la interfaz cambia entre
  versiones), DETENTE y descríbeme qué opciones ves, en vez de adivinar.
- Si aparece un error, DETENTE y cópiame el texto exacto.
- Al terminar, manda una captura del flujo completo.

RESULTADO ESPERADO: al probarlo, si hay mantenimientos preventivos programados dentro
de los próximos 15 días, llega un correo a david.reboredo@outlook.com con una tabla
que lista Mantenimiento, Especialidad, Fecha y Proveedor. Si no hay ninguno en ese
rango, el flujo termina en verde sin enviar nada (eso también es correcto).
```

---

## Cómo ajustarlo después (sin tocar la estructura)

| Quiero cambiar… | Dónde | Cómo |
|---|---|---|
| Cada cuánto llega el aviso | Acción **Periodicidad** | Frecuencia / Intervalo / Día / Hora |
| Días de anticipación | Acción **varDias** | Cambia el `15` por 7, 30, etc. |
| Quién lo recibe | Acción **varCorreos** | Correos separados por `;` |
| El asunto | Acción **EnviarAviso** | Edita el texto |
