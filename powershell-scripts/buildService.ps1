function call {
    Write-Host "VideogameService initialized"
}

function createJarFile {
    param(
        [string]$Path
    )
    Set-Location $Path
    mvn -v
    mvn clean install
}

function buildAndPushOnDocker {
    param(
        [string]$Path,
        [string]$ImageName,
        [string]$ImageTag,
    )
    $UsernameDockerHub = "dannybatchrun"
    try {
        Set-Location $Path
        docker buildx build . -t $ImageName
        docker tag $ImageName "$UsernameDockerHub/$ImageName:$ImageTag"
        docker push "$UsernameDockerHub/$ImageName:$ImageTag"
    } catch {
        if($_.Exception.Message -match "certificate signed by unknown authority") {
            $global:currentBuild.result = "UNSTABLE"
        } else {
            $global:currentBuild.result = "FAILURE"
        }
    }
}
