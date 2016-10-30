param ([string]$key)
if (-not([String]::IsNullOrEmpty($key)))
{
    $path = "C:\inetpub\wwwroot\nugetserver\Web.config"
    [xml]$config = Get-Content $path -Raw
    ($config.configuration.appSettings.add | Where-Object {$_.key -eq "apiKey"}).value = $key
    $config.Save($path)
    Stop-Website -Name 'Default Web Site'
    Start-Website -Name 'Default Web Site'
}
Start-Process C:\ServiceMonitor.exe -ArgumentList "w3svc" -Wait