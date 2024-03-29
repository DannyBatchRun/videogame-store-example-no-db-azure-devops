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
    try {
        Set-Location $Path
        docker buildx build . -t $ImageName
        [string]$repositoryName = "dannybatchrun/$ImageName".ToLower()

        # Debugging output
        Write-Host "Repository Name: $repositoryName"
        Write-Host "Image Tag: $ImageTag"

        $taggedImage = "${repositoryName}:${ImageTag}"
        docker tag $ImageName $taggedImage
        docker push $taggedImage
    } catch {
        Write-Host "Error occurred: $_"
    }
}






































































