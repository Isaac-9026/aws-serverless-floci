# Aplicación de Gestión de Documentos Serverless

Este es un proyecto académico diseñado para demostrar la construcción y el funcionamiento de una arquitectura orientada a eventos (Event-Driven Architecture) utilizando servicios de computación en la nube, emulados localmente con Floci/Docker.

## Objetivo

Desarrollar una aplicación de gestión de documentos que permita almacenar archivos en Amazon S3, registrar automáticamente sus metadatos mediante AWS Lambda y generar periódicamente un resumen de los documentos registrados utilizando Amazon EventBridge.

## Arquitectura del Sistema

El proyecto está dividido en dos flujos principales que convergen en una única base de datos NoSQL:

### Actividad 01: Flujo Reactivo (S3 + Lambda)

1. El usuario sube un documento mediante la interfaz web local.
2. El archivo se almacena en el bucket de Amazon S3 (`documentos-entrada`).
3. S3 emite un evento `s3:ObjectCreated:*` de forma automática.
4. AWS Lambda (`registrar_archivo`) captura el evento, extrae los metadatos del archivo y persiste un registro con un identificador único en Amazon DynamoDB.

### Actividad 02: Flujo Programado (EventBridge)

1. Amazon EventBridge permite programar la ejecución periódica de una función Lambda.
2. Cada minuto, EventBridge invoca la función Lambda `resumen_diario`.
3. Esta Lambda realiza un barrido de los registros en DynamoDB.
4. Calcula el total de documentos y el almacenamiento acumulado, imprimiendo un reporte en los registros del sistema.

## Flujo de Integración

El sistema combina un flujo reactivo y un flujo programado:

* **Flujo reactivo:** cuando un usuario carga un documento, S3 genera un evento que activa automáticamente la Lambda `registrar_archivo`, la cual registra los metadatos en DynamoDB.
* **Flujo programado:** cada minuto, EventBridge activa la Lambda `resumen_diario`, que consulta los documentos registrados y genera un resumen de la información almacenada.

De esta manera, ambas actividades trabajan sobre una misma fuente de información y forman parte de un único sistema.

## Funcionalidades Principales

* Carga de documentos desde una interfaz web.
* Almacenamiento de archivos en Amazon S3.
* Detección automática de nuevos archivos mediante eventos de S3.
* Registro automático de metadatos en DynamoDB.
* Consulta de documentos registrados.
* Visualización de estadísticas básicas.
* Generación automática de resúmenes periódicos.
* Ejecución local de los servicios mediante Floci y Docker.

## Tecnologías Utilizadas

* **Python:** desarrollo de las funciones Lambda y servidor local.
* **Boto3:** interacción con los servicios de AWS.
* **Amazon S3:** almacenamiento de documentos.
* **AWS Lambda:** procesamiento de eventos y generación de resúmenes.
* **Amazon DynamoDB:** almacenamiento de metadatos.
* **Amazon EventBridge:** ejecución programada de Lambda.
* **HTML, CSS y JavaScript:** desarrollo de la interfaz web.
* **AWS CLI:** configuración y administración de los recursos.
* **Floci + Docker:** emulación local de los servicios de AWS.

## Conceptos Académicos Demostrados

* **Cómputo sin Servidor (Serverless):** Ejecución de funciones bajo demanda sin necesidad de administrar directamente servidores o infraestructura de ejecución.
* **Desacoplamiento:** Separación clara entre el almacenamiento de archivos (S3), el almacenamiento estructurado de metadatos (DynamoDB) y la programación de tareas (EventBridge).
* **Arquitectura Orientada a Eventos:** Uso de eventos generados por S3 para activar automáticamente funciones Lambda ante la creación de nuevos archivos.
* **Infraestructura como Código:** Uso de la AWS CLI para definir triggers y reglas de planificación directamente contra el entorno.

## Instrucciones de Ejecución

Para conocer los pasos técnicos sobre cómo inicializar el entorno, configurar las variables y probar ambas actividades, por favor revisa el archivo:

**[GUIA_EJECUCION.md](./GUIA_EJECUCION.md)**
