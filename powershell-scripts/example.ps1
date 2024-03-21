function callVar {
    param(
        [string]$Path,
        [string]$ImageName,
        [string]$ImageTag
    )

    $ImageTag = $env:IMAGE_TAG
    Write-Host "IMAGE_TAG value: $ImageTag"
    [string]$UsernameDockerHub = "dannybatchrun"
    [string]$ImageName = "usersubscription"
    [string]$repositoryName = "$UsernameDockerHub/$ImageName"
    [string]$ImageComplete = "${repositoryName}:$ImageTag"
    [string]$lowercaseRepositoryName = $ImageComplete.ToLower()
    Write-Output $lowercaserepositoryName
    Write-Output "Hey there!"
}
