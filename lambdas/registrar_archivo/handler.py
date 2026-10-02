import json
import urllib.parse
import boto3
import uuid
import os
from datetime import datetime, timezone

# Cliente de DynamoDB apuntando al emulador local
dynamodb = boto3.resource(
    'dynamodb',
    endpoint_url=os.environ.get('AWS_ENDPOINT_URL', 'http://localhost:4566'),
    region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
)

def lambda_handler(event, context):
    """
    Esta es la función principal (handler) que AWS Lambda ejecuta.
    'event' contiene los datos del evento que disparó la función (en este caso, S3).
    'context' contiene información sobre la ejecución de la función.
    """
    print("Se recibio un evento de S3")
    
    tabla_nombre = os.environ.get('TABLA_DOCUMENTOS', 'documentos')
    tabla = dynamodb.Table(tabla_nombre)
    
    # Procesar cada registro
    for record in event.get('Records', []):
        try:
            #Obtener nombre del bucket
            bucket_name = record['s3']['bucket']['name']
            
            #Obtener el nombre del archivo y decodificar caracteres especiales.
            file_key = urllib.parse.unquote_plus(record['s3']['object']['key'])
            
            # Obtener el tamaño del archivo.
            file_size = record['s3']['object']['size']
            
            print(f"Archivo detectado: {file_key} en {bucket_name} ({file_size} bytes)")
            
            # PARA GUARDAR EN DYNAMODB :
            documento_id = str(uuid.uuid4())
            fecha_actual = datetime.now(timezone.utc).isoformat()
            
            item = {
                'documento_id': documento_id,
                'nombre_archivo': file_key,
                'bucket': bucket_name,
                'tamanio_bytes': file_size,
                'fecha_subida': fecha_actual,
                'estado': 'registrado'
            }
            
            tabla.put_item(Item=item)
            print(f"Registro guardado en DynamoDB con ID: {documento_id}")
            
        except Exception as e:
            print(f"Error procesando el archivo: {e}")
            raise e
            
    return {
        'statusCode': 200,
        'body': json.dumps('Procesamiento completado con éxito')
    }
