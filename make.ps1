param(
    $buildType = "Release"
)

$basePath = Get-Location
$logPath = "$basePath\logs"
$buildVersion = Get-Content .\VERSION
$projectName = "httpn"

$msbuild = "c:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
$solutionPath = "$basePath\src\httpnet.sln"
$nugetPackageProject =  "$basePath\src\httpn\httpn.csproj"
$testConfig = "$basePath\src\LocalTestRun.testrunconfig"

function incrementVersion{
    
    $version = Get-Content .\VERSION
    $versions = $version.split('.')

    $majorV = [convert]::ToInt32($versions[0], 10)
    $minorV = [convert]::ToInt32($versions[1], 10)
    $patchV = [convert]::ToInt32($versions[2], 10)
    $buildV = [convert]::ToInt32($versions[3], 10)
    $buildV += 1
    
    "$majorV.$minorV.$patchV.$buildV" | set-content .\VERSION

    $buildVersion = Get-Content .\VERSION
    write-host "Version is now $buildVersion" -foregroundcolor:blue
}

function clean{
    # CLEAN
    write-host "Cleaning" -foregroundcolor:blue
    if(!(Test-Path "$basePath\BuildOutput\"))
    {
        mkdir "$basePath\BuildOutput\"
    }
    if(!(Test-Path "$logPath"))
    {
        mkdir "$logPath"
    }
    if(!(Test-Path "$basePath\TestOutput\"))
    {
        mkdir "$basePath\TestOutput\"
    }    
   
    remove-item $basePath\BuildOutput\* -recurse
    remove-item $basePath\TestOutput\* -recurse
   
    remove-item $logPath\* -recurse
    $lastResult = $true
}

function build{
    # BUILD
    write-host "Building"  -foregroundcolor:blue   
    
    Invoke-expression "$msbuild $solutionPath /p:configuration=$buildType /t:Clean /t:Build /verbosity:q /nologo > $logPath\LogBuild.log"

    if($? -eq $False){
        Write-host "BUILD FAILED!"
        exit
    }
    
    $content = (Get-Content -Path "$logPath\LogBuild.log")
    $failedContent = ($content -match "error")
    $failedCount = $failedContent.Count
    if($failedCount -gt 0)
    {    
        Write-host "BUILDING FAILED!" -foregroundcolor:red
        $lastResult = $false
        
        Foreach ($line in $content) 
        {
            write-host $line -foregroundcolor:red
        }
    }

    if($lastResult -eq $False){    
        exit
    } 
}

function test{
    # TESTING
    write-host "Testing"  -foregroundcolor:blue

    $trxPath = "$basePath\TestOutput\AllTest.trx"
    $resultFile="/resultsfile:$trxPath"

    $testDLLs = get-childitem -path "$basePath\TestOutput\*.*" -include "*tests.dll"
     
    $arguments = " /testcontainer:" + $testDLLs + " /TestSettings:$testConfig"

    Invoke-Expression "mstest $resultFile $arguments > $logPath\LogTest.log"

    $content = (Get-Content -Path "$logPath\LogTest.log")
    $passedContent = ($content -match "Passed")
    if($passedContent.Count -eq 0)
    {    
        Write-host "TESTING FAILED!" -foregroundcolor:red
        $lastResult = $false
    }
    $failedContent = ($content -match "^Failed")
    $failedCount = $failedContent.Count
    if($failedCount -gt 0)
    {    
        Write-host "TESTING FAILED!" -foregroundcolor:red
        $lastResult = $false
    }
    Foreach ($line in $failedContent) 
    {
        write-host $line -foregroundcolor:red
    }
    if($lastResult -eq $False){    
        exit
    }
}

function pack{
    # Packing
    write-host "Packing" -foregroundcolor:blue
    nuget pack $nugetPackageProject -Version $buildVersion -OutputDirectory .\releases > $logPath\LogPacking.log     
    if($? -eq $False){
        Write-host "PACK FAILED!"  -foregroundcolor:red
        exit
    }
}

function deploy{
    # DEPLOYING
    write-host "Deploying" -foregroundcolor:blue
    $outputName = $projectName+"_V"+$buildVersion+"_BUILD.zip"
    zip a -tzip .\releases\$outputName -r .\BuildOutput\*.* >> $logPath\LogDeploy.log    

}

if($buildType -eq "package"){
    
    $buildType="Release"

    incrementVersion
    clean
    build
    test
    pack
    deploy

    exit
}
if($buildType -eq "clean"){
    
    clean  
    exit
}

else {
    incrementVersion
    clean
    build
    test    
}
Write-Host Finished -foregroundcolor:blue

