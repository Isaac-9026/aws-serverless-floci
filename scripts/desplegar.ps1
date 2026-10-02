$ErrorActionPreference = "Stop"

$ENDPOINT = "http://localhost:4566"

Write-Host "Iniciando despliegue de infraestructura en Floci..."

# Funcion para ejecutar AWS CLI y detener el despliegue si falla
function Invoke-Aws {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & aws @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "AWS CLI fallo con codigo $LASTEXITCODE"
    }
}

# 1. Crear tabla DynamoDB
Write-Host "Creando tabla DynamoDB 'documentos'..."

Invoke-Aws @(
    "dynamodb",
    "create-table",
    "--table-name", "documentos",
    "--attribute-definitions", "AttributeName=documento_id,AttributeType=S",
    "--key-schema", "AttributeName=documento_id,KeyType=HASH",
    "--billing-mode", "PAY_PER_REQUEST",
    "--endpoint-url", $ENDPOINT
)

# 2. Crear bucket S3
Write-Host "Creando bucket S3 'documentos-entrada'..."

Invoke-Aws @(
    "s3",
    "mb",
    "s3://documentos-entrada",
    "--endpoint-url", $ENDPOINT
)

# 3. Desplegar Lambda registrar_archivo
Write-Host "Empaquetando y desplegando Lambda: registrar_archivo..."

Compress-Archive `
    -Path .\lambdas\registrar_archivo\handler.py `
    -DestinationPath .\registrar_archivo.zip `
    -Force

Invoke-Aws @(
    "lambda",
    "create-function",
    "--function-name", "registrar_archivo",
    "--runtime", "python3.12",
    "--role", "arn:aws:iam::000000000000:role/dummy-role",
    "--handler", "handler.lambda_handler",
    "--zip-file", "fileb://registrar_archivo.zip",
    "--endpoint-url", $ENDPOINT
)

Invoke-Aws @(
    "lambda",
    "add-permission",
    "--function-name", "registrar_archivo",
    "--statement-id", "s3-permiso",
    "--action", "lambda:InvokeFunction",
    "--principal", "s3.amazonaws.com",
    "--source-arn", "arn:aws:s3:::documentos-entrada",
    "--endpoint-url", $ENDPOINT
)

Invoke-Aws @(
    "s3api",
    "put-bucket-notification-configuration",
    "--bucket", "documentos-entrada",
    "--notification-configuration", "file://scripts/s3_notification.json",
    "--endpoint-url", $ENDPOINT
)

# 4. Desplegar Lambda resumen_diario
Write-Host "Empaquetando y desplegando Lambda: resumen_diario..."

Compress-Archive `
    -Path .\lambdas\resumen_diario\handler.py `
    -DestinationPath .\resumen_diario.zip `
    -Force

Invoke-Aws @(
    "lambda",
    "create-function",
    "--function-name", "resumen_diario",
    "--runtime", "python3.12",
    "--role", "arn:aws:iam::000000000000:role/dummy-role",
    "--handler", "handler.lambda_handler",
    "--zip-file", "fileb://resumen_diario.zip",
    "--endpoint-url", $ENDPOINT
)

# 5. Configurar EventBridge cada 1 minuto (A JUSTAR SEGUN PRUEBAS)
Write-Host "Configurando EventBridge (Cron cada 1 minuto)..."

Invoke-Aws @(
    "events",
    "put-rule",
    "--name", "regla-resumen-diario",
    "--schedule-expression", "rate(1 minute)",
    "--endpoint-url", $ENDPOINT
)

$LambdaArn = "arn:aws:lambda:us-east-1:000000000000:function:resumen_diario"

Invoke-Aws @(
    "events",
    "put-targets",
    "--rule", "regla-resumen-diario",
    "--targets", "Id=1,Arn=$LambdaArn",
    "--endpoint-url", $ENDPOINT
)

Invoke-Aws @(
    "lambda",
    "add-permission",
    "--function-name", "resumen_diario",
    "--statement-id", "eventbridge-permiso",
    "--action", "lambda:InvokeFunction",
    "--principal", "events.amazonaws.com",
    "--source-arn", "arn:aws:events:us-east-1:000000000000:rule/regla-resumen-diario",
    "--endpoint-url", $ENDPOINT
)

# Limpiar archivos temporales
Remove-Item .\registrar_archivo.zip -Force -ErrorAction SilentlyContinue
Remove-Item .\resumen_diario.zip -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Despliegue completado con exito." -ForegroundColor Green
