# scripts/desplegar.ps1

$ErrorActionPreference = "Stop"
$ENDPOINT = "--endpoint-url http://localhost:4566"

Write-Host "Iniciando despliegue de infraestructura en Floci..."

# 1. Crear tabla DynamoDB
Write-Host "Creando tabla DynamoDB 'documentos'..."
aws dynamodb create-table --table-name documentos --attribute-definitions AttributeName=documento_id,AttributeType=S --key-schema AttributeName=documento_id,KeyType=HASH --billing-mode PAY_PER_REQUEST $ENDPOINT

# 2. Crear S3 Bucket
Write-Host "Creando bucket S3 'documentos-entrada'..."
aws s3 mb s3://documentos-entrada $ENDPOINT

# 3. Desplegar Lambda 1: registrar_archivo
Write-Host "Empaquetando y desplegando Lambda: registrar_archivo..."
Compress-Archive -Path .\lambdas\registrar_archivo\handler.py -DestinationPath .\registrar_archivo.zip -Force
aws lambda create-function --function-name registrar_archivo --runtime python3.12 --role arn:aws:iam::000000000000:role/dummy-role --handler handler.lambda_handler --zip-file fileb://registrar_archivo.zip $ENDPOINT
aws lambda add-permission --function-name registrar_archivo --statement-id s3-permiso --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::documentos-entrada $ENDPOINT
aws s3api put-bucket-notification-configuration --bucket documentos-entrada --notification-configuration file://scripts/s3_notification.json $ENDPOINT

# 4. Desplegar Lambda 2: resumen_diario
Write-Host "Empaquetando y desplegando Lambda: resumen_diario..."
Compress-Archive -Path .\lambdas\resumen_diario\handler.py -DestinationPath .\resumen_diario.zip -Force
aws lambda create-function --function-name resumen_diario --runtime python3.12 --role arn:aws:iam::000000000000:role/dummy-role --handler handler.lambda_handler --zip-file fileb://resumen_diario.zip $ENDPOINT

# 5. Configurar EventBridge "EN ESTE CASO SE EJECUTARÁ CADA MINUTO". PUEDES CONFIGURARLO.
Write-Host "Configurando EventBridge (Cron cada 1 minuto)..."
aws events put-rule --name regla-resumen-diario --schedule-expression "rate(1 minute)" $ENDPOINT
aws events put-targets --rule regla-resumen-diario --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:000000000000:function:resumen_diario" $ENDPOINT
aws lambda add-permission --function-name resumen_diario --statement-id eventbridge-permiso --action lambda:InvokeFunction --principal events.amazonaws.com --source-arn arn:aws:events:us-east-1:000000000000:rule/regla-resumen-diario $ENDPOINT

# Limpiar archivos temporales
Remove-Item *.zip -Force

Write-Host "Despliegue completado con exito."
