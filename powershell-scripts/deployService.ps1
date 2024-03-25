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
    $chartVersion = $imageTag -replace '[^0-9.]', ''
    Write-Host "**** Chart Version of Helm: $chartVersion ****"
    Set-Location "helm-integration/${imageName}"
    (Get-Content Chart.yaml) -replace '^version:.*', "version: $chartVersion" | Set-Content Chart.yaml
    $helmArguments = @{
        "image.repository" = "index.docker.io/dannybatchrun/${imageName}"
        "image.tag" = $imageTag
        "image.pullPolicy" = "Always"
        "service.port" = $servicePort
        "livenessProbe.httpGet.path" = "/health"
        "livenessProbe.httpGet.port" = $servicePort
        "service.type" = "NodePort"
    }
    $helmArgsArray = @()
    foreach ($key in $helmArguments.Keys) {
        $helmArgsArray += "--set $key=$($helmArguments[$key])"
    }
    $helmArgsString = $helmArgsArray -join ' '
    helm package .
    kubectl scale --replicas=0 "deployment/${imageName}" -n "${imageName}"
    helm upgrade "${imageName}" . $helmArgsString -n "${imageName}"
    kubectl scale --replicas=1 "deployment/${imageName}" -n "${imageName}"
}


