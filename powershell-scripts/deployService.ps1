function call() {
    Write-Host "VideogameServiceDeploy initialized"
    return this;
}

function getServicePort {
    param(
        [string]$microservice
    )
    [string]$servicePort
    switch ($microservice) {
        "usersubscription" { $servicePort = "8090"; Break }
        "videogameproducts" { $servicePort = "8100"; Break }
        "videogamestore" { $servicePort = "8080"; Break }
    }
    return $servicePort
}

function pullDockerImage {
    param(
        [bool]$deployAll,
        [string]$imageName,
        [string]$imageVersion
    )

    if ($deployAll -eq $true) {
        docker pull "index.docker.io/dannybatchrun/usersubscription:$imageVersion"
        docker pull "index.docker.io/dannybatchrun/videogameproducts:${imageVersion}"
        docker pull "index.docker.io/dannybatchrun/videogamestore:${imageVersion}"
    } elseif ($deployAll -eq $false) {
        docker pull "index.docker.io/dannybatchrun/${imageName}:${imageVersion}"
    }
}


function upgradeHelmDeployment {
    param(
        [string]$releaseName,
        [string]$chartPath,
        [string]$imageName,
        [string]$imageTag,
        [string]$servicePort
    )

    $chartVersion = $imageTag -replace '[^0-9.]', ''
    Write-Host "**** Chart Version of Helm: $chartVersion ****"
    $chartFilePath = "$chartPath/Chart.yaml"
    (Get-Content $chartFilePath) -replace '^version:.*', "version: $chartVersion" | Set-Content $chartFilePath
    $helmCommand = "helm upgrade $releaseName $chartPath"
    $helmCommand += " --set image.repository=index.docker.io/dannybatchrun/$imageName"
    $helmCommand += ",image.tag=$imageTag"
    $helmCommand += ",image.pullPolicy=Always"
    $helmCommand += ",service.port=$servicePort"
    $helmCommand += ",livenessProbe.httpGet.path=/health"
    $helmCommand += ",livenessProbe.httpGet.port=$servicePort"
    $helmCommand += ",service.type=NodePort"
    Write-Host "Executing Helm command: $helmCommand"
    Invoke-Expression $helmCommand
}














