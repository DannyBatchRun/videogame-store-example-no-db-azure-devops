function call {
    Write-Host "VideogameService initialized"
}

function createJarFile {
    param(
        [string]$Path
    )
    try {
        sudo apt update
        sudo apt install openjdk-21-jdk -y
        $env:JAVA_HOME = "/usr/lib/jvm/java-1.21.0-openjdk-amd64"
        $env:PATH = "$env:JAVA_HOME/bin;$env:PATH"
        java -version
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
    $UsernameDockerHub = "dannybatchrun"
    try {
        Set-Location $Path
        docker buildx build . -t $ImageName
        $lowercaseImageName = $ImageName.ToLower()
        $taggedImage = "${UsernameDockerHub}/" + $lowercaseImageName + ":" + $ImageTag
        docker tag $lowercaseImageName $taggedImage
        docker push $taggedImage
    } catch {
        Write-Host "Error occurred: $_"
    }
}
