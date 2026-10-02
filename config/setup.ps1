# config/setup.ps1
$env:AWS_ENDPOINT_URL="http://localhost:4566"
$env:AWS_ACCESS_KEY_ID="test"
$env:AWS_SECRET_ACCESS_KEY="test"
$env:AWS_DEFAULT_REGION="us-east-1"

$env:BUCKET_ENTRADA="documentos-entrada"
$env:TABLA_DOCUMENTOS="documentos"
$env:LAMBDA_REGISTRAR="registrar_archivo"
$env:LAMBDA_RESUMEN="resumen_diario"

Write-Host "Variables de entorno configuradas para Floci."
Write-Host "Endpoint: $env:AWS_ENDPOINT_URL"
Write-Host "Región: $env:AWS_DEFAULT_REGION"
