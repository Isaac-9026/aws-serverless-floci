# Guia de Configuracion: Entorno Local AWS con Floci

Esta guia detalla los pasos para configurar un entorno de desarrollo local emulando servicios de AWS utilizando Floci y Docker, culminando con la preparacion y prueba de un Sistema de Gestion de Documentos Serverless (S3, Lambda, DynamoDB, EventBridge) usando Python.

---

## Glosario Basico

* **CLI**: Interfaz de linea de comandos (Command Line Interface).
* **Serverless**: Modelo de ejecucion donde la nube gestiona dinamicamente la asignacion de recursos (cero servidores que administrar por parte del cliente).
* **Floci**: Herramienta basada en LocalStack para emular los servicios de AWS de manera local.

---

## Requisitos Previos

0. Tener instalado y en ejecucion **Docker Desktop**.
1. Tener instalado **Python 3.12+**.

---

## Fase 1: Instalacion y Configuracion

### 1. Instalar Floci
Abre **PowerShell como Administrador** y ejecuta el siguiente comando:

```powershell
iwr https://floci.io/install.ps1 | iex
```

> **Nota:** Al finalizar, cierra y vuelve a abrir PowerShell (como Administrador).

### 2. Iniciar Floci
Ejecuta el siguiente comando para descargar y configurar el contenedor:

```powershell
floci start
```

> **Verificacion:** Abre Docker Desktop y verifica que el nuevo contenedor de Floci este en ejecucion.

### 3. Gestionar Credenciales AWS (AWS CLI)
Instala la interfaz de comandos de AWS ejecutando en PowerShell:

```powershell
irm https://awscli.amazonaws.com/v2/install.ps1 | iex
```

> **Nota:** Al finalizar, cierra y vuelve a abrir PowerShell. Verifica la instalacion ejecutando `aws --version`.

### 4. Configurar AWS CLI para Floci
Configura las variables de entorno para redirigir el trafico de red hacia Floci. En la terminal de tu proyecto, ejecuta:

```powershell
floci env --shell powershell
floci env --shell powershell | Invoke-Expression
```

### 5. Verificar las variables de entorno
Comprueba que las variables apunten al entorno local:

```powershell
$env:AWS_ENDPOINT_URL
# Resultado esperado: http://localhost.floci.io:4566 o http://localhost:4566

$env:AWS_DEFAULT_REGION
# Resultado esperado: us-east-1
```

> **[Atencion] Solucion de problemas (Alternativa de configuracion directa):**  
> Si el comando `Invoke-Expression` arrojo excepciones o errores, declara las variables manualmente cargando nuestro script provisto:
>
> ```powershell
> . .\config\setup.ps1
> ```
> O escribiendo manualmente en PowerShell:
> ```powershell
> $env:AWS_ENDPOINT_URL = 'http://localhost:4566'
> $env:AWS_ACCESS_KEY_ID = 'test'
> $env:AWS_SECRET_ACCESS_KEY = 'test'
> $env:AWS_DEFAULT_REGION = 'us-east-1'
> ```

---

## [Punto de Control] Resumen de Fase 1

Hasta este punto se ha logrado:
- [x] Instalar los componentes requeridos: AWS CLI, Floci y Docker Desktop.
- [x] Configurar Floci y definir correctamente las variables de entorno locales.
- [x] Conocer los comandos basicos de Floci:
  - `floci start` — Iniciar servicio.
  - `floci stop` — Detener servicio.
  - `floci doctor` — Diagnostico detallado del contenedor.

**Servicios integrables localmente en este proyecto:**
`S3`, `DynamoDB`, `Lambda`, `EventBridge`.

---

## Fase 2: Despliegue del Entorno y API Python

### 6. Instalar dependencias del proyecto
Abre la terminal en la carpeta raiz de tu proyecto (`d:\aws-lambda`) e instala el SDK de AWS para Python (`boto3`):

```powershell
pip install -r requirements.txt
```

### 7. Aprovisionar la Infraestructura en Floci
El proyecto incluye un script automatizado que crea la tabla en DynamoDB, el bucket S3, empaqueta el codigo de ambas funciones Lambda y configura la regla de EventBridge (1 minuto). En la raiz del proyecto, ejecuta:

```powershell
.\scripts\desplegar.ps1
```

> **[Punto de Control]** Veras que el script emite mensajes por consola confirmando la creacion exitosa de cada componente.

### 8. Inicializar el Servidor Backend Local
El proyecto cuenta con un servidor ligero nativo en Python (`servidor.py`) que gestiona las vistas HTML sin necesidad de librerias externas (reemplazando frameworks como Express de Node.js). 

Para iniciarlo, ejecuta en la consola:

```powershell
python servidor.py
```

> **Verificacion:** Ingresa a `http://localhost:8000` en tu navegador de preferencia. La aplicacion web debe estar visible.

---

## Fase 3: Pruebas de la Arquitectura Serverless

### 9. Prueba de la Actividad 01 (Flujo Reactivo)
1. Desde el sitio web local (`http://localhost:8000`), selecciona un archivo de prueba (ej. `.pdf`, `.jpg`, `.txt`) y haz clic en **Subir a S3**.
2. Automáticamente en el backend: El evento `s3:ObjectCreated:*` es interceptado por Floci y disparara la ejecucion de nuestra funcion `registrar_archivo`.
3. Verifica que los metadatos se hayan guardado con exito abriendo `http://localhost:8000/tabla.html` para consultar los registros extraidos de DynamoDB.

### 10. Prueba de la Actividad 02 (Flujo Programado / Cron)
La regla de Amazon EventBridge ha sido configurada previamente para despertar de forma autonoma a la funcion Lambda `resumen_diario` cada 1 minuto.

Para corroborar la automatizacion:
1. Abre una nueva ventana de terminal (PowerShell o CMD).
2. Inspecciona los registros en tiempo real del orquestador:
   ```powershell
   docker logs -f floci
   ```
3. **Resultado esperado:** Cada minuto debera aparecer un bloque JSON impreso conteniendo las metricas procesadas.

> **[Exito] ¡FLOCI Y TODOS LOS SERVICIOS SERVERLESS ESTAN ONLINE Y FUNCIONANDO!**
