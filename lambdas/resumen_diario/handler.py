import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource(
    'dynamodb',
    endpoint_url=os.environ.get('AWS_ENDPOINT_URL', 'http://localhost:4566'),
    region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
)

def lambda_handler(event, context):
    
    #Esta Lambda se ejecuta por un evento programado (cron).
    #Su objetivo es leer los documentos en Dynamo y generar un resumen.
    
    print("Iniciando generación de resumen diario...")
    
    tabla_nombre = os.environ.get('TABLA_DOCUMENTOS', 'documentos')
    tabla = dynamodb.Table(tabla_nombre)
    
    try:
        #Obtenemos todos los registros
        respuesta = tabla.scan()
        documentos = respuesta.get('Items', [])
        
        total_archivos = len(documentos)
        peso_total_bytes = sum(int(item.get('tamanio_bytes', 0)) for item in documentos)
        
        # Calcular peso en MB para que sea legible
        peso_total_mb = float(peso_total_bytes) / (1024 * 1024)
        
        resumen = {
            "fecha_resumen": datetime.now().isoformat(),
            "total_archivos_recibidos": total_archivos,
            "peso_total_mb": round(peso_total_mb, 4)
        }
        
        print("RESUMEN DIARIO GENERADO")
        print(json.dumps(resumen, indent=2))
        
        return {
            'statusCode': 200,
            'body': json.dumps(resumen)
        }
        
    except Exception as e:
        print(f"Error al generar el resumen: {e}")
        raise e
