# Variables de configuración
$organization = $ORG
$project = $PROJECT
$personalAccessToken = $PAT

# Definir la URL de la API para crear un bug
$apiUrl = "https://dev.azure.com/$organization/$project/_apis/wit/workitems/`$Bug?api-version=6.0"

# Crear el cuerpo de la solicitud para crear el bug
$body = @{
    "op" = "add";
    "path" = "/fields/System.Title";
    "from" = "null";
    "value" = "Bug creado desde PowerShell";
} | ConvertTo-Json

# Configurar la autenticación con el token personal
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
$headers = @{
    "Authorization" = "Basic $token"
    "Content-Type" = "application/json-patch+json"
}

# Enviar la solicitud HTTP para crear el bug
$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body

# Verificar la respuesta
if ($response.id) {
    Write-Host "Bug creado exitosamente. ID: $($response.id)"
} else {
    Write-Host "Error al crear el bug: $($response.message)"
}