function call {
    Write-Host "VideogameService initialized"
}

function installDependencies() {
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk i java 21.0.2-sapmchn
    sdk d java 21.0.2-sapmchn
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
        docker buildx build . -t $ImageName
        docker tag --% $ImageName "${UsernameDockerHub}/$ImageName:$ImageTag"
        docker push --% "${UsernameDockerHub}/$ImageName:$ImageTag"
    } catch {
        Write-Host "Error occurred: $_"
    }
}
