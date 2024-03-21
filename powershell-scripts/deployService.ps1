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
        case "usersubscription":
            $servicePort = "8090"
            break
        case "videogameproducts":
            $servicePort = "8100"
            break
        case "videogamestore":
            $servicePort = "8080"
            break
        default:
            $servicePort = "80"
    }
    return $servicePort
}

function pullDockerImage {
    param(
        [bool]$deployAll,
        [string]$imageName,
        [string]$imageVersion
    )
    if ($deployAll -eq true) {
        docker pull index.docker.io/dannybatchrun/usersubscription:$imageVersion
        docker pull index.docker.io/dannybatchrun/videogameproducts:$imageVersion
        docker pull index.docker.io/dannybatchrun/videogamestore:$imageVersion
    } else if ($deployAll -eq false) {
        docker pull index.docker.io/dannybatchrun/$imageName:$imageVersion
    }
}

function upgradeHelmDeployment {
    param(
        [string]$imageName,
        [string]$imageTag,
        [string]$servicePort
    )
    [string]$chartVersion = $imageTag
    $chartVersion = $chartVersion -replace '[^\d.]', ''
    Write-Host "**** Chart Version of Helm : $chartVersion ****"
    Set-Location "helm-integration/$imageName"
    $chartContent = Get-Content Chart.yaml
    $chartContent = $chartContent -replace '^version: 0.1.0', "version: '${chartVersion}'"
    $chartContent | Set-Content Chart.yaml
    helm package .
    kubectl scale --replicas=0 deployment/$imageName -n $imageName
    helm upgrade $imageName . --set image.repository=index.docker.io/dannybatchrun/$imageName,image.tag=$imageTag,image.pullPolicy=Always,service.port=$servicePort,livenessProbe.httpGet.path=/health,livenessProbe.httpGet.port=$servicePort,service.type=NodePort -n $imageName
    kubectl scale --replicas=1 deployment/$imageName -n $imageName
}
