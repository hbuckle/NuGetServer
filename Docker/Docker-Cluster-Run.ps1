param(
    [string[]]$servers,
    [string]$packagesroot,
    [string]$containerhost,
    [string]$domain,
    [PSCredential]$cred
)
$ErrorActionPreference = "Stop"
if ([String]::IsNullOrEmpty($containerhost))
{
    $containerhost = "localhost"
}
docker -H $containerhost pull hbuckle/nugetserver
docker -H $containerhost pull hbuckle/iis-reverse-proxy

$serverdetails = @()
foreach ($server in $servers)
{
    $packagevolume = Join-Path $packagesroot $server
    Invoke-Command -ComputerName ($containerhost -split ':')[0] -ScriptBlock {
        New-Item -Path $Using:packagevolume -ItemType Directory -ErrorAction SilentlyContinue
    } -Credential $cred
    $packagemount = "${packagevolume}:C:\Packages"
    $pw = -join ((65..90) + (97..122) | Get-Random -Count 15 | ForEach-Object {[char]$_})
    $id = docker -H $containerhost run -d -h $server -l nuget -v $packagemount --name $server hbuckle/nugetserver $pw
    $info = ($info = docker -H $containerhost container inspect $id | ConvertFrom-Json)[0]
    $ip = $info.NetworkSettings.Networks.nat.IPAddress
    $detail = @{externalHostname = $server;containerHostname = $server;appPath = 'nugetserver'}
    $serverdetails += $detail
    $props = [ordered]@{
        Name = $server
        ID = $id
        InternalIP = $ip
        PackageFolder = $packagevolume
        ApiKey = $pw
        Url = "https://${server}.${domain}"
    }
    $result = New-Object -TypeName PSObject -Property $props
    Write-Output $result
}
[string]$jsonstring = $serverdetails | ConvertTo-Json
#Need to escape the quotes in the JSON string or Docker strips them out
$jsonstring = $jsonstring -replace '"','\"'
$iisid = docker -H $containerhost run -d -l nuget --name iisrp -p 443:443 hbuckle/iis-reverse-proxy "-servers" $jsonstring "-domain" $domain
Write-Output "Proxy container ID: $iisid"