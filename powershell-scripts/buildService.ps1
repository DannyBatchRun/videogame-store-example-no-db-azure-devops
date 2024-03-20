function call {
    Write-Host "VideogameService initialized"
}

function createJarFile {
    param(
        [string]$Path
    )
    try {
        Set-Location $Path
        Write-Host "Current Directory: $(Get-Location)"
        /opt/maven/bin/mvn -v
        /opt/maven/bin/mvn clean install
    }
    catch {
        Write-Host "Error occurred: $_"
    }
}


function buildAndPushOnDocker {
    param(
        [string]$Path,
        [string]$ImageName,
        [string]$ImageTag
    )
    [String]$UsernameDockerHub = "dannybatchrun"
    try {
        Set-Location $Path
        docker buildx build . -t $ImageName
        docker tag --% $ImageName "${UsernameDockerHub}/$ImageName:$ImageTag"
        docker push --% "${UsernameDockerHub}/$ImageName:$ImageTag"
    } catch {
        Write-Host "Error occurred: $_"
    }
}
