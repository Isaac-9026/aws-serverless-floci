# Aplicación de Gestion de Documentos Serverless

Este es un proyecto academico diseñado para demostrar la construccion y el funcionamiento de una arquitectura orientada a eventos (Event-Driven Architecture) utilizando servicios de computo en la nube (emulados localmente con Floci/Docker).

## Arquitectura del Sistema

El proyecto esta dividido en dos flujos principales que convergen en una unica base de datos NoSQL:

### Actividad 01: Flujo Reactivo (S3 + Lambda)
1. El usuario sube un documento mediante la interfaz web local.
2. El archivo se almacena en el bucket de Amazon S3 (`documentos-entrada`).
3. S3 emite un evento `s3:ObjectCreated:*` de forma automatica.
4. AWS Lambda (`registrar_archivo`) captura el evento, extrae los metadatos del archivo y persiste un registro con un identificador unico en Amazon DynamoDB.

### Actividad 02: Flujo Proactivo y Programado (EventBridge)
1. Amazon EventBridge actúa como orquestador cronologico.
2. Cada minuto, EventBridge invoca la funcion Lambda `resumen_diario`.
3. Esta Lambda realiza un barrido de los registros en DynamoDB.
4. Calcula el total de documentos y el almacenamiento acumulado, imprimiendo un reporte en los registros del sistema.

## Conceptos Academicos Demostrados

* **Computo sin Servidor (Serverless):** Ejecucion de logica de negocio en contenedores efimeros bajo demanda.
* **Desacoplamiento:** Separacion clara entre el almacenamiento fisico (S3), el almacenamiento estructurado (DynamoDB) y la orquestacion de tiempo (EventBridge).
* **Infraestructura como Codigo:** Uso de la AWS CLI para definir triggers y reglas de planificacion directamente contra el entorno.

## Instrucciones de Ejecucion

Para conocer los pasos tecnicos sobre como inicializar el entorno, configurar las variables y probar ambas actividades, por favor revisa el archivo:

**[GUIA_EJECUCION.md](./GUIA_EJECUCION.md)**
