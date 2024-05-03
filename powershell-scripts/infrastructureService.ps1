function call() {
    Write-Host "VideogameServiceInfrastructure initialized"
    return this
}

function runPipeline {
    param(
        [string]$pipelineId,
        [string]$pat,
        [hashtable]$parameters
    )
    $organizationUrl = "https://dev.azure.com/infraplayground"
    $projectName = "videogame-store-example-infrastructure"
    $url = "$organizationUrl/$projectName/_apis/build/builds?api-version=6.0"
    $body = @{
        definition = @{
            id = $pipelineId
        }
        parameters = $parameters
    } | ConvertTo-Json
    $headers = @{
        "Content-Type" = "application/json"
        Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
    }
    Write-Host "ORGANIZATIONURL!!! $organizationUrl"
    Write-Host "PAT!!! $pat"
    Write-Host "PARAMETERS!!! $parameters"
    Write-Host "BODY!!! $body"
    Write-Host "HEADERS!!! $headers"
    try {
        Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers
        Write-Host "Pipeline avviata con successo."
    } catch {
        Write-Host "Si è verificato un errore durante l'avvio della pipeline: $_"
    }
    $completedPipeline = $false
    while (-not $completedPipeline) {
        $statusPipelineCommand = "az pipelines runs show --id $pipelineId --org $organizationUrl --project $projectName --output json"
        $statusPipeline = Invoke-Expression $statusPipelineCommand | ConvertFrom-Json
        Write-Host "Stato attuale della pipeline:" $statusPipeline.status
        if ($statusPipeline.status -eq "completed") {
            $completedPipeline = $true
            Write-Host "Pipeline completata."
        } else {
            Write-Host "Pipeline non completata. Controllo previsto tra circa un minuto."
            Start-Sleep -Seconds 60
        }
    }
}

function runPipelineOld {
    param(
        [string]$name,
        [string]$branch,
        [string]$passArguments
    )
    $organization = "https://dev.azure.com/infraplayground"
    $runPipelineCommand = "az pipelines run --name $name --org $organization --project videogame-store-example-infrastructure --branch $branch --parameters $passArguments --output json"
    Write-Host "runPipelineCommand is $runPipelineCommand"
    $runResult = Invoke-Expression $runPipelineCommand | ConvertFrom-Json
    $runId = $runResult.id
    $completedPipeline = $false
    while (-not $completedPipeline) {
        $statusPipelineCommand = "az pipelines runs show --id $runId --org $organization --project videogame-store-example-infrastructure --output json"
        $statusPipeline = Invoke-Expression $statusPipelineCommand | ConvertFrom-Json
        Write-Host "Stato attuale della pipeline:" $statusPipeline.status
        if ($statusPipeline.status -eq "completed") {
            $completedPipeline = $true
            Write-Host "Pipeline completata."
        } else {
            Write-Host "Pipeline non completata. Controllo previsto tra circa un minuto."
            Start-Sleep -Seconds 60
        }
    }
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
    Invoke-Expression 'helm uninstall usersubscription -n usersubscription || $true'
    Invoke-Expression 'helm uninstall usersubscription -n usersubscription || $true'
    Invoke-Expression 'helm uninstall videogamestore -n videogamestore || $true'
    Write-Host "**** Deleting Docker Images ****"
    docker images -q dannybatchrun/usersubscription | ForEach-Object { docker rmi $_ -f -ErrorAction SilentlyContinue }
    docker images -q dannybatchrun/videogameproducts | ForEach-Object { docker rmi $_ -f -ErrorAction SilentlyContinue }
    docker images -q dannybatchrun/videogamestore | ForEach-Object {
        docker rmi $_ -f -ErrorAction SilentlyContinue
        $deployments = kubectl get deployments --all-namespaces -o json -ErrorAction SilentlyContinue | ConvertFrom-Json
        try
        {
            $deployments = kubectl get deployments --all-namespaces -o json | ConvertFrom-Json
            if ($null -ne $deployments -or ($deployments.items.metadata.name -notcontains "No resources found"))
            {
                kubectl delete deployments --all --all-namespaces
            }
            else
            {
                Write-Host "Nessun deployment trovato."
            }
        }
        catch
        {
            Write-Host "Errore durante il recupero delle informazioni sui deployments."
        }
    }
}



































