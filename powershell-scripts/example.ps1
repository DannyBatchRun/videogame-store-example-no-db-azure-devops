function callVar {
    param(
        [string]$Path,
        [string]$ImageName,
        [string]$ImageTag
    )
    [string]$UsernameDockerHub = "dannybatchrun"
    [string]$ImageName = "usersubscription"
    [string]$repositoryName = "$UsernameDockerHub/$ImageName"
    [string]$lowercaseRepositoryName = $repositoryName.ToLower()
    Write-Output $lowercaserepositoryName
    Write-Output "Hey there!"
}
