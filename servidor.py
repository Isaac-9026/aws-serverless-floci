import http.server
import socketserver
import urllib.parse
import json
import boto3
import os

# Configuración puerto
PORT = 8000

# Clientes Boto3 (con valores por defecto seguros por si la terminal no cargó el .ps1)
s3 = boto3.client(
    's3', 
    endpoint_url=os.environ.get('AWS_ENDPOINT_URL', 'http://localhost:4566'),
    region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'),
    aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID', 'test'),
    aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY', 'test')
)

dynamodb = boto3.resource(
    'dynamodb', 
    endpoint_url=os.environ.get('AWS_ENDPOINT_URL', 'http://localhost:4566'),
    region_name=os.environ.get('AWS_DEFAULT_REGION', 'us-east-1'),
    aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID', 'test'),
    aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY', 'test')
)

BUCKET_NAME = os.environ.get('BUCKET_ENTRADA', 'documentos-entrada')
TABLA_NOMBRE = os.environ.get('TABLA_DOCUMENTOS', 'documentos')

class ServerHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        # Forzamos a que el directorio raíz sea 'frontend'
        super().__init__(*args, directory='frontend', **kwargs)

    def do_POST(self):
        if self.path == '/upload':
            try:
                # Obtener el nombre del archivo de los headers
                file_name_encoded = self.headers.get('X-File-Name', 'upload.bin')
                file_name = urllib.parse.unquote(file_name_encoded)
                
                # Leer la longitud y el archivo enviado en binario
                content_length = int(self.headers.get('Content-Length', 0))
                file_data = self.rfile.read(content_length)
                
                # Subir directamente a S3
                s3.put_object(
                    Bucket=BUCKET_NAME,
                    Key=file_name,
                    Body=file_data
                )
                
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"Success")
            except Exception as e:
                print(f"Error: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            self.send_error(404)

    def do_GET(self):
        if self.path == '/stats':
            try:
                tabla = dynamodb.Table(TABLA_NOMBRE)
                respuesta = tabla.scan()
                documentos = respuesta.get('Items', [])
                
                total_archivos = len(documentos)
                peso_total_bytes = sum(int(item.get('tamanio_bytes', 0)) for item in documentos)
                peso_total_mb = round(peso_total_bytes / (1024 * 1024), 4)
                
                stats = {
                    "total_archivos": total_archivos,
                    "peso_total_mb": float(peso_total_mb)
                }
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(stats).encode())
            except Exception as e:
                print(f"Error: {e}")
                self.send_response(500)
                self.end_headers()
        elif self.path == '/items':
            try:
                tabla = dynamodb.Table(TABLA_NOMBRE)
                respuesta = tabla.scan()
                documentos = respuesta.get('Items', [])
                
                # Convertir Decimals para que sean serializables en JSON
                for doc in documentos:
                    if 'tamanio_bytes' in doc:
                        doc['tamanio_bytes'] = int(doc['tamanio_bytes'])
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(documentos).encode())
            except Exception as e:
                print(f"Error: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            # Servir archivos html, css, js por defecto
            super().do_GET()

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), ServerHandler) as httpd:
        print(f"Servidor Web iniciado. Abre tu navegador en: http://localhost:{PORT}")
        httpd.serve_forever()
