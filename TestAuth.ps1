# Definir tu token de acceso personal (PAT)
$pat = $PAT

# Codificar el PAT en base64
$patBytes = [System.Text.Encoding]::UTF8.GetBytes(":$($pat)")
$patBase64 = [Convert]::ToBase64String($patBytes)

# Definir la URL de la API de Azure DevOps para obtener el perfil del usuario autenticado
$organization = $ORG
$url = "https://dev.azure.com/$organization/_apis/resourceAreas/79134c72-4a58-4b42-976c-04e7115f32bf/?api-version=6.0-preview.1"

# Realizar la solicitud HTTP GET
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$response = Invoke-RestMethod -Uri $url -Headers @{Authorization=("Basic {0}" -f [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$PAT")))} -Method Get

$tfs = $response.locationUrl
$projectsUrl = "$($tfs)_apis/projects?api-version=6.0"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$projects = Invoke-RestMethod -Uri $projectsUrl -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$PAT")))}

$projects.value | ForEach-Object {
    Write-Host $_.name
}
# Comprobar la respuesta
#if ($response) {
#    Write-Output "Autenticado correctamente. Listado de proyectos:"
#    $response.value | ForEach-Object { Write-Output $_.name }
#    Write-Host $response.locationUrl
#} else {
#    Write-Output "No autenticado o error en la solicitud."
#}
