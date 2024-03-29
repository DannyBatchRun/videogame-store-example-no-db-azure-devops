function call() {
    Write-Host "VideogameAutomationService initialized"
    return this;
}

function installIntoDirectory {
    param(
        [string]$path,
        [string]$testType
    )
    $currentLocation = Get-Location
    Set-Location $path
    npm install --save @cucumber/cucumber axios pactum
    Write-Host "Dependencies installed for ${testType}"
    Set-Location $currentLocation
}

function replaceEndpoints {
    param(
        [string]$microservice,
        [string]$path,
        [string]$testType,
        [string]$servicePort
    )
    $apiEndpoint = & minikube service $microservice --url -n "${microservice}" | Select-Object -First 1
    $apiEndpoint = $apiEndpoint.Trim()
    $currentLocation = Get-Location
    Set-Location "${path}/cucumber-auto/${testType}/features/step_definitions"
    $fileContent = Get-Content 'stepdefs.js' -Raw
    $replaced = $fileContent -replace "http://localhost:${servicePort}", "${apiEndpoint}"
    Set-Content -Path 'stepdefs.js' -Value $replaced
    if($microservice -eq "videogamestore") {
        Set-Location $currentLocation
        Set-Location "store-videogamestore-final-example/cucumber-auto/synchronize"
        $urlSubscription = & minikube service usersubscription --url -n usersubscription | Select-Object -First 1
        $urlVideogame = & minikube service videogameproducts --url -n videogameproducts | Select-Object -First 1
        (Get-Content -Path "features/synchronize_all.feature") -replace "ENDPOINT_USERSUBSCRIPTION", "${urlSubscription}" | Set-Content -Path "features/synchronize_all.feature"
        (Get-Content -Path "features/synchronize_all.feature") -replace "ENDPOINT_VIDEOGAMEPRODUCTS", "${urlVideogame}" | Set-Content -Path "features/synchronize_all.feature"
    }
    Set-Location $currentLocation
}

function prepareEndpoints {
    param(
        [string]$microservice
    )
    switch($microservice) {
        "usersubscription" {
            replaceEndpoints "usersubscription" "store-usersubscription-example" "postrequestmonthly" "8090"
            replaceEndpoints "usersubscription" "store-usersubscription-example" "postrequestannual" "8090"
            replaceEndpoints "usersubscription" "store-usersubscription-example" "getrequest" "8090"
        }
        "videogameproducts" {
            replaceEndpoints "videogameproducts" "store-videogame-products-example" "postrequest" "8100"
            replaceEndpoints "videogameproducts" "store-videogame-products-example" "getrequest" "8100"
            replaceEndpoints "videogameproducts" "store-videogame-products-example" "deleterequest" "8100"
        }
        "videogamestore" {
            replaceEndpoints "videogamestore" "store-videogamestore-final-example" "synchronize" "8080"
            replaceEndpoints "videogamestore" "store-videogamestore-final-example" "postrequest" "8080"
            replaceEndpoints "videogamestore" "store-videogamestore-final-example" "getrequest" "8080"
        }
    }
}

function installDependenciesNodeJs {
    param(
        [string]$microservice
    )
    switch($microservice) {
        "usersubscription" {
            installIntoDirectory "store-usersubscription-example" "postrequestmonthly"
            installIntoDirectory "store-usersubscription-example" "postrequestannual"
            installIntoDirectory "store-usersubscription-example" "getrequest"
        }
        "videogameproducts" {
            installIntoDirectory "store-videogame-products-example" "postrequest"
            installIntoDirectory "store-videogame-products-example" "getrequest"
            installIntoDirectory "store-videogame-products-example" "deleterequest"
        }
        "videogamestore" {
            installIntoDirectory "store-videogamestore-final-example" "synchronize"
            installIntoDirectory "store-videogamestore-final-example" "postrequest"
            installIntoDirectory "store-videogamestore-final-example" "getrequest"
        }
    }
}

function runTestCucumber {
    param(
        [string]$microservice,
        [string]$testType
    )
    $path = switch($microservice) {
        "usersubscription" { "store-usersubscription-example" }
        "videogameproducts" { "store-videogame-products-example" }
        "videogamestore" { "store-videogamestore-final-example" }
    }
    Write-Host "**** RUNNING TEST $($microservice.ToUpper()) : $($testType.ToUpper())"
    $currentLocation = Get-Location
    try {
        Set-Location "${path}/cucumber-auto/${testType}"
        npm test
    }
    catch [Exception] {
        Write-Host "Error while executing script: $($_.Exception.Message)"
    }
    finally {
        Write-Host "*** $($microservice.ToUpper()) : $($testType.ToUpper()) COMPLETED SUCCESSFULLY"
        Set-Location $currentLocation
    }
}
