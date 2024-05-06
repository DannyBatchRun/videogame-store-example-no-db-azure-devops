function call() {
    Write-Host "VideogameServiceInfrastructure initialized"
    return this
}

function executeCommand {
    param(
        [string]$command
    )
    try {
        Invoke-Expression -Command $command
        Write-Host "$command command executed successfully"
    } catch {
        Write-Error "$Command command failed."
    }
}

function createHelmManifest {
    param(
        [string]$microservice
    )
    $currentLocation = Get-Location
    $path = "helm-integration/${microservice}"
    Write-Host "**** Path: $path ****"
    Set-Location $path
    helm package .
    $pkg = (Get-ChildItem -Filter "*.tgz" | ForEach-Object { $_.Name }) -join "`n"
    $helmInstallCommand = "helm install $microservice ./$pkg --set 'image.repository=index.docker.io/dannybatchrun/$microservice,image.tag=$imageTag,image.pullPolicy=Always,service.port=$servicePort,livenessProbe.httpGet.path=/health,livenessProbe.httpGet.port=$servicePort,livenessProbe.initialDelaySeconds=30,readinessProbe.httpGet.path=/health,readinessProbe.httpGet.port=$servicePort,readinessProbe.initialDelaySeconds=30,service.type=LoadBalancer' -n $microservice"
    Invoke-Expression $helmInstallCommand
    [string]$helmManifestCommand = "helm get manifest $microservice -n $microservice"
    Invoke-Expression $helmManifestCommand
    Set-Location $currentLocation
}

function installOrUpgradeHelmManifest {
    param(
        [string]$microservice,
        [string]$imageTag,
        [string]$servicePort
    )
    $currentLocation = Get-Location
    $helmList = (helm list --short -n $microservice 2>$null).Trim()
    [bool]$isPresent = if ($helmList -match $microservice) { $true } else { $false }
    $path = "helm-integration/${microservice}"
    Write-Host "**** Path: $path ****"
    Set-Location $path
    helm package .
    if($isPresent -eq $true) {
        $pkg = (Get-ChildItem -Filter "*.tgz" | ForEach-Object { $_.Name }) -join "`n"
        $helmInstallCommand = "helm install $microservice ./$pkg --set 'image.repository=index.docker.io/dannybatchrun/$microservice,image.tag=$imageTag,image.pullPolicy=Always,service.port=$servicePort,livenessProbe.httpGet.path=/health,livenessProbe.httpGet.port=$servicePort,livenessProbe.initialDelaySeconds=30,readinessProbe.httpGet.path=/health,readinessProbe.httpGet.port=$servicePort,readinessProbe.initialDelaySeconds=30,service.type=LoadBalancer' -n $microservice"
        Invoke-Expression $helmInstallCommand
    } elseif ($isPresent -eq $false) {
        $chartVersion = $imageTag -replace '[^0-9.]', ''
        Write-Host "**** Chart Version of Helm: $chartVersion ****"
        $chartContent = Get-Content Chart.yaml
        $chartContent = $chartContent -replace '^version:.*', "version: ${chartVersion}"
        $chartContent | Set-Content Chart.yaml
        kubectl scale --replicas=0 "deployment/${imageName}" -n "${imageName}"
        $helmUpgradeCommand = "helm upgrade $imageName . --set 'image.repository=index.docker.io/dannybatchrun/$microservice,image.tag=$imageTag,image.pullPolicy=Always,service.port=$servicePort,livenessProbe.httpGet.path=/health,livenessProbe.httpGet.port=$servicePort,livenessProbe.initialDelaySeconds=30,readinessProbe.httpGet.path=/health,readinessProbe.httpGet.port=$servicePort,readinessProbe.initialDelaySeconds=30,service.type=LoadBalancer' -n $microservice"
        Invoke-Expression $helmUpgradeCommand
        kubectl scale --replicas=1 "deployment/${imageName}" -n "${imageName}"
    }
    $networkPolicyExists = (kubectl get networkpolicy allow-all -n $microservice --ignore-not-found 2>$null).Trim()
    if ($networkPolicyExists) {
        Write-Output "NetworkPolicy allow-all already exists in namespace $microservice"
    } else {
        kubectl apply -f helm-integration\$microservice\networkpolicy.yaml -n $microservice
    }
    Set-Location $currentLocation
}

function controlContext {
    param(
        [string]$requested
    )
    $currentContext = (kubectl config current-context).Trim()
    if($currentContext -ne $requested) {
        kubectl config use-context $requested
        Write-Host "Switched to $requested context"
    } else {
        Write-Host "Already in $requested context"
    }
}

function cleanLocalInfrastructures {
    Write-Host "**** Deleting Helm Manifests ****"
    Invoke-Expression 'helm uninstall usersubscription -n usersubscription -ErrorAction SilentlyContinue'
    Invoke-Expression 'helm uninstall videogameproducts -n videogameproducts -ErrorAction SilentlyContinue'
    Invoke-Expression 'helm uninstall videogamestore -n videogamestore -ErrorAction SilentlyContinue'
    Write-Host "**** Deleting Docker Images ****"
    docker images -q dannybatchrun/usersubscription | ForEach-Object { docker rmi $_ -f -ErrorAction SilentlyContinue }
    docker images -q dannybatchrun/videogameproducts | ForEach-Object { docker rmi $_ -f -ErrorAction SilentlyContinue }
    docker images -q dannybatchrun/videogamestore | ForEach-Object { docker rmi $_ -f -ErrorAction SilentlyContinue }

    Write-Host "**** Deleting Kubernetes Deployments ****"
    try {
        $deployments = kubectl get deployments --all-namespaces -o json -ErrorAction Stop | ConvertFrom-Json
        if ($null -ne $deployments.items) {
            foreach ($deployment in $deployments.items) {
                kubectl delete deployment $deployment.metadata.name --namespace $deployment.metadata.namespace
            }
        } else {
            Write-Host "No deployments found."
        }
    } catch {
        Write-Host "Error retrieving deployment information."
    }
}













































