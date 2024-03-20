function call {
    Write-Host "VideogameService initialized"
}

function installDependencies() {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", "/bin/java", [EnvironmentVariableTarget]::Machine)
}

function createJarFile {
    param(
        [string]$Path
    )
    try {
        # Install OpenJDK 21 using apt
        sudo apt update
        sudo apt install openjdk-11-jdk -y

        # Set JAVA_HOME environment variable
        $env:JAVA_HOME = "/usr/lib/jvm/java-1.21.0-openjdk-amd64"

        # Update PATH to include JDK bin directory
        $env:PATH = "$env:JAVA_HOME/bin;$env:PATH"

        # Confirm Java version
        java -version

        # Navigate to the specified path
        Set-Location $Path
        Write-Host "Current Directory: $(Get-Location)"

        # Run Maven commands
        mvn -v
        mvn clean install
    }
    catch {
        Write-Host "Error occurred: $_"
    }
}

# Call the function with the desired path
createJarFile -Path "store-videogame-products-example"



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
