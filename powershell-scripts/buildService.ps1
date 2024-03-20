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
        mvn -v
        mvn clean install
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
        Start-Process docker buildx build . -t $ImageName
        Start-Process docker tag --% $ImageName "${UsernameDockerHub}/$ImageName:$ImageTag"
        Start-Process docker push --% "${UsernameDockerHub}/$ImageName:$ImageTag"
    } catch {
        Write-Host "Error occurred: $_"
    }
}
