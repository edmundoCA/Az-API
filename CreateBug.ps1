function GetUrl() {
    param(
        [string]$orgUrl, 
        [hashtable]$header, 
        [string]$AreaId
    )

    # Area ids
    # https://docs.microsoft.com/en-us/azure/devops/extend/develop/work-with-urls?view=azure-devops&tabs=http&viewFallbackFrom=vsts#resource-area-ids-reference
    # Build the URL for calling the org-level Resource Areas REST API for the RM APIs
    $orgResourceAreasUrl = [string]::Format("{0}/_apis/resourceAreas/{1}?api-version=6.0-preview.1", $orgUrl, $AreaId)

    # Do a GET on this URL (this returns an object with a "locationUrl" field)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $results = Invoke-RestMethod -Uri $orgResourceAreasUrl -Headers $header

    # The "locationUrl" field reflects the correct base URL for RM REST API calls
    if ("null" -eq $results) {
        $areaUrl = $orgUrl
    }
    else {
        $areaUrl = $results.locationUrl
    }

    return $areaUrl
}

# Variables de configuración
$base = "https://dev.azure.com"
$organization = $ORG
$project = $PROJECT
$personalAccessToken = $PAT

$orgUrl = "https://dev.azure.com/$organization"

# Configurar la autenticación con el token personal
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
$header = @{ authorization = "Basic $token" }

# DEMO 1 Projects - List
Write-Host "Getting list of projects" -ForegroundColor Green
$coreAreaId = "79134c72-4a58-4b42-976c-04e7115f32bf"
$tfsBaseUrl = GetUrl -orgUrl $orgUrl -header $header -AreaId $coreAreaId

# https://docs.microsoft.com/en-us/rest/api/azure/devops/core/projects/list?view=azure-devops-rest-5.1
$projectsUrl = "$($tfsBaseUrl)_apis/projects?api-version=6.0"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-RestMethod -Uri "$base/$organization/_apis/projects?api-version=6.0" -Method Get -ContentType "application/json" -Headers $header

$projects.value | ForEach-Object {
    Write-Host $_.name
}

# Definir la URL de la API para crear un bug
$apiUrl = "https://dev.azure.com/$organization/$project/_apis/wit/workitems/`$Bug?api-version=6.0"

# Crear el cuerpo de la solicitud para crear el bug
$body = @{
    "op" = "add";
    "path" = "/fields/System.Title";
    "from" = "null";
    "value" = "Bug creado desde PowerShell";
} | ConvertTo-Json


# Enviar la solicitud HTTP para crear el bug
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$response = Invoke-RestMethod $apiUrl -Method Post -ContentType "application/json-patch+json" -Headers $header -Body $body

# Verificar la respuesta
if ($response.id) {
    Write-Host "Bug creado exitosamente. ID: $($response.id)"
} else {
    Write-Host "Error al crear el bug: $($response.message)"
}