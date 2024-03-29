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
        [string]$imageName,
        [string]$imageTag,
        [string]$servicePort
    )

    $currentLocation = Get-Location
    $imageName = $imageName.Trim()
    $imageTag = $imageTag.Trim()
    $servicePort = $servicePort.Trim()
    $chartVersion = $imageTag -replace '[^0-9.]', ''
    Write-Host "**** Chart Version of Helm: $chartVersion ****"
    $path = "helm-integration/${imageName}"
    Write-Host "**** Path: $path ****"
    Set-Location $path
    $chartContent = Get-Content Chart.yaml
    $chartContent = $chartContent -replace '^version:.*', "version: ${chartVersion}"
    $chartContent | Set-Content Chart.yaml
    helm package .
    kubectl scale --replicas=0 "deployment/${imageName}" -n "${imageName}"
    $helmUpgradeCommand = "helm upgrade $imageName . --set ""image.repository=index.docker.io/dannybatchrun/$imageName,image.tag=$imageTag,image.pullPolicy=Always,service.port=$servicePort,livenessProbe.httpGet.path=/health,livenessProbe.httpGet.port=$servicePort,service.type=NodePort"" -n $imageName"
    Invoke-Expression $helmUpgradeCommand
    kubectl scale --replicas=1 "deployment/${imageName}" -n "${imageName}"
    Set-Location $currentLocation
}

















