function call {
    Write-Host "VideogameService initialized"
}

function createJarFile {
    param(
        [string]$Path
    )
    Write-Output "Changing directory to: $Path"
    Set-Location $Path

    Write-Output "Executing 'mvn -v'..."
    mvn -v

    Write-Output "Executing 'mvn clean install'..."
    mvn clean install
}

function buildAndPushOnDocker {
    param(
        [string]$Path,
        [string]$ImageName,
        [string]$ImageTag
    )
    $UsernameDockerHub = "dannybatchrun"
    try {
        Set-Location $Path
        docker buildx build . -t $ImageName
        docker tag --% $ImageName "${UsernameDockerHub}/$ImageName:$ImageTag"
        docker push --% "${UsernameDockerHub}/$ImageName:$ImageTag"
    } catch {
        if($_.Exception.Message -match "certificate signed by unknown authority") {
            $global:currentBuild.result = "UNSTABLE"
        } else {
            $global:currentBuild.result = "FAILURE"
        }
    }
}
